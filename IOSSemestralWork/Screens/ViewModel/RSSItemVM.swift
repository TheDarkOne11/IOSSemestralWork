//
//  RSSItemVM.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 14/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift
import Data
import Resources

protocol IRSSItemVM {
    var selectedItem: MutableProperty<MyRSSItem> { get }
    var canGoUp: MutableProperty<Bool> { get }
    var canGoDown: MutableProperty<Bool> { get }
    
    func set(isRead: Bool)
    func set(isStarred: Bool)
    func goUp()
    func goDown()
    
    func getScriptCode() -> String
}

final class RSSItemVM: BaseViewModel, IRSSItemVM {
    typealias Dependencies = HasRepository & HasDBHandler & HasRealm & HasRootFolder & HasUserDefaults
    private let dependencies: Dependencies!
    
    let otherRssItems: Results<MyRSSItem>
    let selectedItem: MutableProperty<MyRSSItem>
    let canGoUp = MutableProperty<Bool>(false)
    let canGoDown = MutableProperty<Bool>(false)
    
    private var currentIndex: Int
    
    init(dependencies: Dependencies, otherRssItems: Results<MyRSSItem>) {
        self.dependencies = dependencies
        self.otherRssItems = otherRssItems
        
        guard let selectedItem = dependencies.repository.selectedItem.value as? MyRSSItem else {
            fatalError("Selected item must be a RSSItem")
        }
        
        self.selectedItem = MutableProperty<MyRSSItem>(selectedItem)
        
        guard let index = otherRssItems.index(of: selectedItem) else {
            fatalError("Selected item must exist in Realm DB")
        }
        self.currentIndex = index
        
        super.init()
        
        self.selectedItem.producer.startWithValues { [weak self] selectedItem in
            self?.canGoUp.value = selectedItem.itemId != otherRssItems.first!.itemId
            self?.canGoDown.value = selectedItem.itemId != otherRssItems.last!.itemId

            if !selectedItem.isRead {
                self?.dependencies.dbHandler.realmEdit(errorMsg: "Could not edit the selected item.") {
                    selectedItem.isRead = true
                }
            }
        }
    }
    
    func set(isRead: Bool) {
        dependencies.dbHandler.realmEdit(errorMsg: "Could not edit the selected item.") {
            selectedItem.value.isRead = isRead
        }
    }
    
    func set(isStarred: Bool) {
        dependencies.dbHandler.realmEdit(errorMsg: "Could not edit the selected item.") {
            selectedItem.value.isStarred = isStarred
        }
    }
    
    func goUp() {
        currentIndex -= 1
        selectedItem.value = otherRssItems[currentIndex]
    }
    
    func goDown() {
        currentIndex += 1
        selectedItem.value = otherRssItems[currentIndex]
    }
    
    /**
     Create Javascript code which passes data to the webView.
     
     - parameter rssItem: The RSSItem whose data we want to display.
     
     - returns: The String value of the Javascript code used to pass data into the WKWebView.
     */
    func getScriptCode() -> String {
        // Time
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_GB")  // "cs_CZ"
        var timeString = L10n.RssItemVM.timeString(formatter.string(from: selectedItem.value.date!))
        
        if let author = selectedItem.value.author {
            timeString = "\(timeString) \(L10n.RssItemVM.authorPart(author))"
        }
        
        // Init RSSItem webView
        var code = String(format: "init(`%@`, `%@`, `%@`);", selectedItem.value.title, timeString, selectedItem.value.itemDescription)
        
        if let imageLink = selectedItem.value.image {
            code += String(format: "showImage(`%@`);", imageLink)
        }
        
        return code
    }
}

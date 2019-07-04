//
//  RSSFeedEditVM.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 02/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift

protocol RSSFeedEditProtocol {
    var title: MutableProperty<String> { get }
    var link: MutableProperty<String> { get }
    var feedForUpdate: MutableProperty<MyRSSFeed?> { get }
    var folder: MutableProperty<Folder?> { get }
    
    var saveBtnAction: Action<Void, MyRSSFeed, MyRSSFeedError> { get }
}

final class RSSFeedEditVM: BaseViewModel, RSSFeedEditProtocol {
    typealias Dependencies = HasRepository
    private let dependencies: Dependencies
    
    let title = MutableProperty<String>("")
    let link = MutableProperty<String>("")
    let feedForUpdate = MutableProperty<MyRSSFeed?>(nil)
    let folder = MutableProperty<Folder?>(nil)
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    /*
     Action that starts when the Save button is clicked.
     */
    lazy var saveBtnAction = Action<Void, MyRSSFeed, MyRSSFeedError> { [unowned self] in
        var link = self.link.value
        var title = self.title.value
        var folder: Folder = self.folder.value!
        
        if !link.starts(with: "http://") && !link.starts(with: "https://") {
            link = "http://" + link
        }
        
        if title == "" {
            title = link
        }
        
        let newFeed = MyRSSFeed(title: title, link: link, in: folder)
        if let feed = self.feedForUpdate.value {
            return self.dependencies.repository.update(selectedFeed: feed, with: newFeed)
        } else {
            return self.dependencies.repository.create(rssFeed: newFeed)
        }
    }
}

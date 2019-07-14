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

protocol IRSSFeedEditVM {
    var feedName: MutableProperty<String> { get }
    var link: MutableProperty<String> { get }
    var feedForUpdate: MutableProperty<MyRSSFeed?> { get }
    
    var selectedFolder: MutableProperty<Folder> { get }
    var folders: Results<Folder> { get }
    
    var saveBtnAction: Action<Void, MyRSSFeed, MyRSSFeedError> { get }
    
    /** Returns a folder at the selected index.*/
    func getFolder(at index: Int) -> Folder
    
    func createFolder(title: String)
}

final class RSSFeedEditVM: BaseViewModel, IRSSFeedEditVM {
    typealias Dependencies = HasRepository & HasRealm & HasRootFolder & HasDBHandler
    private let dependencies: Dependencies
    
    let feedName = MutableProperty<String>("")
    let link = MutableProperty<String>("")
    let feedForUpdate = MutableProperty<MyRSSFeed?>(nil)
    
    let selectedFolder: MutableProperty<Folder>
    let folders: Results<Folder>
    
    init(dependencies: Dependencies, feedForUpdate: MyRSSFeed? = nil) {
        self.dependencies = dependencies
        
        if let feedForUpdate = feedForUpdate {
            feedName.value = feedForUpdate.title
            link.value = feedForUpdate.link
            selectedFolder = MutableProperty<Folder>(feedForUpdate.folder.first!)
            self.feedForUpdate.value = feedForUpdate
        } else {
            selectedFolder = MutableProperty<Folder>(dependencies.rootFolder)
        }
        
        folders = dependencies.realm.objects(Folder.self).filter("title != %@", dependencies.rootFolder.title)
    }
    
    /*
     Action that starts when the Save button is clicked.
     */
    lazy var saveBtnAction = Action<Void, MyRSSFeed, MyRSSFeedError> { [unowned self] in
        var link = self.link.value
        var title = self.feedName.value
        var folder: Folder = self.selectedFolder.value
        
        if !link.starts(with: "http://") && !link.starts(with: "https://") {
            link = "http://" + link
        }
        
        if title == "" {
            title = link
        }
        
        let newFeed = MyRSSFeed(title: title, link: link)   //FIXME: No folder
        if let feed = self.feedForUpdate.value {
            return self.dependencies.repository.update(selectedFeed: feed, with: newFeed, parentFolder: folder)
        } else {
            return self.dependencies.repository.create(rssFeed: newFeed, parentFolder: folder)
        }
    }
    
    /**
     Returns folder at the selected index.
     */
    func getFolder(at index: Int) -> Folder {
        var folder: Folder!
        
        if index == 0 {
            folder = dependencies.rootFolder
        } else if index >= 1 && index <= folders.count + 1 {
            folder = folders[index - 1]
        } else {
            fatalError("Index \(index) out of bounds.")
        }
        
        return folder
    }
    
    func createFolder(title: String) {
        let folder = Folder(withTitle: title)
        dependencies.dbHandler.create(folder)
        
        selectedFolder.value = folder
    }
}

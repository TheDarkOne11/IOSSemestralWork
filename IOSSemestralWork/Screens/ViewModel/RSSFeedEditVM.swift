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
import Data
import Common

protocol IRSSFeedEditVM {
    typealias CreateFolderInput = (String, Folder?)
    
    var feedName: MutableProperty<String> { get }
    var link: MutableProperty<String> { get }
    var feedForUpdate: MutableProperty<MyRSSFeed?> { get }
    
    var selectedFolder: MutableProperty<Folder> { get }
    var folders: Results<Folder> { get }
    
    var saveBtnAction: Action<Void, MyRSSFeed, RSSFeedCreationError> { get }
    var createFolderAction: Action<CreateFolderInput, Folder, RSSFeedCreationError> { get }
    
    /** Returns a folder at the selected index.*/
    func getFolder(at index: Int) -> Folder
}

final class RSSFeedEditVM: BaseViewModel, IRSSFeedEditVM {
    typealias Dependencies = HasRepository
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
            selectedFolder = MutableProperty<Folder>(dependencies.repository.rootFolder)
        }
        
        folders = dependencies.repository.folders.filter("title != %@", dependencies.repository.rootFolder.title)
    }
    
    /*
     Action that starts when the Save button is clicked.
     */
    lazy var saveBtnAction = Action<Void, MyRSSFeed, RSSFeedCreationError> { [unowned self] in
        let folder = self.selectedFolder.value
        let newFeed = self.createFeed(title: self.feedName.value, link: self.link.value)
        
        if let feed = self.feedForUpdate.value {
            return self.dependencies.repository.update(selectedFeed: feed, with: newFeed, parentFolder: folder)
        } else {
            return self.dependencies.repository.create(rssFeed: newFeed, parentFolder: folder)
        }
    }
    
    lazy var createFolderAction = Action<CreateFolderInput, Folder, RSSFeedCreationError> { [unowned self] (title, parentFolder) in
        let parentFolder: Folder = parentFolder != nil ? parentFolder! : self.dependencies.repository.rootFolder
        return self.dependencies.repository.create(newFolder: Folder(withTitle: title), parentFolder: parentFolder)
            .on(value: { [weak self] folder in
                self?.selectedFolder.value = folder
            })
    }
    
    /**
     Returns folder at the selected index.
     */
    func getFolder(at index: Int) -> Folder {
        var folder: Folder!
        
        if index == 0 {
            folder = dependencies.repository.rootFolder
        } else if index >= 1 && index <= folders.count + 1 {
            folder = folders[index - 1]
        } else {
            fatalError("Index \(index) out of bounds.")
        }
        
        return folder
    }
    
    private func createFeed(title: String, link: String) -> MyRSSFeed {
        var link = link
        var title = title
        
        if !link.starts(with: "http://") && !link.starts(with: "https://") {
            link = "http://" + link
        }
        
        if title == "" {
            title = link
        }
        
        return MyRSSFeed(title: title, link: link)
    }
}

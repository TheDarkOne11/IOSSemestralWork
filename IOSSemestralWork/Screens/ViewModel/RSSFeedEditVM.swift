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
    var feedName: MutableProperty<String> { get }
    var link: MutableProperty<String> { get }
    var feedForUpdate: MutableProperty<MyRSSFeed?> { get }
    
    var selectedFolder: MutableProperty<Folder> { get }
    var folders: Results<Folder> { get }
    
    var saveBtnAction: Action<Void, MyRSSFeed, RealmObjectError> { get }
    var validateLinkSignal: SignalProducer<DownloadStatus, Never> { get }
    var canCreateFeed: MutableProperty<Bool> { get }
    
    /** Returns a folder at the selected index.*/
    func getFolder(at index: Int) -> Folder
}

final class RSSFeedEditVM: BaseViewModel, IRSSFeedEditVM {
    typealias Dependencies = HasRepository
    private let dependencies: Dependencies
    
    let feedName = MutableProperty<String>("")
    let link = MutableProperty<String>("")
    let feedForUpdate = MutableProperty<MyRSSFeed?>(nil)
    let canCreateFeed = MutableProperty<Bool>(false)
    
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
        
        super.init()
        
        canCreateFeed <~ validateLinkSignal.map { downloadStatus -> Bool in
            return downloadStatus == .OK || downloadStatus == .emptyFeed
        }
    }
    
    /*
     Action that starts when the Save button is clicked.
     */
    lazy var saveBtnAction = Action<Void, MyRSSFeed, RealmObjectError> { [unowned self] in
        let folder = self.selectedFolder.value
        let newFeed = self.createFeed(title: self.feedName.value, link: self.link.value)
        
        if let feed = self.feedForUpdate.value {
            return self.dependencies.repository.update(selectedFeed: feed, with: newFeed, parentFolder: folder)
        } else {
            return self.dependencies.repository.create(rssFeed: newFeed, parentFolder: folder)
        }
    }
    
    lazy var validateLinkSignal: SignalProducer<DownloadStatus, Never> = {
        return self.link.producer
            .on(value: { [weak self] _ in
                self?.canCreateFeed.value = false
            })
            .flatMap(FlattenStrategy.latest, { [weak self] currLink -> SignalProducer<DownloadStatus, Never> in
                guard let self = self else { return SignalProducer<DownloadStatus, Never>.init(value: .unreachable) }
                
                return self.dependencies.repository.validate(link: currLink)
            })
            .throttle(2, on: QueueScheduler.main)
    }()
    
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

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

final class RSSFeedEditVM: BaseViewModel {
    private let repository: Repository = Repository()
    private let realm = try! Realm()
    
    let title = MutableProperty<String>("")
    let link = MutableProperty<String>("")
    let feedForUpdate = MutableProperty<MyRSSFeed?>(nil)
    let folder = MutableProperty<Folder?>(nil)
    
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
        
        if let feed = self.feedForUpdate.value {
            return self.repository.update(selectedFeed: feed, title: title, link: link, folder: folder)
        } else {
            return self.repository.create(title: title, link: link, folder: folder)
        }
    }
}

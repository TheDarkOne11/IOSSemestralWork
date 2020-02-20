//
//  TestRepository.swift
//  Data
//
//  Created by Petr Budík on 20/02/2020.
//  Copyright © 2020 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift
import Common
import Resources
import ReactiveSwift

/**
 A dummy `Repository` which does not download data from the Internet.
 */
public final class TestRepository: Repository {
    /**
     Adds a dummy `MyRSSItem` to all feeds.
     */
    override public func updateAllFeeds(completed: @escaping (DownloadStatus) -> Void) {
        
        realmEdit(errorCode: nil) { realm in
            var cntr: Int = 0
            
            for feed in self.feeds {
                let currItem: MyRSSItem = MyRSSItem()
                currItem.title = "Dummy title " + String(cntr)
                currItem.itemDescription = "Dummy desc " + String(cntr)
                cntr += 1
                
                feed.myRssItems.append(currItem)
            }
        }
    }
    
    /**
     Dummy validation, always returns OK.
     */
    override public func validate(link: String) -> SignalProducer<DownloadStatus, Never> {
        return SignalProducer<DownloadStatus, Never> { (observer, lifetime) in
            observer.send(value: .OK)
            observer.sendCompleted()
        }
    }
}

//
//  File.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 06/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Data

/**
 Programatically manages and coordinates flow of the application i. e. when which screen should be shown.
 */
class AppFlowCoordinator: BaseFlowCoordinator {
    public var childCoordinators = [BaseFlowCoordinator]()
    weak var navigationController: UINavigationController!
    
    /**
     Initial setup.
     
     - Parameters:
        - window: Screen where the application will be shown.
     */
    func start(in window: UIWindow) {
        // Set up Flow Coordinator
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        self.navigationController = navigationController
        
        Globals.dependencies.repository.selectedItem.producer
            .startWithValues { [weak navigationController] item in
                switch item.type {

                case .folder:
                    let vm = ItemTableVM(dependencies: Globals.dependencies)
                    let vc = ItemTableVC(vm)
                    vc.flowDelegate = self
                    navigationController?.pushViewController(vc, animated: true)
                case .myRssFeed:
                    let item = item as! MyRSSFeed
                    let vm = RSSItemsTableVM(dependencies: Globals.dependencies, title: item.title, selectedItem: item)
                    let vc = RSSItemsTableVC(vm, delegate: self)
                    navigationController?.pushViewController(vc, animated: true)
                case .myRssItem:
                    break
                case .specialItem:
                    let item = item as! SpecialItem
                    let actionResult = item.action()
                    let vm = RSSItemsTableVM(dependencies: Globals.dependencies, title: item.title, selectedItem: actionResult.0, predicate: actionResult.1)
                    let vc = RSSItemsTableVC(vm, delegate: self)
                    navigationController?.pushViewController(vc, animated: true)
                }
        }
    }
}

extension AppFlowCoordinator: FolderEditFlowDelegate {
    func editSuccessful(in viewController: FolderEditVC) {
        navigationController.popViewController(animated: true)
    }
}

extension AppFlowCoordinator: RSSFeedEditFlowDelegate {
    func add(folder: Folder?, delegate: FolderEditDelegate) {
        let vm = FolderEditVM(dependencies: Globals.dependencies, folderForUpdate: folder)
        let vc = FolderEditVC(vm)
        vc.flowDelegate = self
        vc.delegate = delegate
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func editSuccessful(in viewController: RSSFeedEditVC) {
        navigationController.popViewController(animated: true)
    }
}

extension AppFlowCoordinator: ItemTableVCFlowDelegate {
    func edit(folder: Folder) {
        let vm = FolderEditVM(dependencies: Globals.dependencies, folderForUpdate: folder)
        let vc = FolderEditVC(vm)
        vc.flowDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func editOrCreate(feed: MyRSSFeed?) {
        let vm = RSSFeedEditVM(dependencies: Globals.dependencies, feedForUpdate: feed)
        let vc = RSSFeedEditVC(vm)
        vc.flowDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AppFlowCoordinator: RSSItemsTableVCFlowDelegate {
    func select(_ rssItem: MyRSSItem, otherRssItems: Results<MyRSSItem>) {
        let vm = RSSItemVM(dependencies: Globals.dependencies, otherRssItems: otherRssItems)
        let vc = RSSItemVC(vm)
        navigationController?.pushViewController(vc, animated: true)
    }
}

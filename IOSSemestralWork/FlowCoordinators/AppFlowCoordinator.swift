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
import Common

class AppFlowCoordinator: BaseFlowCoordinator {
    public var childCoordinators = [BaseFlowCoordinator]()
    weak var navigationController: UINavigationController!
    
    func start(in window: UIWindow) {
        // Set up Flow Coordinator
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        self.navigationController = navigationController
        
        AppDependency.shared.repository.selectedItem.producer
            .startWithValues { [weak navigationController] item in
                switch item.type {

                case .folder:
                    let vm = ItemTableVM(dependencies: AppDependency.shared)
                    let vc = ItemTableVC(vm)
                    vc.flowDelegate = self
                    navigationController?.pushViewController(vc, animated: true)
                case .myRssFeed:
                    let item = item as! MyRSSFeed
                    let vm = RSSItemsTableVM(dependencies: AppDependency.shared, selectedItem: item)
                    let vc = RSSItemsTableVC(vm)
                    navigationController?.pushViewController(vc, animated: true)
                case .myRssItem:
                    let vm = RSSItemVM(dependencies: AppDependency.shared)
                    let vc = RSSItemVC(vm)
                    navigationController?.pushViewController(vc, animated: true)
                case .specialItem:
                    let item = item as! SpecialItem
                    let actionResult = item.action()
                    let vm = RSSItemsTableVM(dependencies: AppDependency.shared, selectedItem: actionResult.0, predicate: actionResult.1)
                    let vc = RSSItemsTableVC(vm)
                    navigationController?.pushViewController(vc, animated: true)
                }
        }
    }
}


extension AppFlowCoordinator: RSSFeedEditFlowDelegate {
    func editSuccessful(in viewController: RSSFeedEditVC) {
        navigationController.popViewController(animated: true)
    }
}

extension AppFlowCoordinator: ItemTableVCFlowDelegate {
    func toFeedEdit(with feed: MyRSSFeed?) {
        let vm = RSSFeedEditVM(dependencies: AppDependency.shared, feedForUpdate: feed)
        let vc = RSSFeedEditVC(vm)
        vc.flowDelegate = self
        navigationController?.pushViewController(vc, animated: true)    //FIXME: We shouldn't go back when cancelling edit, we should cancel
    }
}

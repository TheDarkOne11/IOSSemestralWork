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

class AppFlowCoordinator: BaseFlowCoordinator {
    public var childCoordinators = [BaseFlowCoordinator]()
    weak var navigationController: UINavigationController!
    
    func start(in window: UIWindow) {
        // Set up Flow Coordinator
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        self.navigationController = navigationController
        
        //        let vm = RSSFeedEditVM(dependencies: AppDependency.shared)
        //        let vc = RSSFeedEditVC(vm)
        //        vc.flowDelegate = self
        //        navigationController.setViewControllers([vc], animated: true)
        
        AppDependency.shared.repository.selectedItem.producer
            .startWithValues { [weak navigationController] item in
                switch item.type {
                    
                case .folder:
                    let vm = ItemTableVM(dependencies: AppDependency.shared)
                    let vc = ItemTableVC(vm)
                    navigationController?.pushViewController(vc, animated: true)
                case .myRssFeed:
                    let item = item as! MyRSSFeed
                    print("RSS feed selected: \(item.title)")
                case .myRssItem:
                    let item = item as! MyRSSItem
                    print("RSS item selected: \(item.articleLink)")
                case .specialItem:
                    let item = item as! SpecialItem
                    let actionResult = item.action()
                    print("Special item selected: \(item.title)")
                }
        }
    }
}


extension AppFlowCoordinator: RSSFeedEditFlowDelegate {
    func editSuccessful(in viewController: RSSFeedEditVC) {
        viewController.dismiss(animated: true)
    }
}

extension AppFlowCoordinator: ItemTableVCFlowDelegate {
    func toFeedEdit(in viewController: ItemTableVC) {
        let vm = RSSFeedEditVM(dependencies: AppDependency.shared)
        let vc = RSSFeedEditVC(vm)
        vc.flowDelegate = self
        navigationController.setViewControllers([vc], animated: true)
    }
}

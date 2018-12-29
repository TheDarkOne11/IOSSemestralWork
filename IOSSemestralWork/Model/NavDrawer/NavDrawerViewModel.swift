//
//  NavDrawerModel.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation
import UIKit

/**
 Can be used by any ViewController.
 The ViewModel knows nothing about the View, but it provides all the data, that the View may need.
 */
class NavDrawerViewModel : NSObject {
    var items = [NavDrawerViewModelItem]()
    
    /**
     - Parameter navDrawer: This model has all the data we get from a ViewController. We use it to set up our Navigation drawer.
     */
    init(navDrawer: NavDrawer) {
        super.init()
        
//                if let buttons = navDrawer.buttons {
//        
//                }
//
//                if let feedCategories = navDrawer.feedCategories {
//        
//                }
        // Pass data to appropriate models
        items.append(NavDrawerViewModelItem_Buttons(with: navDrawer.buttons))
        
        items.append(NavDrawerViewModelItem_FeedCategories(with: navDrawer.feedCategories))
    }
}

extension NavDrawerViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        
//        switch item.type {
//        case .feedCategories:
//            
//        case .buttons:
//            
//        case .addFeed:
//            if let cell = tableView.dequeueReusableCell(withIdentifier: NamePictureCell.identifier, for: indexPath) as? NamePictureCell {
//                cell.item = item
//                return cell
//            }
//        }
        
        
        return UITableViewCell()
    }
}

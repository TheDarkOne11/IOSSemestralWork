//
//  NavDrawerModel.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation

/**
 Different parts of Navigation Drawer.
 They might use different ViewTable cells.
 */
enum NavDrawerViewModelItemType {
    case buttons    // Settings etc.
    case feedCategories // Feeds which are divided into categories
    case addFeed    // Add feed button
}

/**
 What we need to know about each cell.
 */
protocol NavDrawerViewModelItem {
    var type: NavDrawerViewModelItemType { get }
    var sectionTitle: String { get }
    var rowCount: Int { get }
}

/**
 Specifies default value for the protocol.
 */
extension NavDrawerViewModelItem {
    var rowCount: Int {
        return 1
    }
    
    var sectionTitle: String {
        return ""
    }
}

class NavDrawerViewModelItem_AddFeed: NavDrawerViewModelItem {
    var type: NavDrawerViewModelItemType {
        return .addFeed
    }
}

class NavDrawerViewModelItem_Buttons: NavDrawerViewModelItem {
    var type: NavDrawerViewModelItemType {
        return .buttons
    }
    
    var rowCount: Int {
        return buttons.count
    }
    
    var buttons: [String]
    
    init(with buttons: [String]) {
        self.buttons = buttons
    }
}

/**
 ViewModel for our dynamic list of feeds and feed categories.
 */
class NavDrawerViewModelItem_FeedCategories: NavDrawerViewModelItem {
    var type: NavDrawerViewModelItemType {
        return .feedCategories
    }
    
    var sectionTitle: String {
        return "Feeds"
    }
    
    var rowCount: Int {
        return feedCategories.count
    }
    
    var feedCategories: [FeedCategory]
    
    init(with feedCategories: [FeedCategory]) {
        self.feedCategories = feedCategories
    }
}

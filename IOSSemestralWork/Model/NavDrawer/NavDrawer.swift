//
//  NavDrawer.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation

/**
 Describes structure of our Navigation Drawer, the view which appears when we swipe right on the main screen.
 */
class NavDrawer {
    
    // Settings etc.
    var buttons = [String]()
    
    var feedCategories = [FeedCategory]()
    
    // MARK: Generate buttons
    
    init() {
        // Create all the buttons we are going to have
        buttons.append("Read later")
        buttons.append("Day/ Night mode")
        buttons.append("Settings")
    }
}

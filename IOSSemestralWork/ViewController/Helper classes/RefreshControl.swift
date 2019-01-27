//
//  RefreshControl.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 27/01/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import UIKit

protocol RefreshControlDelegate {
    /**
     This method is called when PullToRefresh is activated.
     */
    func update()
}

class RefreshControl: UIRefreshControl {
    var refreshView: PullToRefreshView!
    var delegate: RefreshControlDelegate!
    
    let defaults = UserDefaults.standard
    
    override init() {
        super.init()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        tintColor = .clear
        backgroundColor = .clear
        addTarget(self, action: #selector(updateFeeds), for: .valueChanged)
        
        // Initialize PullToRefreshView
        if let objOfRefreshView = Bundle.main.loadNibNamed("PullToRefreshView", owner: self, options: nil)?.first as? PullToRefreshView {
            // Initializing the 'refreshView'
            refreshView = objOfRefreshView
            refreshView.updateLabelText()
            refreshView.frame = frame
            
            // Adding the 'refreshView' to 'tableViewRefreshControl'
            addSubview(refreshView)
        }
    }
    
    /**
     Update method which calls the delegates update method.
     This one is used by a selector.
     */
    @objc
    private func updateFeeds() {
        delegate.update()
    }
}

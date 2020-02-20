//
//  RefreshControl.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 7/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import UIKit
import Data

protocol RefreshControlDelegate {
    /**
     This method is called when PullToRefresh is activated.
     */
    func update()
    func lastUpdateDate() -> NSDate
}

/**
 Contains PullToRefresh logic for starting/stopping update.
 */
class RefreshControl: UIRefreshControl {
    private(set) var refreshView: PullToRefreshView!
    private let delegate: RefreshControlDelegate!
    
    init(delegate: RefreshControlDelegate) {
        self.delegate = delegate
        super.init()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Initializer of RefreshControl.
     */
    private func commonInit() {
        tintColor = .clear
        backgroundColor = .clear
        addTarget(self, action: #selector(updateFeeds), for: .valueChanged)
        
        // Initialize PullToRefreshView
        if let objOfRefreshView = Bundle.main.loadNibNamed("PullToRefreshView", owner: self, options: nil)?.first as? PullToRefreshView {
            // Initializing the 'refreshView'
            refreshView = objOfRefreshView
            refreshView.updateLabelText(date: delegate.lastUpdateDate())
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
        refreshView.updateLabelText(date: delegate.lastUpdateDate())
        delegate.update()
    }
}

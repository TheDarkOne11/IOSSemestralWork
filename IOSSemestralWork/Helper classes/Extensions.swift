//
//  Extensions.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 05/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

extension UIView {
    func addSubViews(_ subViews: UIView...) -> UIView {
        for subView in subViews {
            self.addSubview(subView)
        }
        
        return self
    }
}

extension UITableView {
    class Section {
        var rows: [Row] = []
        var header: String?
        var footer: String?
        
        init(rows: Int, header: String? = nil, footer: String? = nil) {
            self.header = header
            self.footer = footer
            
            for _ in 0..<rows {
                self.rows.append(Row())
            }
        }
    }
    
    class Row {
        typealias SelectedAction = () -> ()
        var contentView: UIView?
        var isHidden: Bool
        var onSelected: SelectedAction?
        
        init(contentView: UIView? = nil, isHidden: Bool = false, isSelected: SelectedAction? = nil) {
            self.contentView = contentView
            self.onSelected = isSelected
            self.isHidden = isHidden
        }
    }
}

extension List where Element == PolyItem {
    func append(_ item: Item) {
        let polyItem = PolyItem()
        switch item.type {
        case .folder:
            polyItem.folder = item as? Folder
        case .myRssFeed:
            polyItem.myRssFeed = item as? MyRSSFeed
        case .myRssItem:
            polyItem.myRssItem = item as? MyRSSItem
        }
        
        self.append(polyItem)
    }
}

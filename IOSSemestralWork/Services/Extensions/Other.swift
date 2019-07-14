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

extension UserDefaults {
    /**
     This enum stores all the keys that are used in the UserDefaults.
     */
    enum Keys: String {
        case lastUpdate
        case rootFolderItemId
    }
}

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

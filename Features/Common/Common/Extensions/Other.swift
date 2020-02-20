//
//  Extensions.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 05/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import UIKit

extension UserDefaults {
    /**
     This enum stores all the keys that are used in the UserDefaults.
     */
    public enum Keys: String {
        case lastUpdate
        case rootFolderItemId
    }
}

extension UIView {
    public func addSubViews(_ subViews: UIView...) -> UIView {
        for subView in subViews {
            self.addSubview(subView)
        }
        
        return self
    }
}

extension UITableView {
    public class Section {
        public var rows: [Row] = []
        public var header: String?
        public var footer: String?
        
        public init(rows: Int, header: String? = nil, footer: String? = nil) {
            self.header = header
            self.footer = footer
            
            for _ in 0..<rows {
                self.rows.append(Row())
            }
        }
    }
    
    public class Row {
        public typealias SelectedAction = () -> ()
        public var contentView: UIView?
        public var isHidden: Bool
        public var onSelected: SelectedAction?
        
        public init(contentView: UIView? = nil, isHidden: Bool = false, isSelected: SelectedAction? = nil) {
            self.contentView = contentView
            self.onSelected = isSelected
            self.isHidden = isHidden
        }
    }
}

extension Bundle {
    /**
     A resources bundle used by this application.
     */
    public static let resources: Bundle = {
        guard let bundle = Bundle(identifier: "cz.budikpet.IOSSemestralWork.Resources") else {
            fatalError("Resources bundle must exist.")
        }
        
        return bundle
    }()
}

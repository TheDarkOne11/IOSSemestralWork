//
//  RSSItemVM.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 14/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift

protocol IRSSItemVM {
    var selectedItem: MutableProperty<MyRSSItem> { get }
    
}

final class RSSItemVM: BaseViewModel, IRSSItemVM {
    typealias Dependencies = HasRepository & HasDBHandler & HasRealm & HasRootFolder & HasUserDefaults
    private let dependencies: Dependencies!
    
    let selectedItem: MutableProperty<MyRSSItem>
    
    private let specialItems: [SpecialItem] = []
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        
        if let selectedItem = dependencies.repository.selectedItem.value as? MyRSSItem {
            self.selectedItem = MutableProperty<MyRSSItem>(selectedItem)
        } else {
            fatalError("Selected item must be a RSSItem")
        }
        
        super.init()
    }
}

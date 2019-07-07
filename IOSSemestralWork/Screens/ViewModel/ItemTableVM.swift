//
//  ItemTableVM.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 07/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift

protocol IItemTableVM {
    var selectedItem: MutableProperty<Item> { get }
    
    func remove(_ polyItem: PolyItem)
}

final class ItemTableVM: BaseViewModel, IItemTableVM {
    typealias Dependencies = HasRepository & HasDBHandler & HasRealm
    private let dependencies: Dependencies!
    
    let selectedItem: MutableProperty<Item>
    let items: MutableProperty<[Item]>
    let specialItems: [SpecialItem] = []
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        selectedItem = dependencies.repository.selectedItem
        items = MutableProperty<[Item]>([dependencies.repository.selectedItem.value])   //TODO: Nějak využít pro získání itemů
    }
    
    func remove(_ polyItem: PolyItem) {
        dependencies.dbHandler.remove(polyItem)
    }
    
    private func getItems() -> [Item] {
        // FIXME: Get items from selected item and add special folders
        return []
    }
}

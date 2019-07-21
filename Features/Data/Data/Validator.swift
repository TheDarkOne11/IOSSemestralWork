//
//  Validator.swift
//  Data
//
//  Created by Petr Budík on 21/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation

public class TitleValidator {
    
    public init() {
    }
    
    public func validate(_ title: String) -> Bool {
        let textCount = title.trimmingCharacters(in: .whitespacesAndNewlines).count
        
        return textCount > 0
    }
}

public class ItemCreateableValidator {
    public typealias Dependencies = HasRepository
    private let dependencies: Dependencies
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    public func validate(newItem: Item, itemForUpdate: Item? = nil) -> Bool {
        let hasDuplicate = dependencies.repository.exists(newItem)
        
        return hasDuplicate == nil || hasDuplicate?.itemId == itemForUpdate?.itemId
    }
}

//
//  FolderEditVM.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 20/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift
import Data
import Common

protocol IFolderEditVM {
    typealias CreateFolderInput = (String, Folder?)
    var folderName: MutableProperty<String> { get }
    var folderForUpdate: MutableProperty<Folder?> { get }
    
    var createFolderAction: Action<CreateFolderInput, Folder, RSSFeedCreationError> { get }
    var canCreateFolderSignal: SignalProducer<Bool, Never> { get }
}

class FolderEditVM: BaseViewModel, IFolderEditVM {
    typealias Dependencies = HasRepository
    private let dependencies: Dependencies
    
    let folderName = MutableProperty<String>("")
    let folderForUpdate = MutableProperty<Folder?>(nil)
    
    lazy var canCreateFolderSignal: SignalProducer<Bool, Never> = {
        return folderName.producer.map({ [weak self] currTitle -> Bool in
            return self?.canCreate(folder: Folder(withTitle: currTitle)) ?? false
        })
    }()
    
    init(dependencies: Dependencies, folderForUpdate: Folder? = nil) {
        self.dependencies = dependencies
        
        if let folderForUpdate = folderForUpdate {
            folderName.value = folderForUpdate.title
            self.folderForUpdate.value = folderForUpdate
        }
    }
    
    lazy var createFolderAction = Action<CreateFolderInput, Folder, RSSFeedCreationError> { [unowned self] (title, parentFolder) in
        let parentFolder: Folder = parentFolder != nil ? parentFolder! : self.dependencies.repository.rootFolder
        return self.dependencies.repository.create(newFolder: Folder(withTitle: title), parentFolder: parentFolder)
    }
    
    private func canCreate(folder: Folder) -> Bool {
        let textCount = folder.title.trimmingCharacters(in: .whitespacesAndNewlines).count
        
        let duplicate = dependencies.repository.exists(folder)
        
        return textCount > 0 && (duplicate == nil || duplicate?.itemId == self.folderForUpdate.value?.itemId)
    }
}

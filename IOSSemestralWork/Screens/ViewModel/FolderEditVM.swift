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
    
    var createFolderAction: Action<CreateFolderInput, Folder, RealmObjectError> { get }
    var canCreateFolderSignal: SignalProducer<RealmObjectError?, Never> { get }
}

class FolderEditVM: BaseViewModel, IFolderEditVM {
    typealias Dependencies = HasRepository
    private let dependencies: Dependencies
    
    let folderName = MutableProperty<String>("")
    let folderForUpdate = MutableProperty<Folder?>(nil)
    
    lazy var canCreateFolderSignal: SignalProducer<RealmObjectError?, Never> = {
        return folderName.producer.map({ [weak self] currTitle -> RealmObjectError? in
            guard let self = self else { return .unknown }
            
            let isItemCreateable = ItemCreateableValidator(dependencies: self.dependencies).validate(newItem: Folder(withTitle: currTitle), itemForUpdate: self.folderForUpdate.value)
            let titleValid = TitleValidator().validate(currTitle)
            
            if !titleValid {
                return .titleInvalid
            } else if !isItemCreateable {
                return .exists
            } else {
                return nil
            }
        })
    }()
    
    init(dependencies: Dependencies, folderForUpdate: Folder? = nil) {
        self.dependencies = dependencies
        
        if let folderForUpdate = folderForUpdate {
            folderName.value = folderForUpdate.title
            self.folderForUpdate.value = folderForUpdate
        }
    }
    
    lazy var createFolderAction = Action<CreateFolderInput, Folder, RealmObjectError> { [unowned self] (title, parentFolder) in
        let parentFolder: Folder = parentFolder != nil ? parentFolder! : self.dependencies.repository.rootFolder
        let newFolder = Folder(withTitle: title)
        
        if let folderForUpdate = self.folderForUpdate.value {
            return self.dependencies.repository.update(selectedFolder: folderForUpdate, with: newFolder, parentFolder: parentFolder)
        } else {
            return self.dependencies.repository.create(newFolder: newFolder, parentFolder: parentFolder)
        }
    }
}

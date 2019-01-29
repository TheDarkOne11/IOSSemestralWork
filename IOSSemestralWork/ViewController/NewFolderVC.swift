//
//  NewFolderVC.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 20/01/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import UIKit

protocol NewFolderDelegate {
    func folderCreated()
}

/**
 Displays the View used for creating new folders.
 */
class NewFolderVC: UITableViewController {
    @IBOutlet weak var folderNameLabel: UITextField!
    
    var delegate: NewFolderDelegate!
    
    let dbHandler = DBHandler()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        folderNameLabel.becomeFirstResponder()
    }
    
    /**
     When a user confirms the name (clicks enter), a new folder is created and added to Realm database.
     */
    @IBAction func createFolder(_ sender: UITextField) {
        let title = sender.text!
        dbHandler.create(Folder(with: title, isContentsViewable: true))
        delegate.folderCreated()
        
        self.navigationController?.popViewController(animated: true)
    }
}

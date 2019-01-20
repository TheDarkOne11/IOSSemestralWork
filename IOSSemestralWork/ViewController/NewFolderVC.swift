//
//  NewFolderVC.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 20/01/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import UIKit
import RealmSwift

protocol NewFolderDelegate {
    func createFolder(with title: String)
}

class NewFolderVC: UITableViewController {
    @IBOutlet weak var folderName: UITextField!
    
    var delegate: NewFolderDelegate!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        folderName.becomeFirstResponder()
    }
    
    /**
     When a user confirms the name (clicks enter), a new folder is created and added to Realm database.
     */
    @IBAction func createFolder(_ sender: UITextField) {
        let title = sender.text!
        delegate.createFolder(with: title)
        
        self.navigationController?.popViewController(animated: true)
    }
}

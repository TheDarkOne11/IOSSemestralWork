//
//  NewFeedViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import RealmSwift

/**
 Displays the View used for creating new feeds.
 */
class NewFeedVC: UITableViewController {
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var pickerTableViewCell: UITableViewCell!
    @IBOutlet weak var folderNameLabel: UILabel!
    
    let realm = try! Realm()
    
    var folders: Results<Folder>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        
        // Loads all folders from Realm, updates on changes.
        folders = realm.objects(Folder.self)
        
        if let folders = self.folders {
            if folders.isEmpty {
                createFolder(with: "None")
            }

            folderNameLabel.text = folders.first?.title
        }
    }
    
    // MARK: NavBar items

    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {
        // TODO: Save feed, fetch its items
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: TableView methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Create expandable tableView instead of this?
        
        if indexPath.row == 1 && indexPath.section == 1 {
            // Show/ Hide picker view
            pickerTableViewCell.isHidden = !pickerTableViewCell.isHidden
            folderNameLabel.textColor = pickerTableViewCell.isHidden == true ? UIColor.black : UIColor.red
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: UIPickerView methods

extension NewFeedVC: UIPickerViewDelegate, UIPickerViewDataSource {
    /**
     Number of columns.
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     Number of rows.
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return folders?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return folders?[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let selectedFolder = folders?[row] {
            folderNameLabel.text = selectedFolder.title
        }
    }
}

// MARK: NewFolderDelegate

extension NewFeedVC: NewFolderDelegate {
    // TODO: Could this be done automatically when Realm updates the datasource?
    func createFolder(with title: String) {
        // Save the folder to Realm
        do {
            try realm.write {
                let folder = Folder(with: title, isContentsViewable: true)
                
                realm.add(folder)
            }
        } catch {
            print("Could not add a new folder to Realm: \(error)")
        }
        
        picker.reloadAllComponents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            print("Unreacheable tableViewCell selected.")
            fatalError()
        }
        
        if segue.identifier == "ShowCreateNewFolder" {
            let destinationVC = segue.destination as! NewFolderVC
            destinationVC.delegate = self
        }
    }
}

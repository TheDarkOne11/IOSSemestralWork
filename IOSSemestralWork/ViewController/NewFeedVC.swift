//
//  NewFeedViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit

class NewFeedVC: UITableViewController {
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var pickerTableViewCell: UITableViewCell!
    @IBOutlet weak var folderNameLabel: UILabel!
    
    var folders = [Folder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        
        for i in 1...10 {
            folders.append(Folder(with: "Folder\(i)"))
        }
        
        folderNameLabel.text = folders.first?.title
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
        
        if indexPath.row == 0 && indexPath.section == 1 {
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
        return folders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return folders[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedFolder = folders[row]
        
        folderNameLabel.text = selectedFolder.title
    }
}

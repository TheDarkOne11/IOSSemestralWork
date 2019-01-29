//
//  NewFeedViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import RealmSwift

protocol NewFeedDelegate {
    
    /**
     Validates the given RSS feed link address. The feed is then persisted in Realm.b
     */
    func feedCreated(feed myRssFeed: MyRSSFeed)
}

/**
 Displays the View used for creating new feeds.
 */
class NewFeedVC: UITableViewController {
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var pickerTableViewCell: UITableViewCell!
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var feedNameLabel: UITextField!
    @IBOutlet weak var feedLinkLabel: UITextField!
    
    let realm = try! Realm()
    
    let dbHandler = DBHandler()
    
    var delegate: NewFeedDelegate!
    
    var folders: Results<Folder>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        
        // Loads all folders from Realm, updates on changes.
        folders = realm.objects(Folder.self)
        
        // There is always at least 1 folder
        folderNameLabel.text = folders!.first?.title
    }
    
    // MARK: NavBar items

    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {        
        var link = feedLinkLabel.text!
        
        if !link.starts(with: "http://") && !link.starts(with: "https://") {
            link = "http://" + link
        }
        
        var title = feedNameLabel.text!
        if title == "" {
            title = link
        }
        let myRssFeed = MyRSSFeed(with: title, link: link)
        
        // Save the new feed to the selected folder
        
        let selectedFolder = folders![picker.selectedRow(inComponent: 0)]
        
        // Save the new feed to the selected folder in Realm
        dbHandler.create(myRssFeed, in: selectedFolder)
        
        delegate.feedCreated(feed: myRssFeed)
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: TableView methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    func folderCreated() {
        picker.reloadAllComponents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCreateNewFolder" {
            let destinationVC = segue.destination as! NewFolderVC
            destinationVC.delegate = self
        }
    }
}

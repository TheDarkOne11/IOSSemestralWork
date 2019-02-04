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
     Validates the given RSS feed link address. The feed is then persisted in Realm.
     */
    func feedCreated(feed myRssFeed: MyRSSFeed)
}

/**
 Displays the View used for creating new feeds.
 */
class RSSFeedEditVC: UITableViewController {
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var pickerTableViewCell: UITableViewCell!
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var feedNameLabel: UITextField!
    @IBOutlet weak var feedLinkLabel: UITextField!
    
    let realm = try! Realm()
    let dbHandler = DBHandler()
    var delegate: NewFeedDelegate!
    
    /**
     If it's nil then new feed is created. If it isn't nil then this feed is updated.
     */
    var feedForUpdate: MyRSSFeed?
    var folders: Results<Folder>?
    lazy var noneFolder: Folder = {
        guard let folder = realm.objects(Folder.self).filter("title == %@", UserDefaultsKeys.NoneFolderTitle.rawValue).first else {
            fatalError("The special \(UserDefaultsKeys.NoneFolderTitle.rawValue) folder has to exist.")
        }
        
        return folder
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        
        // Loads all folders from Realm, updates on changes.
        folders = realm.objects(Folder.self).filter("title != %@", UserDefaultsKeys.NoneFolderTitle.rawValue).sorted(byKeyPath: "title")
        
        if let feed = feedForUpdate {
            // Prepopulate all components of the screen
            feedNameLabel.text = feed.title
            feedLinkLabel.text = feed.link
            selectPickerRow(for: feed.folder!)
        } else {
            // There is always at least 1 folder
            selectPickerRow(for: noneFolder)
        }
    }
    
    /**
     Returns folder at the selected index.
     */
    private func getFolder(at index: Int) -> Folder {
        var folder = noneFolder
        
        if index == 0 {
            folder = noneFolder
        } else if index >= 1 && index <= folders!.count + 1 {
            folder = folders![index - 1]
        } else {
            fatalError("Index \(index) out of bounds.")
        }
        
        return folder
    }
    
    // MARK: NavBar items

    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {        
        var link = feedLinkLabel.text!
        
        
        if let duplicateFeed = realm.objects(MyRSSFeed.self).filter("link CONTAINS[cd] %@", link).first {
            // Feed with the same link already exists in Realm
            presentDuplicateFeedAlert(duplicateFeed.title)
            return
        }
        
        if !link.starts(with: "http://") && !link.starts(with: "https://") {
            link = "http://" + link
        }
        
        var title = feedNameLabel.text!
        if title == "" {
            title = link
        }
        let selectedFolder = getFolder(at: picker.selectedRow(inComponent: 0))
        
        var myRssFeed = feedForUpdate
        
        if let myRssFeed = myRssFeed {
            // Update the feed
            dbHandler.realmEdit(errorMsg: "Error occured when updating the RSSFeed") {
                let oldFolder: Folder = myRssFeed.folder!
                let index: Int = oldFolder.myRssFeeds.index(of: myRssFeed)!
                
                myRssFeed.title = title
                myRssFeed.link = link
                
                // Change folders
                oldFolder.myRssFeeds.remove(at: index)
                myRssFeed.folder = selectedFolder
                selectedFolder.myRssFeeds.append(myRssFeed)
            }
        } else {
            // Save the new feed
            myRssFeed = MyRSSFeed(title: title, link: link, folder: selectedFolder)
            dbHandler.create(myRssFeed!)
        }
        
        delegate.feedCreated(feed: myRssFeed!)
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: TableView methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                // New folder alert
                presentCreateFolderAlert()
            } else if indexPath.row == 1 {
                // Show/ Hide picker view
                pickerTableViewCell.isHidden = !pickerTableViewCell.isHidden
                folderNameLabel.textColor = pickerTableViewCell.isHidden == true ? UIColor.black : UIColor.red
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Alerts
    
    /**
     Creates and presents an alert used for creating a new folder.
     */
    private func presentCreateFolderAlert() {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Create folder", message: "", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        let actionDone = UIAlertAction(title: "Done", style: .default) { (action) in
            let folder = Folder(with: textField.text!)
            self.dbHandler.create(folder)
            
            self.picker.reloadAllComponents()
            self.selectPickerRow(for: folder)
        }
        actionDone.isEnabled = false
        
        alert.addAction(actionDone)
        alert.addAction(actionCancel)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Folder name"
            alertTextField.enablesReturnKeyAutomatically = true
            
            textField = alertTextField
        }
        
        // Check for textField changes. Done button is enabled only when the textField isn't empty
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { _ in
            // Enables and disables Done action. Triggered when value of textField changes
            let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
            actionDone.isEnabled = textCount > 0
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    /**
     Creates and presents an alert warning a user that a feed with the same link exists.
     */
    private func presentDuplicateFeedAlert(_ feedTitle: String) {
        let msg = "Feed with this link already exists. \nIts title is \"\(feedTitle)\". \nPlease use a different link."
        
        let alert = UIAlertController(title: "Duplicate RSS feed detected", message: msg, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.feedLinkLabel.becomeFirstResponder()
        }
        alert.addAction(actionCancel)
        
        present(alert, animated: true)
    }
    
}

// MARK: UIPickerView methods

extension RSSFeedEditVC: UIPickerViewDelegate, UIPickerViewDataSource {
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
        if let folders = self.folders {
            return folders.count + 1
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return getFolder(at: row).title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        folderNameLabel.text = getFolder(at: row).title
    }
    
    /**
     Selects the folder in the pickerView.
     */
    func selectPickerRow(for folder: Folder) {
        folderNameLabel.text = folder.title
        
        if folder.title == noneFolder.title {
            picker.selectRow(0, inComponent: 0, animated: false)
        } else {
            guard let index = folders?.index(of: folder) else {
                fatalError("The selected folder has to exist in Realm.")
            }
            
            picker.selectRow(index + 1, inComponent: 0, animated: false)
        }
    }
}

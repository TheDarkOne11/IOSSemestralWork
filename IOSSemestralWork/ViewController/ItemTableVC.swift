//
//  ItemTableViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import RealmSwift
import Toast_Swift

class ItemTableVC: UITableViewController {
    /** All shown folders in the current tableView. */
    var folders: Results<Folder>?
    // All feeds that aren't inside a folder and are supposed to be shown
    var feeds: List<MyRSSFeed>?
    let specialFoldersCount = 3
    
    let realm = try! Realm()
    let dbHandler = DBHandler()
    let defaults = UserDefaults.standard
    
    lazy var refresher = RefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if LastUpdate Date exists
        if defaults.object(forKey: UserDefaultsKeys.LastUpdate.rawValue) == nil {
            defaults.set(NSDate(), forKey: UserDefaultsKeys.LastUpdate.rawValue)
        }
        
        // Initialize PullToRefresh
        tableView.refreshControl = refresher
        refresher.delegate = self
        
        // Set default Toast values
        ToastManager.shared.duration = 4.0
        ToastManager.shared.position = .center
        ToastManager.shared.style.backgroundColor = UIColor.black.withAlphaComponent(0.71)
    }
    
    // MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        // Check for special folders
        if (indexPath.row < specialFoldersCount) {
            switch(indexPath.row) {
            case 0:
                // All items
                cell.textLabel?.text = "All items" + " (Special)"
                break
            case 1:
                // Unread items
                cell.textLabel?.text = "Unread items" + " (Special)"
                break
            case 2:
                // Starred items
                cell.textLabel?.text = "Starred items" + " (Special)"
                break
            default:
                // Not one of the special folders
                break
            }
            
            return cell
        }
        
        // First show custom folders then RSS feeds without folder
        let foldersCount = folders?.count ?? 0
        if indexPath.row < foldersCount + specialFoldersCount {
            // Show folder
            guard let folder = folders?[indexPath.row - specialFoldersCount] else {
                print("Error when loading folders to display in the tableView")
                fatalError()
            }
            
            cell.textLabel?.text = folder.title + " (Folder)"
        } else {
            // Show RSSFeed
            guard let feed = feeds?[indexPath.row - foldersCount - specialFoldersCount] else {
                print("Error when loading feeds to display in the tableView")
                fatalError()
            }
            
            cell.textLabel?.text = feed.title + " (MyRSSFeed)"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let feedsCount = feeds?.count ?? 0
        let foldersCount = folders?.count ?? 0
        
        return specialFoldersCount + feedsCount + foldersCount
    }
    
    // MARK: - TableView methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row < specialFoldersCount) {
            var items: Results<MyRSSItem>
            
            switch(indexPath.row) {
            case 0:
                // All items
                items = realm.objects(MyRSSItem.self)
                performSegue(withIdentifier: "ShowRssItems", sender: SeguePreparationSender(rssItems: items, title: "All items"))
                break
            case 1:
                // Unread items
                // TODO: Create
                items = realm.objects(MyRSSItem.self)
                performSegue(withIdentifier: "ShowRssItems", sender: SeguePreparationSender(rssItems: items, title: "Unread items"))
                break
            case 2:
                // Starred items
                // TODO: Create
                items = realm.objects(MyRSSItem.self)
                performSegue(withIdentifier: "ShowRssItems", sender: SeguePreparationSender(rssItems: items, title: "Starred items"))
                break
            default:
                return
            }
            
            return
        }
        
        // TODO: Go to the folder's contents only when an edge of the cell is selected, otherwise show RSSItems of its feeds
        let foldersCount = folders?.count ?? 0
        
        if indexPath.row < foldersCount + specialFoldersCount {
            // Go to FolderTableVC
            // TODO: Maybe do the same for folder we did for RSSItems
            performSegue(withIdentifier: "ShowFolderContents", sender: nil)
            return
        }
        
        if let feeds = self.feeds {
            // Go to RSSFeedTableVC
            let currFeed = feeds[indexPath.row - foldersCount - specialFoldersCount]
            
            // Change rssItems from List to Results
            let sender = SeguePreparationSender(rssItems: currFeed.myRssItems.filter("TRUEPREDICATE"), title: currFeed.title)
            
            performSegue(withIdentifier: "ShowRssItems", sender: sender)
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAddFeed" {
            // Add feed button pressed
            let destinationVC = (segue.destination as! UINavigationController).topViewController as! RSSFeedEditVC
            destinationVC.delegate = self
            
            if let feed = sender as? MyRSSFeed {
                destinationVC.feedForUpdate = feed
            }
            
            return
        }
        
        if segue.identifier == "ShowRssItems" {
            // Show RSSFeed
            guard let currSender = sender as? SeguePreparationSender<MyRSSItem> else {
                print("Did not get data")
                fatalError()
            }
            
            let destinationVC = segue.destination as! RSSFeedTableVC
            destinationVC.myRssItems = currSender.rssItems
            destinationVC.title = currSender.title
            return
        }
        
        guard let indexPath = tableView.indexPathForSelectedRow else {
            print("Unreacheable tableViewCell selected.")
            fatalError()
        }
        
        if segue.identifier ==  "ShowFolderContents" {
            // Show folder
            if let folder = folders?[indexPath.row - specialFoldersCount] {
                let destinationVC = segue.destination as! FolderTableVC
                destinationVC.selectedFolder = folder
            }
        }
    }
}

// MARK: TableView cells editing and removing

extension ItemTableVC {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row >= specialFoldersCount
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeAction = UITableViewRowAction(style: .destructive, title: "Remove") { (action, indexPath) in
            print("Remove clicked at row \(indexPath.row)")
            self.removeItem(at: indexPath)
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            print("Edit clicked at row \(indexPath.row)")
            self.editItem(at: indexPath)
        }
        
        return [removeAction, editAction]
    }
    
    func editItem(at indexPath: IndexPath) {
        let foldersCount = folders?.count ?? 0
        
        if indexPath.row < foldersCount + specialFoldersCount {
            // Go to folder edit screen
            guard let folder = folders?[indexPath.row - specialFoldersCount] else {
                print("The folder which is to be removed should exist")
                fatalError()
            }
            
            presentEditAlert(folder)
            
        } else {
            // Go to feed edit screen
            guard let feed = feeds?[indexPath.row - foldersCount - specialFoldersCount] else {
                print("The feed which is to be removed should exist")
                fatalError()
            }
            
            performSegue(withIdentifier: "ShowAddFeed", sender: feed)
        }
    }
    
    /**
     Creates and presents an alert used for editing the selected folder.
     */
    func presentEditAlert(_ folder: Folder) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Edit folder", message: "", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        let actionDone = UIAlertAction(title: "Done", style: .default) { (action) in
            do {
                try self.realm.write {
                    folder.title = textField.text!
                }
            } catch {
                print("Error occured when editing a folder: \(error)")
            }
            self.tableView.reloadData()
        }
        
        alert.addAction(actionDone)
        alert.addAction(actionCancel)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Folder name"
            alertTextField.text = folder.title
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
    
    func removeItem(at indexPath: IndexPath) {
        let foldersCount = folders?.count ?? 0
        
        if indexPath.row < foldersCount + specialFoldersCount {
            // Remove folder and all its contents
            guard let folder = folders?[indexPath.row - specialFoldersCount] else {
                print("The folder which is to be removed should exist")
                fatalError()
            }
            
            dbHandler.remove(folder)
        } else {
            // Remove feed
            guard let feed = feeds?[indexPath.row - foldersCount - specialFoldersCount] else {
                print("The feed which is to be removed should exist")
                fatalError()
            }
            
            dbHandler.remove(feed)
        }
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: RefreshControlDelegate

extension ItemTableVC: RefreshControlDelegate {
    
    /**
     Checks beginning of the pull to refresh and updates its label.
     */
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset: CGFloat = 0
        if let frame = self.navigationController?.navigationBar.frame {
            offset = frame.minY + frame.size.height
        }
        
        if (-scrollView.contentOffset.y  == offset) {
            refresher.refreshView.updateLabelText()
        }
    }
    
    func update() {
        print("requesting data")
        
        let refreshView: PullToRefreshView! = refresher.refreshView
                        
        refreshView.startUpdating()
        dbHandler.updateAll() { success in
            
            // Hiding of the RefreshView is delayed to at least 0.5 s
            let deadline = DispatchTime.now() + .milliseconds(500)
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                print("End refreshing")
                refreshView.stopUpdating()
                self.refresher.endRefreshing()
                
                if success == DownloadStatus.Unreachable {
                    // Internet is unreachable
                    print("Internet is unreachable")
                    self.view.makeToast("Internet is unreachable. Please try updating later.")
                    
                } else {
                    self.defaults.set(NSDate(), forKey: UserDefaultsKeys.LastUpdate.rawValue)
                }
                
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: NewFeedDelegate

extension ItemTableVC: NewFeedDelegate {
    func feedCreated(feed myRssFeed: MyRSSFeed) {
        // Validate the address by running update of the feed
        dbHandler.update(myRssFeed) { (success) in
            self.tableView.reloadData()
            
            switch success {
                
            case .OK:
                break
            case .NotOK:
                print("Feed \(myRssFeed.title) probably has a wrong link")
                
                self.view.makeToast("Could not download any RSS items. \nPlease check the RSS feed link you provided.")
                do {
                    try self.realm.write {
                        myRssFeed.isOk = false
                    }
                } catch {
                    print("Error occured when setting rssFeed.isOk to false: \(error)")
                }
                break
            case .Unreachable:
                print("Internet is unreachable. Please try updating later.")
                
                self.view.makeToast("Internet is unreachable. Please try updating later.")
                break
            }
        }
    }
    
}

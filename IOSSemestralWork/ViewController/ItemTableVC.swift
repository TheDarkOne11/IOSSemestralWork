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
    var folders: Results<PolyItem>?
    // All feeds that aren't inside a folder and are supposed to be shown
    var feeds: Results<PolyItem>?
    let specialFoldersCount = 3
    
    let realm = try! Realm()
    let dbHandler = DBHandler()
    let defaults = UserDefaults.standard
    
    lazy var refresher = RefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        
        // Initialize PullToRefresh
        tableView.refreshControl = refresher
        refresher.delegate = self
        
        // Set default Toast values
        ToastManager.shared.duration = 4.0
        ToastManager.shared.position = .center
        ToastManager.shared.style.backgroundColor = UIColor.black.withAlphaComponent(0.71)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
        
    // MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        var items = allRssItems()
        
        // Check for special folders
        if (indexPath.row < specialFoldersCount) {
            switch(indexPath.row) {
            case 0:
                // All items
                cell.setData(title: "All items", imgName: "all", itemCount: items.count)
                break
            case 1:
                // Unread items
                items = items.filter("isRead == false")
                cell.setData(title: "Unread items", imgName: "unread", itemCount: items.count)
                break
            case 2:
                // Starred items
                items = items.filter("isStarred == true")
                cell.setData(title: "Starred items", imgName: "star", itemCount: items.count)
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
                fatalError("Error when loading folders to display in the tableView")
            }
            
            cell.setData(using: folder.folder!)
        } else {
            // Show RSSFeed
            guard let feed = feeds?[indexPath.row - foldersCount - specialFoldersCount] else {
                fatalError("Error when loading feeds to display in the tableView")
            }
            
           cell.setData(using: feed.myRssFeed!)
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
            var items: Results<MyRSSItem> = allRssItems()
            
            switch(indexPath.row) {
            case 0:
                // All items
                performSegue(withIdentifier: "ShowRssItems", sender: SeguePreparationSender(rssItems: items, title: "All items"))
                break
            case 1:
                // Unread items
                items = items.filter("isRead == false")
                performSegue(withIdentifier: "ShowRssItems", sender: SeguePreparationSender(rssItems: items, title: "Unread items"))
                break
            case 2:
                // Starred items
                items = items.filter("isStarred == true")
                performSegue(withIdentifier: "ShowRssItems", sender: SeguePreparationSender(rssItems: items, title: "Starred items"))
                break
            default:
                return
            }
            
            return
        }
        
        let foldersCount = folders?.count ?? 0
        
        if indexPath.row < foldersCount + specialFoldersCount {
            // Go to FolderTableVC
            performSegue(withIdentifier: "ShowFolderContents", sender: nil)
            return
        }
        
        if let feeds = self.feeds {
            // Go to RSSFeedTableVC
            let currFeed = feeds[indexPath.row - foldersCount - specialFoldersCount]
            
            // Change rssItems from List to Results
            let sender = SeguePreparationSender(rssItems: currFeed.myRssFeed!.myRssItems.sorted(byKeyPath: "date", ascending: false), title: currFeed.myRssFeed!.title)
            
            performSegue(withIdentifier: "ShowRssItems", sender: sender)
        }
    }
    
    /**
     Returns a collection of all RSSItems. Used when displaying RSSItems of a selected RSS feed or all items of a particular folder.
     */
    func allRssItems() -> Results<MyRSSItem> {
        return realm.objects(MyRSSItem.self).sorted(byKeyPath: "date", ascending: false)
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
                fatalError("Did not get data through the sender variable.")
            }
            
            let destinationVC = segue.destination as! RSSFeedTableVC
            destinationVC.myRssItems = currSender.rssItems
            destinationVC.title = currSender.title
            return
        }
        
        guard let indexPath = tableView.indexPathForSelectedRow else {
            fatalError("Unreacheable tableViewCell selected.")
        }
        
        if segue.identifier ==  "ShowFolderContents" {
            // Show folder
            if let folder = folders?[indexPath.row - specialFoldersCount] {
                let destinationVC = segue.destination as! FolderTableVC
                destinationVC.selectedFolder = folder.folder!
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
            self.removeItem(at: indexPath)
            self.tableView.reloadData()
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.editItem(at: indexPath)
            self.tableView.reloadData()
        }
        
        return [removeAction, editAction]
    }
    
    /**
     According to the selected cell we move a user to the screens where he can edit Folders or RSS feeds.
     - parameter indexPath: The location of the cell (Folder or RSS feed) we want to edit.
     */
    private func editItem(at indexPath: IndexPath) {
        let foldersCount = folders?.count ?? 0
        
        if indexPath.row < foldersCount + specialFoldersCount {
            // Go to folder edit screen
            guard let folder = folders?[indexPath.row - specialFoldersCount] else {
                fatalError("The folder which is to be removed should exist")
            }
            
            presentEditAlert(folder.folder!)
            
        } else {
            // Go to feed edit screen
            guard let feed = feeds?[indexPath.row - foldersCount - specialFoldersCount] else {
                fatalError("The feed which is to be removed should exist")
            }
            
            performSegue(withIdentifier: "ShowAddFeed", sender: feed)
        }
    }
    
    /**
     Creates and presents an alert used for editing the selected folder.
     
     - parameter folder: The selected folder.
     */
    private func presentEditAlert(_ folder: Folder) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Edit folder", message: "", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        let actionDone = UIAlertAction(title: "Done", style: .default) { (action) in
            self.dbHandler.realmEdit(errorMsg: "Error occured when editing a folder", editCode: {
                folder.title = textField.text!
            })
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
    
    /**
     We remove the selected cell.
     - parameter indexPath: The location of the cell (Folder or RSS feed) we want to remove.
     */
    private func removeItem(at indexPath: IndexPath) {
        let foldersCount = folders?.count ?? 0
        
        if indexPath.row < foldersCount + specialFoldersCount {
            // Remove folder and all its contents
            guard let folder = folders?[indexPath.row - specialFoldersCount] else {
                fatalError("The folder which is to be removed should exist")
            }
            
            dbHandler.remove(folder)
        } else {
            // Remove feed
            guard let feed = feeds?[indexPath.row - foldersCount - specialFoldersCount] else {
                fatalError("The feed which is to be removed should exist")
            }
            
            dbHandler.remove(feed)
        }
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: RefreshControlDelegate

extension ItemTableVC: RefreshControlDelegate {
    
    /**
     Checks beginning of the PullToRefresh and updates its label.
     */
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset: CGFloat = 0
        if let frame = self.navigationController?.navigationBar.frame {
            offset = frame.minY + frame.size.height
        }
        
        if (-scrollView.contentOffset.y >= offset ) {
            refresher.refreshView.updateLabelText()
        }
    }
    
    func update() {
        print("requesting data")
        
        let refreshView: PullToRefreshView! = refresher.refreshView
                        
        refreshView.startUpdating()
        dbHandler.updateAll() { status in
            
            // Hiding of the RefreshView is delayed to at least 0.5 s so that the updateLabel is visible.
            let deadline = DispatchTime.now() + .milliseconds(500)
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                print("End refreshing")
                refreshView.stopUpdating()
                self.refresher.endRefreshing()
                
                self.checkStatus(status)
                
                self.tableView.reloadData()
            }
        }
    }
    
    /**
     Checks status of the update.
     */
    private func checkStatus(_ status: DownloadStatus) {
        if status == DownloadStatus.Unreachable {
            // Internet is unreachable
            print("Internet is unreachable")
            self.view.makeToast("Internet is unreachable. Please try updating later.")
            
        } else {
            self.defaults.set(NSDate(), forKey: UserDefaultsKeys.LastUpdate.rawValue)
        }
    }
}

// MARK: NewFeedDelegate

extension ItemTableVC: NewFeedDelegate {
    func feedCreated(feed myRssFeed: MyRSSFeed) {
        // Validate the address by running update of the feed
        dbHandler.update(myRssFeed) { (result) in
            self.tableView.reloadData()
            
            // Check the result
            self.dbHandler.realmEdit(errorMsg: "Error occured when setting rssFeed.isOk", editCode: {
                self.checkResult(myRssFeed, result)
            })
        }
    }
    
    /**
     Checks result of the download of RSS items and shows it on screen.
     
     - parameter myRssFeed: The RSS feed we downloaded RSS items for.
     - parameter result: The end result of downloading RSS items.
     */
    private func checkResult(_ myRssFeed: MyRSSFeed, _ result: DownloadStatus) {
        switch result {
            
        case .OK:
            self.view.makeToast("RSS feed \"\(myRssFeed.title)\" created.")
            myRssFeed.isOk = true
            break
        case .NotOK:
            print("Feed \(myRssFeed.title) probably has a wrong link")
            
            self.view.makeToast("Could not download any RSS items. \nPlease check the RSS feed link you provided.")
            myRssFeed.isOk = false
            break
        case .Unreachable:
            print("Internet is unreachable. Please try updating later.")
            
            self.view.makeToast("Internet is unreachable. Please try updating later.")
            break
        }
    }
    
}

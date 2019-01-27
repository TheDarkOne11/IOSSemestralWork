//
//  ItemTableViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import RealmSwift

// TODO: Pokud má feed špatnou adresu (adresa není RSS feed nebo neexistuje), udělám u něj v tableView nějaký vizuální indikátor (červený trojúhelník), možná i u jeho folderu. Tuto informaci musím uložit ve feedu, možná i ve folderu. Vizuální indikátor nezobrazíme, pokud se nemůžeme připojit k internetu. To uděláme v update liště.
class ItemTableVC: UITableViewController {    
    // All feeds that aren't inside a folder and are supposed to be shown
    var feeds: List<MyRSSFeed>?
    let specialFoldersCount = 3
    
    let realm = try! Realm()
    let dbHandler = DBHandler()
    
    var testDate = NSDate()
    var refreshView: PullToRefreshView!
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .clear
        refreshControl.backgroundColor = .clear
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl = refresher
        
        if let objOfRefreshView = Bundle.main.loadNibNamed("PullToRefreshView", owner: self, options: nil)?.first as? PullToRefreshView {
            // Initializing the 'refreshView'
            refreshView = objOfRefreshView
            refreshView.updateLabelText(dateOfLastUpdate: testDate)
            // Giving the frame as per 'tableViewRefreshControl'
            refreshView.frame = refresher.frame
            // Adding the 'refreshView' to 'tableViewRefreshControl'
            refresher.addSubview(refreshView)
        }
    }
    
    @objc
    func requestData() {
        print("requesting data")
        
        // TODO: Temporary update code, remove!
//        dbHandler.updateAll()
        tableView.reloadData()
        
        let deadline = DispatchTime.now() + .milliseconds(500)
        refreshView.updateLabelText(dateOfLastUpdate: testDate)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    // MARK: - TableView helper methods
    
    /**
     This method is used to fill all cells of TableViews of ItemTableVC children in tableViewCellForRowAt methods.
     */
    func fill(cell: UITableViewCell, at row: Int) ->UITableViewCell? {
        
        // Check for special folders
        switch(row) {
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
            return nil
        }
        
        return cell
    }
    
    // MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds!.count + specialFoldersCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        guard let filledCell = fill(cell: cell, at: indexPath.row) else {
            print("Error occured at cellForRowAt.")
            fatalError()
        }
        
        return filledCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row >= 0 && indexPath.row < specialFoldersCount) {
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
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRssItems" {
            // Show RSSFeed
            guard let currSender = sender as? SeguePreparationSender<MyRSSItem> else {
                print("Did not get data")
                fatalError()
            }
            
            let destinationVC = segue.destination as! RSSFeedTableVC
            destinationVC.myRssItems = currSender.rssItems
            destinationVC.title = currSender.title
        }
    }
}

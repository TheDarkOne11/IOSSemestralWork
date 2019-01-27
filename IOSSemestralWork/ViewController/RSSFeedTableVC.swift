//
//  RSSFeedTableVC.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import RealmSwift

/**
 Displays all RssFeedItems of the selected feed or feeds.
 */
class RSSFeedTableVC: UITableViewController {
    var myRssItems: Results<MyRSSItem>?
    
    let dbHandler = DBHandler()
    let defaults = UserDefaults.standard
    
    lazy var refresher = RefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize PullToRefresh
        tableView.refreshControl = refresher
        refresher.delegate = self
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myRssItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RssItemCell", for: indexPath)
        let currRssItem = myRssItems?[indexPath.row]
        cell.textLabel?.text = currRssItem?.title
        
        return cell
    }
    
    // MARK: Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowRssItem", sender: nil)
        
    }
    
    // MARK: Navigation
    @IBAction func simpleSettingsPressed(_ sender: UIBarButtonItem) {
        // TODO: Implement
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            print("Unreacheable tableViewCell selected.")
            fatalError()
        }
        
        if segue.identifier == "ShowRssItem" {
            let destinationVC = segue.destination as! RSSItemVC
            
            destinationVC.title = title
            destinationVC.selectedRssItem = myRssItems?[indexPath.row]
        }
    }
}

extension RSSFeedTableVC: RefreshControlDelegate {
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
                
                if !success {
                    // Internet is unreachable
                    // TODO: Implement
                    print("Internet is unreachable")
                    self.view.makeToast("Internet is unreachable. Please try updating later.", duration: 3.0, position: .center)
                } else {
                    self.defaults.set(NSDate(), forKey: "LastUpdate")
                }
                
                self.tableView.reloadData()
            }
        }
    }
}

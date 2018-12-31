//
//  RSSFeedTableVC.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit

/**
 Displays all RssFeedItems of the selected feed or feeds.
 */
class RSSFeedTableVC: UITableViewController {
    var selectedFeed: MyRSSFeed? {
        didSet {
            title = selectedFeed!.title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedFeed?.myRssItems.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RssItemCell", for: indexPath)
        let currRssItem = selectedFeed?.myRssItems[indexPath.row]
        cell.textLabel?.text = currRssItem?.title
        
        return cell
    }
    
    // MARK: Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowRssItem", sender: nil)
        
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            print("Unreacheable tableViewCell selected.")
            fatalError()
        }
        
        if segue.identifier == "ShowRssItem" {
            let destinationVC = segue.destination as! RSSItemVC
            
            destinationVC.selectedRssItem = selectedFeed?.myRssItems[indexPath.row]
        }
    }
}

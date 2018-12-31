//
//  ItemTableViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit

class ItemTableVC: UITableViewController {
    var myItems = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item: Item = myItems[indexPath.row]
        
        switch item.type {
        case .folder:
            let currItem = item as! Folder
            cell.textLabel?.text = currItem.title + " (Folder)"
        case .myRssFeed:
            let currItem = item as! MyRSSFeed
            cell.textLabel?.text = currItem.title + " (MyRSSFeed)"
        case .myRssItem:
            let currItem = item as! MyRSSItem
            cell.textLabel?.text = currItem.title + " (MyRSSItem)"
        }
        
        return cell
    }

    // MARK: Data manipulation
    
    func loadData() {
        myItems.removeAll()
        myItems.append(Folder(with: "All Items"))
        myItems.append(Folder(with: "Starred Items"))
    }
}
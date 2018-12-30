//
//  ItemsTableViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireRSSParser

class MainTableVC: ItemTableVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        fetchData()
    }
    
    // MARK: Data manipulation
    
    func fetchData() {
        let url = "http://servis.idnes.cz/rss.aspx?c=zpravodaj"
        
        Alamofire.request(url).responseRSS() { (response) -> Void in
            if let feed: RSSFeed = response.result.value {
                //do something with your new RSSFeed object!
                for item in feed.items {
                    let myItem = MyRSSItem(with: item)
                    self.myItems.append(myItem)
                    
                    print(myItem.title)
                    print(myItem.link)
                    print(myItem.author)
                    print(myItem.itemDescription)
                    print("\n###############################################\n")
                }
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: TableView methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: Item = myItems[indexPath.row]
        
        switch item.type {
        case .folder:
            let currItem = item as! Folder
            
            performSegue(withIdentifier: "ShowFolderContents", sender: nil)
        case .myRssFeed:
            let currItem = item as! MyRSSFeed
            
            performSegue(withIdentifier: "ShowRssItems", sender: nil)
        case .myRssItem:
            // MyRssItems won't be visible on the main screen
            break
        }
        
    }
    
     // MARK: - Navigation
     
    /**
     Passes information to the destinationVC.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            print("IndexPath problem")
            return
        }
        
        let item = myItems[indexPath.row]
        
        switch item.type {
        case .folder:
            let folder = item as! Folder
            let destinationVC = segue.destination as! FolderTableVC
            
            destinationVC.selectedFolder = folder
        case .myRssFeed:
            let feed = item as! MyRSSFeed
            let destinationVC = segue.destination as! RSSFeedTableVC
            
            destinationVC.selectedFeed = feed
        case .myRssItem:
            // MyRssItems won't be visible on the main screen
            break
        }
        
        
    }
    
    // MARK: Data manipulation
    
    override func loadData() {
        super.loadData()
        var testFeed = MyRSSFeed(with: "Technika")
        testFeed.myRssItems.append(MyRSSItem(with: nil))
        
        let testFolder = Folder(with: "TestFolder", isContentsViewable: true)
        testFolder.myRssFeeds.append(testFeed)
        
        testFeed = MyRSSFeed(with: "Zpravodaj")
        testFeed.myRssItems.append(MyRSSItem(with: nil))
        
        myItems.append(testFolder)
        myItems.append(testFeed)
    }
}

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

class ItemsTableViewController: UITableViewController {
    var myItems = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myItems.append(Folder(with: "All Items"))
        myItems.append(Folder(with: "Starred Items"))
        myItems.append(Folder(with: "TestFolder", isContentsViewable: true))
        myItems.append(MyRSSFeed(with: "Zpravodaj"))
        
//        for i in 1...20 {
//            let myItem = MyRSSItem()
//            myItem.title = "Title\(i)"
//            myRssItems.append(myItem)
//        }
        
//        fetchData()
    }
    
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
            cell.textLabel?.text = currItem.title + "_Folder"
        case .myRssFeed:
            let currItem = item as! MyRSSFeed
            cell.textLabel?.text = currItem.title + "_MyRSSFeed"
        case .myRssItem:
            let currItem = item as! MyRSSItem
            cell.textLabel?.text = currItem.title + "_MyRSSItem"
        }
        
        return cell
    }
    
    // MARK: TableView methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: Item = myItems[indexPath.row]
        
        performSegue(withIdentifier: "ShowRssItems", sender: nil)
        
        switch item.type {
        case .folder:
            let currItem = item as! Folder
        case .myRssFeed:
            let currItem = item as! MyRSSFeed
        case .myRssItem:
            let currItem = item as! MyRSSItem
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}

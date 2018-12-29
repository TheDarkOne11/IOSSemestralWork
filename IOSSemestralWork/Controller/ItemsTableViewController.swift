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
    var myRssItems = [MyRSSItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        for i in 1...20 {
//            let myItem = MyRSSItem()
//            myItem.title = "Title\(i)"
//            myRssItems.append(myItem)
//        }
        
        fetchData()
    }
    
    func fetchData() {
        let url = "http://servis.idnes.cz/rss.aspx?c=zpravodaj"

        print("Fetching:")
        Alamofire.request(url).responseRSS() { (response) -> Void in
            if let feed: RSSFeed = response.result.value {
                //do something with your new RSSFeed object!
                for item in feed.items {
                    let myItem = MyRSSItem(with: item)
                    self.myRssItems.append(myItem)

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
        return myRssItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedItemCell", for: indexPath)
        let currItem: MyRSSItem = myRssItems[indexPath.row]
        
        cell.textLabel?.text = currItem.title
        
        return cell
    }
    
    // MARK: TableView methods
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}

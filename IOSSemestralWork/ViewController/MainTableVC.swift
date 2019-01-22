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
import RealmSwift

/**
 Displays the primary TableView for all possible items.
 */
class MainTableVC: ItemTableVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
//        fetchData()
    }
    
    @IBAction func editBtnPressed(_ sender: UIBarButtonItem) {
        // TODO: Temporary code, remove!
        let realm = try! Realm()
        let folders = realm.objects(Folder.self)
        
        for folder in folders {
            for feed in folder.myRssFeeds {
                dbHandler.update(feed: feed)
            }
        }
    }
    
    // MARK: Data manipulation
    
    func fetchData() {
//        let url = "http://servis.idnes.cz/rss.aspx?c=zpravodaj"
//        let url = "http://google.com"
//        let url = "http://budikpet.com"
        let url = "http://feeds.foxnews.com/foxnews/latest"
        
        Alamofire.request(url)
            .responseRSS() { (response) -> Void in
                
                print("response.result.isFailure: \(response.result.isFailure)")
                print("response.result.isSuccess: \(response.result.isSuccess)")
                
                if(response.result.isFailure) {
                    // TODO: Return internet offline or website doesn't exist
                    print(response.error)
                    return
                }
                
                if let feed: RSSFeed = response.result.value {
                    
                    //do something with your new RSSFeed object!
                    for item in feed.items {
                        let myItem = MyRSSItem(with: item)
                        //                    self.myItems.append(myItem)
                        
                        print("TITLE:\n\(myItem.title)")
                        print("LINK:\n\(myItem.articleLink)")
                        print("AUTHOR:\n\(myItem.author)")
                        print("DESCRIPTION:\n\(myItem.itemDescription)")
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
        if segue.identifier == "ShowAddFeed" {
            let destinationVC = (segue.destination as! UINavigationController).topViewController as! NewFeedVC
            destinationVC.delegate = self
            
            return
        }

        guard let indexPath = tableView.indexPathForSelectedRow else {
            print("Unreacheable tableViewCell selected.")
            fatalError()
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
        var testFeed = MyRSSFeed(with: "Technika", link: "http://www.google.com")
        testFeed.myRssItems.append(MyRSSItem(with: nil))
        
        let testFolder = Folder(with: "TestFolder", isContentsViewable: true)
        testFolder.myRssFeeds.append(testFeed)
        
        var testRssItem = MyRSSItem(with: nil)
        testRssItem.title = "Prezident Zeman plánuje odpočinkový rok. Jen krátké cesty, ale znovu Čína"
        testRssItem.author = "Unknown"
        testRssItem.articleLink = "https://zpravy.idnes.cz/zeman-hrad-odpocinek-zahranicni-cesty-dxg-/domaci.aspx?c=A181218_104225_domaci_jabe#utm_source=rss&utm_medium=feed&utm_campaign=zpravodaj&utm_content=main"
        testRssItem.itemDescription = """
        Od listopadové návštěvy v Izraeli odpočívá, na konec letošního roku si naordinoval i s hradním mluvčím Jiřím Ovčáčkem třítýdenní dovolenou. A odpočinkový režim bude mít prezident Miloš Zeman i příští rok. Zatím má v plánu pět zahraničních cest. Vyrazí opět na Slovensko a do Číny.

        <ul><b>Další články k tématu:</b><li><a href=\"https://zpravy.idnes.cz/videa-tydne-zeman-parodie-orsava-teroristicky-utok-strasburk-d1-kolaps-pocasi-soukup-urazka-barrando-ibd-/domaci.aspx?c=A181216_154745_domaci_rejs#utm_source=rss&utm_medium=feed&utm_campaign=zpravodaj&utm_content=related\">VIDEA TÝDNE: Zeman v parodii, útok ve Štrasburku a kolaps na dálnici D1</a></li><li><a href=\"https://kultura.zpravy.idnes.cz/harry-potter-zeman-parodie-video-michal-orsava-fln-/filmvideo.aspx?c=A181214_170737_filmvideo_kiz#utm_source=rss&utm_medium=feed&utm_campaign=zpravodaj&utm_content=related\">VIDEO: Takto se točila parodie na Harryho Pottera se Zemanem a Babišem</a></li><li><a href=\"https://zpravy.idnes.cz/eu-rusko-sankce-diplomacie-d0k-/zahranicni.aspx?c=A181213_185215_zahranicni_luka#utm_source=rss&utm_medium=feed&utm_campaign=zpravodaj&utm_content=related\">Zemanovi navzdory. EU znovu prodloužila hospodářské sankce proti Rusku</a></li><li><a href=\"https://zpravy.idnes.cz/zeman-vecere-adventni-lany-zamek-vlada-premier-ministri-babis-pu7-/domaci.aspx?c=A181210_183953_domaci_pmk#utm_source=rss&utm_medium=feed&utm_campaign=zpravodaj&utm_content=related\">Ministři večeřeli u prezidenta Zemana, adventní setkání se má stát tradicí</a></li></ul>
        """
        
        testFeed = MyRSSFeed(with: "Zpravodaj", link: "http://www.google.com")
        testFeed.myRssItems.append(testRssItem)
        
        myItems.append(testFolder)
        myItems.append(testFeed)
    }
}

// TODO: Do Realmu vložím nový feed a začnu stahovat data. Pokud má feed špatnou adresu (adresa není RSS feed nebo neexistuje), udělám u něj v tableView nějaký vizuální indikátor (červený trojúhelník), možná i u jeho folderu. Tuto informaci musím uložit ve feedu, možná i ve folderu. Vizuální indikátor nezobrazíme, pokud se nemůžeme připojit k internetu. To uděláme v update liště.
extension MainTableVC: NewFeedDelegate {
    func feedCreated(feed myRssFeed: MyRSSFeed) {
        // Validate the address by running update of the feed
        // TODO: Validation
        dbHandler.update(feed: myRssFeed)
        
        tableView.reloadData()
    }
    
}

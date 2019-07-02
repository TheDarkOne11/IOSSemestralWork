//
//  RSSItemVC.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import WebKit
import RealmSwift

class RSSItemVC: UIViewController {
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var starItem: UITabBarItem!
    @IBOutlet weak var readItem: UITabBarItem!
    @IBOutlet weak var upItem: UITabBarItem!
    @IBOutlet weak var downItem: UITabBarItem!
    
    let dbHandler: DBHandler = DBHandler()
    
    var myRssItems: Results<MyRSSItem>?
    var selectedItemIndex: Int?
    private var selectedRssItem: MyRSSItem? {
        didSet {
            // Set read status to true when user enters
            dbHandler.realmEdit(errorMsg: "Error occured when setting MyRSSItem isRead to true") {
                selectedRssItem!.isRead = true
            }
        }
    }
    
    /**
     The WKWebView used to display data of RSSItems.
     It's created as singleton because creating its instance every time caused a significant delay.
     */
    private static var webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        
        // Load HTML template
        if let url = Bundle.main.url(forResource: "RSSItemFormat", withExtension: "html", subdirectory: "Web") {
            print("Loading webView")
            webView.loadFileURL(url, allowingReadAccessTo: url)
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add WebKitView into the view programatically, statically didn't work.
        let layoutGuide = view.safeAreaLayoutGuide
        
        view.addSubview(RSSItemVC.webView)
        RSSItemVC.webView.navigationDelegate = self
        RSSItemVC.webView.translatesAutoresizingMaskIntoConstraints = false
        RSSItemVC.webView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        RSSItemVC.webView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        RSSItemVC.webView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        RSSItemVC.webView.bottomAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        
        // Select the RSSItem and load data into the webView
        selectRssItem(at: selectedItemIndex)
        
        // Initialize TabBar
        initTabBar()
    }
    
    /**
     Sets selectedRssItem to the RSSItem at the given index.
     */
    private func selectRssItem(at index: Int?) {
        guard let items = myRssItems else {
            fatalError("RSS items should already be initialized.")
        }
        
        if let index = index {
            if index >= 0 && index < items.count {
                selectedItemIndex = index
                selectedRssItem = myRssItems?[index]
                RSSItemVC.webView.reload()
            } else {
                fatalError("Index out of bounds.")
            }
        }
    }
    
    // MARK: Navigation
    
    @IBAction func goToWebButtonPressed(_ sender: UIBarButtonItem) {
        if let link = selectedRssItem?.articleLink {
            goToWeb(url: URL(string: link))
        }
    }
}

// MARK: WKNavigationDelegate

extension RSSItemVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            // A link inside the webView was clicked
            goToWeb(url: navigationAction.request.url)
            
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    /**
     Opens the URL of the current RSSItem in the Safari app browser.
     */
    private func goToWeb(url: URL?) {
        if let currUrl = url {
            UIApplication.shared.open(currUrl)
        }
    }
    
    /**
     Loads new RSSItem data in the HTML template using a Javascript script.
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let rssItem = selectedRssItem {
            let scriptCode = getScriptCode(using: rssItem)
            
            RSSItemVC.webView.evaluateJavaScript(scriptCode) { (result, error) in
                if let error = error {
                    print("Error occured when passing data to WKWebView: \(error)")
                }
            }
        }
    }
    
    /**
     Create Javascript code which passes data to the webView.
     
     - parameter rssItem: The RSSItem whose data we want to display.
     
     - returns: The String value of the Javascript code used to pass data into the WKWebView.
     */
    private func getScriptCode(using rssItem: MyRSSItem) -> String {
        // Time
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_GB")  // "cs_CZ"
        let timeString = "Published \( formatter.string(from: rssItem.date!) ) by \(rssItem.author)"
        
        // Init RSSItem webView
        var code = String(format: "init(`%@`, `%@`, `%@`);", rssItem.title, timeString, rssItem.itemDescription)
        
        if let imageLink = rssItem.image {
            code += String(format: "showImage(`%@`);", imageLink)
        }
        
        return code
    }
}

// MARK: TabBar and UITabBarDelegate methods

extension RSSItemVC: UITabBarDelegate {
    private func initTabBar() {
        tabBar.delegate = self
        set(read: selectedRssItem!.isRead)
        set(starred: selectedRssItem!.isStarred)
        
        checkBounds()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            // Read & Unread item
            set(read: !selectedRssItem!.isRead)
            break
        case 1:
            // Starred & Unstarred item
            set(starred: !selectedRssItem!.isStarred)
            break
        case 2:
            // Up item
            selectRssItem(at: selectedItemIndex! - 1)
            initTabBar()
            break
        case 3:
            // Down item
            selectRssItem(at: selectedItemIndex! + 1)
            initTabBar()
            break
        default:
            fatalError("Unknown tab bar item selected")
        }
    }
    
    /**
     Changes the starred value of the current RSS item and persists it.
     */
    private func set(starred: Bool) {
        guard let rssItem = selectedRssItem else {
            fatalError("The RSSItem should already be selected.")
        }
        
        if starred {
            starItem.title = "Starred"
            starItem.image = UIImage(named: "tabStarred")
        } else {
            starItem.title = "Unstarred"
            starItem.image = UIImage(named: "tabUnstarred")
        }
        
        starItem.selectedImage = starItem.image
        
        if starred != rssItem.isStarred {
            dbHandler.realmEdit(errorMsg: "Error occured when setting MyRSSItem isStarred to \(starred)") {
                rssItem.isStarred = starred
            }
        }
    }
    
    /**
     Changes the read value of the current RSS item and persists it.
     */
    private func set(read: Bool) {
        guard let rssItem = selectedRssItem else {
            fatalError("The RSSItem should already be selected.")
        }
        
        if read {
            readItem.title = "Read"
            readItem.image = UIImage(named: "tabRead")
        } else {
            readItem.title = "Unread"
            readItem.image = UIImage(named: "tabUnread")
        }
        
        readItem.selectedImage = readItem.image
        
        if read != rssItem.isRead {
            dbHandler.realmEdit(errorMsg: "Error occured when setting MyRSSItem isRead to \(read)") {
                rssItem.isRead = read
            }
        }
    }
    
    /**
     Disables Up/ Down bar items if a user is at the first/ last RSSItem of the RSSItems list.
     */
    private func checkBounds() {
        upItem.isEnabled = selectedItemIndex! > 0
        downItem.isEnabled = selectedItemIndex! < myRssItems!.count - 1
    }
}

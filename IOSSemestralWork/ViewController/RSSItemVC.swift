//
//  RSSItemVC.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import WebKit

class RSSItemVC: UIViewController {
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var starItem: UITabBarItem!
    @IBOutlet weak var readItem: UITabBarItem!
    
    let dbHandler: DBHandler = DBHandler()
    
    var selectedRssItem: MyRSSItem? {
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
        
        // Initialize TabBar
        tabBar.delegate = self
        set(read: selectedRssItem!.isRead)
        set(starred: selectedRssItem!.isStarred)
        
        // Add WebKitView into the view programatically, statically didn't work.
        let layoutGuide = view.safeAreaLayoutGuide
        
        view.addSubview(RSSItemVC.webView)
        RSSItemVC.webView.navigationDelegate = self
        RSSItemVC.webView.translatesAutoresizingMaskIntoConstraints = false
        RSSItemVC.webView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        RSSItemVC.webView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        RSSItemVC.webView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        RSSItemVC.webView.bottomAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        
        // Load data into the webView
        RSSItemVC.webView.reload()
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
     Opens the URL in Safari app browser.
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

// MARK: UITabBarDelegate methods

extension RSSItemVC: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            // Read & Unread item
            print("Change read")
            set(read: !selectedRssItem!.isRead)
            break
        case 1:
            // Starred & Unstarred item
            print("Change starred")
            set(starred: !selectedRssItem!.isStarred)
            break
        case 2:
            // Up item
            print("Change item up")
            break
        case 3:
            // Down item
            print("Change item down")
            break
        default:
            fatalError("Unknown tab bar item selected")
        }
    }
    
    func set(starred: Bool) {
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
    
    func set(read: Bool) {
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
}

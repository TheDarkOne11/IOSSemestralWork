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
    var selectedRssItem: MyRSSItem?
    
    /**
     The WKWebView used to display data of RSSItems.
     It's created as singleton because creating its instance every time caused a significant delay.
     */
    private static var webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        
        // Load HTML template
        if let url = Bundle.main.url(forResource: "RSSItemFormat", withExtension: "html", subdirectory: ".") {
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
        RSSItemVC.webView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        // Load data into the webView
        RSSItemVC.webView.reload()
    }
    
    // MARK: Navigation
    
    @IBAction func goToWebButtonPressed(_ sender: UIBarButtonItem) {
        // Open the URL in Safari
        if let link = selectedRssItem?.articleLink {
            guard let url = URL(string: link) else { return }
            UIApplication.shared.open(url)
        }
    }
}

// MARK: WKNavigationDelegate

extension RSSItemVC: WKNavigationDelegate {
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
    func getScriptCode(using rssItem: MyRSSItem) -> String {
        // Time
        let date = NSDate()
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_GB")  // "cs_CZ"
        let timeString = "Published \( formatter.string(from: date as Date) ) by \(rssItem.author)"
        
        // Image
        // TODO: Add image
        let code = String(format: "init(`%@`, `%@`, `%@`);", rssItem.title, timeString, rssItem.itemDescription)
        
        return code
    }
}

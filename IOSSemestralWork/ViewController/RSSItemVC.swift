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
    
    var webView: WKWebView?
    
    // TODO: Add image
    
    // Template string for javascript script thich loads data to the HTML template
    var inputDataScript =   """
                                document.getElementById(`title`).innerHTML = `%@`;
                                document.getElementById(`timeString`).innerHTML = `%@`;
                                document.getElementById(`description`).innerHTML = `%@`;

                                document.getElementById(`image`).hidden = `%@`;
                                document.getElementById(`image`).innerHTML = `%@`;
                            """
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Add WebKitView into the view programatically, statically didn't work.
        let layoutGuide = view.safeAreaLayoutGuide
        let webView = WKWebView(frame: .zero)
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        // Load HTML template
        if let url = Bundle.main.url(forResource: "RSSItemFormat", withExtension: "html", subdirectory: ".") {
            print("Loading webView")
            webView.loadFileURL(url, allowingReadAccessTo: url)
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        self.webView = webView
        reloadPage()
    }
    
    // MARK: WebView methods
    
    /**
     Loads new information in the HTML template using a Javascript script and RSSItem information.
     */
    func reloadPage() {
        guard let webView = self.webView else { fatalError() }
        
        if let rssItem = selectedRssItem {
            let controller = webView.configuration.userContentController
            let scriptCode = getScriptCode(using: rssItem)
            let script = WKUserScript(source: scriptCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

            controller.removeAllUserScripts()
            controller.addUserScript(script)
        }
        
        webView.reload()
    }
    
    /**
     Put the Javascript script code together using a template string and information from a RSSItem.
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
        // TODO Add image
        
        let code = String(format: inputDataScript, rssItem.title, timeString, rssItem.itemDescription);
        
        return code
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

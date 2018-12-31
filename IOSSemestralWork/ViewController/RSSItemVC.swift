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

    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        var string = selectedRssItem!.itemDescription
        string += string
        string += string
        string += string
        string += string
        webView.loadHTMLString(string, baseURL: nil)
    }

    @IBAction func goToWebButtonPressed(_ sender: UIBarButtonItem) {
        guard let url = URL(string: "https://www.idnes.cz") else { return }
        UIApplication.shared.open(url)
    }
}

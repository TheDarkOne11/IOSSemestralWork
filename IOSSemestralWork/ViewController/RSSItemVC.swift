//
//  RSSItemVC.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit

class RSSItemVC: UIViewController {
    var selectedRssItem: MyRSSItem? {
        didSet {
            title = selectedRssItem!.title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func goToWebButtonPressed(_ sender: UIBarButtonItem) {
        guard let url = URL(string: "https://www.idnes.cz") else { return }
        UIApplication.shared.open(url)
    }
}

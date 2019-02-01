//
//  TableViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 01/02/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var array = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        
        for i in 0...5 {
            array.append("The longest title I could think of on such short notice when I need one: \(i)")
            array.append("Title \(i)")
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ItemCell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell

        cell.set(title: array[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("Pressed accessory button at: \(indexPath.row)")
    }

}

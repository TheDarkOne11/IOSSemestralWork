//
//  TableViewController2.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 01/02/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import UIKit

class TableViewController2: UITableViewController {
    @IBOutlet weak var titleLabel: UILabel!
    
    var array = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...10 {
            //            array.append("The longest title I could think of on such short notice when I need one: \(i)")
            array.append("Title \(i)")
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath)
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("Pressed accessory button at: \(indexPath.row)")
    }

}

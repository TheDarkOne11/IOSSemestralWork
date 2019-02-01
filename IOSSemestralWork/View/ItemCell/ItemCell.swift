//
//  ItemCell.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 01/02/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var errorImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(using folder: Folder) {
        setData(title: folder.title, imgName: "folder")
    }
    
    func setData(using feed: MyRSSFeed) {
        setData(title: feed.title, imgName: "error")
    }
    
    func setData(title: String?, imgName: String?) {
        titleLabel.text = title
        
        if let imgName = imgName {
            self.typeImage.image = UIImage(named: imgName)
        }
    }
    
}

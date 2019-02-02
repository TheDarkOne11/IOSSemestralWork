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
    @IBOutlet weak var numOfItemsLabel: UILabel!
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
        var count = 0
        for feed in folder.myRssFeeds {
            count += feed.unreadItemsCount()
        }
        
        setData(title: folder.title, imgName: "folder", itemCount: count)
    }
    
    func setData(using feed: MyRSSFeed) {
        if !feed.isOk {
            errorImage.isHidden = false
        }
        
        setData(title: feed.title, imgName: nil, itemCount: feed.unreadItemsCount())
    }
    
    func setData(title: String?, imgName: String?, itemCount count: Int) {
        titleLabel.text = title
        
        if let imgName = imgName {
            typeImage.image = UIImage(named: imgName)
        } else {
            typeImage.isHidden = true
        }
        
        // Set errorImage/numOfItemsLabel
        numOfItemsLabel.isHidden = !errorImage.isHidden
        numOfItemsLabel.text = "\(count)"
    }
    
}

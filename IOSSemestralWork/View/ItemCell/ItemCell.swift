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
            if let feed = feed.myRssFeed {
                count += feed.unreadItemsCount()
            }
        }
        
        setData(title: folder.title, imgName: "folder", itemCount: count, true)
    }
    
    func setData(using feed: MyRSSFeed) {
        setData(title: feed.title, imgName: nil, itemCount: feed.unreadItemsCount(), feed.isOk)
    }
    
    func setData(title: String?, imgName: String?, itemCount count: Int, _ errorHidden: Bool? = true) {
        titleLabel.text = title
        
        if let imgName = imgName {
            typeImage.image = UIImage(named: imgName)
            typeImage.isHidden = false
        } else {
            typeImage.isHidden = true
        }
        
        // Set errorImage/numOfItemsLabel
        errorImage.isHidden = errorHidden!
        numOfItemsLabel.isHidden = !errorImage.isHidden
        numOfItemsLabel.text = "\(count)"
    }
    
}

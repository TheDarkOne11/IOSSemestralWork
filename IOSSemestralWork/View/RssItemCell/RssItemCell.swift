//
//  RssItemCell.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 02/02/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import UIKit

class RssItemCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var timeFeedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(using item: MyRSSItem) {
        titleLabel.text = item.title
        descLabel.text = item.description_NoHtml
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "en_GB")  // "cs_CZ"
        
        let timeString = formatter.string(from: item.date!)
        timeFeedLabel.text = "\(timeString) | \(item.rssFeed!.title)"
    }
}

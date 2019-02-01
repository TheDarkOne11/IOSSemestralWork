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
    
    public func set(title: String) {
        titleLabel.text = title
    }
    
}

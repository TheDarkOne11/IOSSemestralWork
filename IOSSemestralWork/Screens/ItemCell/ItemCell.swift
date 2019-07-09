//
//  ItemCell.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 01/02/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import UIKit
import SnapKit

class ItemCell: UITableViewCell {
    private weak var titleLabel: UILabel!
    private weak var numOfItemsLabel: UILabel!
    private weak var typeImage: UIImageView!
//    private weak var errorImage: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stackView = UIStackView()
        addSubview(stackView)
        
        let titleLabel = UILabel()
        stackView.addArrangedSubview(titleLabel)
        self.titleLabel = titleLabel
//        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
//        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        let numOfItemsLabel = UILabel()
        stackView.addArrangedSubview(numOfItemsLabel)
        self.numOfItemsLabel = numOfItemsLabel
//        numOfItemsLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        numOfItemsLabel.setContentHuggingPriority(.init(251), for: .vertical)
//        numOfItemsLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
//        numOfItemsLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        let typeImage = UIImageView()
        stackView.addArrangedSubview(typeImage)
        self.typeImage = typeImage
//        typeImage.setContentHuggingPriority(.init(251), for: .horizontal)
//        typeImage.setContentHuggingPriority(.init(251), for: .vertical)
//        typeImage.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        typeImage.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setData(using polyItem: PolyItem) {
        if let folder = polyItem.folder {
            setData(using: folder)
        } else if let feed = polyItem.myRssFeed {
            setData(using: feed)
        }
    }
    
    func setData(using folder: Folder) {
        var count = 0
        for feed in folder.polyItems {
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
//        errorImage.isHidden = errorHidden!
//        numOfItemsLabel.isHidden = !errorImage.isHidden
        numOfItemsLabel.text = "\(count)"
    }
    
}

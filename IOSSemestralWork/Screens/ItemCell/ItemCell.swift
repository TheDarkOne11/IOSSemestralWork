//
//  ItemCell.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 01/02/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import UIKit
import SnapKit
import Common

class ItemCell: UITableViewCell {
    private weak var titleLabel: UILabel!
    private weak var numOfItemsLabel: UILabel!
    private weak var typeImage: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let typeImage = UIImageView()
        addSubview(typeImage)
        self.typeImage = typeImage
        typeImage.setContentHuggingPriority(.defaultLow, for: .horizontal)
        typeImage.setContentHuggingPriority(.defaultLow, for: .vertical)
        typeImage.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        typeImage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        let titleLabel = UILabel()
        addSubview(titleLabel)
        self.titleLabel = titleLabel
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.init(251), for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        let numOfItemsLabel = UILabel()
        addSubview(numOfItemsLabel)
        self.numOfItemsLabel = numOfItemsLabel
        numOfItemsLabel.textColor = .lightGray
        numOfItemsLabel.setContentHuggingPriority(.init(251), for: .horizontal)
        numOfItemsLabel.setContentHuggingPriority(.init(251), for: .vertical)
        numOfItemsLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        numOfItemsLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        // Constraints
        typeImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
            make.width.equalTo(typeImage.snp.height).multipliedBy(1/1)
            make.height.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.top.equalToSuperview().inset(8)
            make.leading.equalTo(typeImage.snp_trailing).offset(16)
            make.trailing.greaterThanOrEqualTo(numOfItemsLabel.snp_leading).offset(-8)
        }
        
        numOfItemsLabel.snp.makeConstraints { make in
            make.bottom.trailing.top.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(using item: Item) {
        switch item.type {
        case .folder:
            setData(using: item as! Folder)
        case .myRssFeed:
            setData(using: item as! MyRSSFeed)
        case .myRssItem:
            fatalError("The ItemCell should not be used with RSSItems.")
        case .specialItem:
            let item = item as! SpecialItem
            setData(title: item.title, imgName: item.imgName, itemCount: item.itemsCount())
        }
    }
    
    func setData(using folder: Folder) {
        let predicateUnread = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "isRead == false")])
        setData(title: folder.title, imgName: "folder", itemCount: folder.getRssItemsCount(predicate: predicateUnread), true)
    }
    
    func setData(using feed: MyRSSFeed) {
        let count = feed.myRssItems.filter("isRead == false").count
        setData(title: feed.title, imgName: nil, itemCount: count, feed.isOk)
    }
    
    func setData(title: String?, imgName: String?, itemCount count: Int, _ errorHidden: Bool? = true) {
        titleLabel.text = title
        
        if let imgName = imgName {
            typeImage.image = UIImage(named: imgName, in: Bundle.resources, compatibleWith: nil)
            typeImage.isHidden = false
        } else {
            typeImage.isHidden = true
        }
        
        // Set errorImage/numOfItemsLabel
        numOfItemsLabel.text = "\(count)"
    }
    
}

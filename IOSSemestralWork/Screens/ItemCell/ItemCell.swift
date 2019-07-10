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
    
    func setData(using folder: Folder) {
        setData(title: folder.title, imgName: "folder", itemCount: getUnreadItems(of: folder), true)
    }
    
    private func getUnreadItems(of folder: Folder) -> Int {
        var count = 0
        for feed in folder.feeds {
            count += feed.unreadItemsCount()
        }
        
        for subfolder in folder.folders {
            count += getUnreadItems(of: subfolder)
        }
        
        return count
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
        numOfItemsLabel.text = "\(count)"
    }
    
}

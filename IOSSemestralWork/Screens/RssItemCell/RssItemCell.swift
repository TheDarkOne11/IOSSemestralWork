//
//  RssItemCell.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 02/02/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import UIKit
import SnapKit
import Data

/**
 Visual representation of RSS Item UITableViewCell.
*/
class RssItemCell: UITableViewCell {
    private weak var titleLabel: UILabel!
    private weak var descLabel: UILabel!
    private weak var timeFeedLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let titleLabel = UILabel()
        addSubview(titleLabel)
        self.titleLabel = titleLabel
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.setContentHuggingPriority(.init(251), for: .horizontal)
        titleLabel.setContentHuggingPriority(.init(251), for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        let descLabel = UILabel()
        addSubview(descLabel)
        self.descLabel = descLabel
        descLabel.numberOfLines = 3
        descLabel.font = UIFont.systemFont(ofSize: 13)
        descLabel.setContentHuggingPriority(.init(251), for: .horizontal)
        descLabel.setContentHuggingPriority(.init(251), for: .vertical)
        descLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        descLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        let timeFeedLabel = UILabel()
        addSubview(timeFeedLabel)
        self.timeFeedLabel = timeFeedLabel
        timeFeedLabel.font = UIFont.systemFont(ofSize: 9)
        timeFeedLabel.textColor = .lightGray
        timeFeedLabel.setContentHuggingPriority(.init(251), for: .horizontal)
        timeFeedLabel.setContentHuggingPriority(.init(251), for: .vertical)
        timeFeedLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        timeFeedLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(8)
            make.bottom.equalTo(descLabel.snp.top).offset(-8)
        }
        
        descLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(timeFeedLabel.snp.top).offset(-16)
        }

        timeFeedLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
//            make.top.greaterThanOrEqualTo(descLabel.snp_bottom).inset(16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Load data of an Item into the cell.
     
     - Parameters:
        - item: `MyRSSItem` which should be displayed using the `RssItemCell`.
     */
    func setData(using item: MyRSSItem) {
        titleLabel.text = item.title
        descLabel.text = item.description_NoHtml

        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale.current

        let timeString = formatter.string(from: item.date!)
        timeFeedLabel.text = "\(timeString) | \(item.rssFeed.first!.title)"

        // Items that a user already read are greyed out (disabled)
        titleLabel.isEnabled = !item.isRead
        descLabel.isEnabled = !item.isRead
        timeFeedLabel.isEnabled = !item.isRead
    }
}

//
//  TodayViewController.swift
//  FeedTodayAppExtension
//
//  Created by Petr Budík on 15/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import UIKit
import NotificationCenter
import SnapKit

@objc(TodayViewController)
class TodayViewController: UIViewController, NCWidgetProviding {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stackView = UIStackView()
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 8

        let unreadLabel = UILabel()
        stackView.addArrangedSubview(unreadLabel)
        unreadLabel.text = "Unread items: 666"

        let starredLabel = UILabel()
        stackView.addArrangedSubview(starredLabel)
        starredLabel.text = "Starred items: 666"

        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}

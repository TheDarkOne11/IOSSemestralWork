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
import RealmSwift
import Data
import Common
import Resources

@objc(TodayViewController)
class TodayViewController: UIViewController, NCWidgetProviding {
    private weak var unreadLabel: UILabel!
    private weak var starredLabel: UILabel!
    
    private lazy var rssItems: Results<MyRSSItem> = AppDependency.shared.realm.objects(MyRSSItem.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stackView = UIStackView()
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 8

        let unreadLabel = UILabel()
        stackView.addArrangedSubview(unreadLabel)
        self.unreadLabel = unreadLabel

        let starredLabel = UILabel()
        stackView.addArrangedSubview(starredLabel)
        self.starredLabel = starredLabel

        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        updateLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateLabels()
    }
    
    func updateLabels() {
        let unreadCount = rssItems.filter("isRead == false").count
        let starredCount = rssItems.filter("isStarred == true").count
        
        unreadLabel.text = "Unread items: \(unreadCount)"
        starredLabel.text = "Starred items: \(starredCount)"
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}

//
//  ItemTableVC.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 07/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import UIKit
import RealmSwift
import Resources
import Data
import Common

protocol ItemTableVCFlowDelegate {
    func editOrCreate(feed: MyRSSFeed?)
    func edit(folder: Folder)
}

/**
 VC for displaying `Folder`s and `MyRSSFeed`s.
 */
class ItemTableVC: BaseViewController {
    private let viewModel: IItemTableVM
    private weak var tableView: UITableView!
    lazy var refresher = RefreshControl(delegate: self)
    
    var flowDelegate: ItemTableVCFlowDelegate?
    
    // Realm observer tokens
    private var tokenFeeds: NotificationToken!
    private var tokenFolders: NotificationToken!
    
    init(_ viewModel: IItemTableVM) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        tokenFeeds.invalidate()
        tokenFolders.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        view.accessibilityIdentifier = "ItemTableVC"
        
        let tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.accessibilityIdentifier = "ItemTableVC_TableView"
        
        // Initialize PullToRefresh
        tableView.refreshControl = refresher
        
        tableView.register(ItemCell.self, forCellReuseIdentifier: "ItemCell")
        view.addSubview(tableView)
        self.tableView = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        
        navigationItem.title = viewModel.screenTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonTapped(_:)))
    }
    
    private func setupBindings() {
        viewModel.downloadStatus.producer.startWithValues { [weak self] status in
            print("End refreshing")
            self?.refresher.refreshView.stopUpdating()
            self?.refresher.endRefreshing()
            
            if let status = status {
                self?.checkStatus(status)
            }
            
            self?.tableView.reloadData()
        }
        
        tokenFeeds = viewModel.shownItems.feeds.observe({ [weak self] changes in
            self?.tableView.reloadData()
        })
        
        tokenFolders = viewModel.shownItems.folders.observe({ [weak self] changes in
            self?.tableView.reloadData()
        })
    }
    
    @objc
    private func addBarButtonTapped(_ sender: UIBarButtonItem) {
        flowDelegate?.editOrCreate(feed: nil)
    }
}

// MARK: UITableView delegate and data source

extension ItemTableVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let shownItems = viewModel.shownItems else {
            return 0
        }
        
        let count = shownItems.specialItems.count + shownItems.folders.count + shownItems.feeds.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        guard let shownItems = viewModel.shownItems else {
            fatalError("Shown items should not be nil.")
        }
        
        let item = shownItems.getItem(at: indexPath.row)
        cell.setData(using: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let shownItems = viewModel.shownItems else {
            fatalError("Shown items should not be nil.")
        }
        
        let item = shownItems.getItem(at: indexPath.row)
        viewModel.select(item)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: Refresher

extension ItemTableVC: RefreshControlDelegate {
    func lastUpdateDate() -> NSDate {
        return viewModel.getLastUpdateDate()
    }
    
    
    /**
     Checks beginning of the PullToRefresh and updates its label.
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset: CGFloat = 0
        if let frame = self.navigationController?.navigationBar.frame {
            offset = frame.minY + frame.size.height
        }
        
        if (-scrollView.contentOffset.y >= offset ) {
            refresher.refreshView.updateLabelText(date: lastUpdateDate())
        }
    }
    
    func update() {
        print("requesting data")
        
        refresher.refreshView.startUpdating()
        viewModel.updateAllFeeds()
    }
    
    private func checkStatus(_ status: DownloadStatus) {
        if status == DownloadStatus.unreachable {
            // Internet is unreachable
            print("Internet is unreachable")
            self.view.makeToast(L10n.Error.internetUnreachable)
            
        }
    }
}

// MARK: TableView cells editing and removing

extension ItemTableVC {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let count = viewModel.shownItems.specialItems.count
        return indexPath.row >= count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeAction = UITableViewRowAction(style: .destructive, title: L10n.Base.actionRemove) { (action, indexPath) in
            self.removeItem(at: indexPath)
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: L10n.Base.actionEdit) { (action, indexPath) in
            self.editItem(at: indexPath)
        }
        
        return [removeAction, editAction]
    }
    
    /**
     According to the selected cell we move a user to the screens where he can edit Folders or RSS feeds.
     - parameter indexPath: The location of the cell (Folder or RSS feed) we want to edit.
     */
    private func editItem(at indexPath: IndexPath) {
        guard let shownItems = viewModel.shownItems else {
            fatalError("Error when loading a PolyItem from PolyItems collection.")
        }
        
        let item = shownItems.getItem(at: indexPath.row)
        switch item.type {
        case .folder:
            flowDelegate?.edit(folder: item as! Folder)
        case .myRssFeed:
            flowDelegate?.editOrCreate(feed: item as? MyRSSFeed)
        case .myRssItem:
            fatalError("RSSItems should not be in this window")
        case .specialItem:
            fatalError("Should not be able to edit a special item \(item.title)")
        }
    }
    
    /**
     We remove the selected cell.
     - parameter indexPath: The location of the cell (Folder or RSS feed) we want to remove.
     */
    private func removeItem(at indexPath: IndexPath) {
        guard let shownItems = viewModel.shownItems else {
            fatalError("Error when loading a PolyItem from PolyItems collection.")
        }
        
        let item = shownItems.getItem(at: indexPath.row)
        viewModel.remove(item)
    }
}

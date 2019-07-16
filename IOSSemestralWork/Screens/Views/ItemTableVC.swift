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
import Common

protocol ItemTableVCFlowDelegate {
    func toFeedEdit(with feed: MyRSSFeed?)
}

class ItemTableVC: BaseViewController {
    private let viewModel: IItemTableVM
    private weak var tableView: UITableView!
    lazy var refresher = RefreshControl()
    
    var flowDelegate: ItemTableVCFlowDelegate?
    
    var token: NotificationToken!
    var token2: NotificationToken!
    
    init(_ viewModel: IItemTableVM) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        token.invalidate()
        token2.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        
        let tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        tableView.dataSource = self
        tableView.delegate = self
        
        // Initialize PullToRefresh
        tableView.refreshControl = refresher
        refresher.delegate = self
        
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
        
        token = viewModel.shownItems.feeds.observe({ [weak self] changes in
            guard let tableView = self?.tableView else { return }
            guard let shownItems = self?.viewModel.shownItems else { return }
            switch changes {
            case .initial(_):
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                let offset = shownItems.specialItems.count + shownItems.folders.count
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map { IndexPath(row: $0 + offset, section: 0) },
                                          with: .automatic)
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0 + offset, section: 0) },
                                          with: .automatic)
                tableView.reloadRows(at: modifications.map { IndexPath(row: $0 + offset, section: 0) },
                                          with: .automatic)
                tableView.endUpdates()
            case .error(let err):
                fatalError(err.localizedDescription)
            }
        })
        
        token2 = viewModel.shownItems.folders.observe({ [weak self] changes in
            guard let tableView = self?.tableView else { return }
            guard let shownItems = self?.viewModel.shownItems else { return }
            switch changes {
            case .initial(_):
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                let offset = shownItems.specialItems.count
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map { IndexPath(row: $0 + offset, section: 0) },
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0 + offset, section: 0) },
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map { IndexPath(row: $0 + offset, section: 0) },
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let err):
                fatalError(err.localizedDescription)
            }
        })
    }
    
    @objc
    private func addBarButtonTapped(_ sender: UIBarButtonItem) {
        flowDelegate?.toFeedEdit(with: nil)
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
    
    /**
     Checks beginning of the PullToRefresh and updates its label.
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset: CGFloat = 0
        if let frame = self.navigationController?.navigationBar.frame {
            offset = frame.minY + frame.size.height
        }
        
        if (-scrollView.contentOffset.y >= offset ) {
            refresher.refreshView.updateLabelText()
        }
    }
    
    func update() {
        print("requesting data")
        
        refresher.refreshView.startUpdating()
        viewModel.updateAllFeeds()
    }
    
    private func checkStatus(_ status: DownloadStatus) {
        if status == DownloadStatus.Unreachable {
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
            presentEditAlert(item as! Folder)
        case .myRssFeed:
            flowDelegate?.toFeedEdit(with: item as! MyRSSFeed)
        case .myRssItem:
            fatalError("RSSItems should not be in this window")
        case .specialItem:
            fatalError("Should not be able to edit a special item \(item.title)")
        }
    }
    
    /**
     Creates and presents an alert used for editing the selected folder.
     
     - parameter folder: The selected folder.
     */
    private func presentEditAlert(_ folder: Folder) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: L10n.ItemTableView.editFolderTitle, message: "", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: L10n.Base.actionCancel, style: .cancel)
        let actionDone = UIAlertAction(title: L10n.Base.actionDone, style: .default) { [weak self] (action) in
            self?.viewModel.edit(folder, title: textField.text ?? "")
        }
        
        alert.addAction(actionDone)
        alert.addAction(actionCancel)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = L10n.ItemTableView.folderNamePlaceholder
            alertTextField.text = folder.title
            alertTextField.enablesReturnKeyAutomatically = true
            
            textField = alertTextField
        }
        
        // Check for textField changes. Done button is enabled only when the textField isn't empty
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { _ in
            // Enables and disables Done action. Triggered when value of textField changes
            let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
            actionDone.isEnabled = textCount > 0
        }
        
        present(alert, animated: true, completion: nil)
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

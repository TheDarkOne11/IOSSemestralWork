//
//  ItemTableVC.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 07/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import UIKit

protocol ItemTableVCFlowDelegate {
    
}

class ItemTableVC: BaseViewController {
    private let viewModel: IItemTableVM
    private weak var tableView: UITableView!
    lazy var refresher = RefreshControl()
    
    init(_ viewModel: ItemTableVM) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        
        let tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.white
        
        // Initialize PullToRefresh
        tableView.refreshControl = refresher
        refresher.delegate = self
        
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        view.addSubview(tableView)
        self.tableView = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        
        navigationItem.title = "Custom title"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionBarButtonTapped(_:)))
    }
    
    private func setupBindings() {
        //FIXME: Implement
    }
}


//FIXME: Implement
extension ItemTableVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("Not implemented")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Not implemented")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


//FIXME: Implement
extension ItemTableVC: RefreshControlDelegate {
    func update() {
        fatalError("Not implemented")
    }
}

// MARK: TableView cells editing and removing

//FIXME: Implement
//extension ItemTableVC {
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
////        return indexPath.row >= specialFoldersCount
//        fatalError("Not implemented")
//    }
//    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let removeAction = UITableViewRowAction(style: .destructive, title: "Remove") { (action, indexPath) in
//            self.removeItem(at: indexPath)
//            self.tableView.reloadData()
//        }
//        
//        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
//            self.editItem(at: indexPath)
//            self.tableView.reloadData()
//        }
//        
//        return [removeAction, editAction]
//    }
//    
//    /**
//     According to the selected cell we move a user to the screens where he can edit Folders or RSS feeds.
//     - parameter indexPath: The location of the cell (Folder or RSS feed) we want to edit.
//     */
//    private func editItem(at indexPath: IndexPath) {
//        guard let polyItem = polyItems?[indexPath.row - specialFoldersCount] else {
//            fatalError("Error when loading a PolyItem from PolyItems collection.")
//        }
//        
//        if let folder = polyItem.folder {
//            presentEditAlert(folder)
//        } else if let feed = polyItem.myRssFeed {
//            performSegue(withIdentifier: "ShowAddFeed", sender: feed)
//        }
//    }
//    
//    /**
//     Creates and presents an alert used for editing the selected folder.
//     
//     - parameter folder: The selected folder.
//     */
//    private func presentEditAlert(_ folder: Folder) {
//        var textField = UITextField()
//        
//        let alert = UIAlertController(title: "Edit folder", message: "", preferredStyle: .alert)
//        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
//        let actionDone = UIAlertAction(title: "Done", style: .default) { (action) in
//            self.dbHandler.realmEdit(errorMsg: "Error occured when editing a folder", editCode: {
//                folder.title = textField.text!
//            })
//            self.tableView.reloadData()
//        }
//        
//        alert.addAction(actionDone)
//        alert.addAction(actionCancel)
//        alert.addTextField { (alertTextField) in
//            alertTextField.placeholder = "Folder name"
//            alertTextField.text = folder.title
//            alertTextField.enablesReturnKeyAutomatically = true
//            
//            textField = alertTextField
//        }
//        
//        // Check for textField changes. Done button is enabled only when the textField isn't empty
//        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { _ in
//            // Enables and disables Done action. Triggered when value of textField changes
//            let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
//            actionDone.isEnabled = textCount > 0
//        }
//        
//        present(alert, animated: true, completion: nil)
//    }
//    
//    /**
//     We remove the selected cell.
//     - parameter indexPath: The location of the cell (Folder or RSS feed) we want to remove.
//     */
//    private func removeItem(at indexPath: IndexPath) {
//        guard let polyItem = polyItems?[indexPath.row - specialFoldersCount] else {
//            fatalError("Error when loading a PolyItem from PolyItems collection.")
//        }
//        
//        viewModel.remove(polyItem)
//        
//        tableView.deleteRows(at: [indexPath], with: .automatic)
//    }
//}

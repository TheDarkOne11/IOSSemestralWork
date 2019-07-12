////
////  RSSFeedTableVC.swift
////  IOSSemestralWork
////
////  Created by Petr Budík on 12/07/2019.
////  Copyright © 2019 Petr Budík. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//final class RSSItemsTableVC: BaseViewController {
//    private let viewModel: IRSSItemsTableVM
//    private weak var tableView: UITableView!
//    lazy var refresher = RefreshControl()
//    
////    var flowDelegate: ItemTableVCFlowDelegate?
//    
//    init(_ viewModel: IRSSItemsTableVM) {
//        self.viewModel = viewModel
//        
//        super.init()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func loadView() {
//        super.loadView()
//        view.backgroundColor = .white
//        
//        let tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
//        tableView.dataSource = self
//        tableView.delegate = self
//        
//        // Initialize PullToRefresh
//        tableView.refreshControl = refresher
//        refresher.delegate = self
//        
//        tableView.register(ItemCell.self, forCellReuseIdentifier: "ItemCell")
//        view.addSubview(tableView)
//        self.tableView = tableView
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupBindings()
//        
//        navigationItem.title = viewModel.screenTitle
////        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonTapped(_:)))
//    }
//}

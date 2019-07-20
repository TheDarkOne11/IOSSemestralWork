//
//  FolderEditVC.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 20/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import ReactiveSwift
import ReactiveCocoa
import Resources
import Common
import Data

protocol FolderEditFlowDelegate {
    func editSuccessful(in viewController: FolderEditVC)
}

protocol FolderEditDelegate {
    func created(folder: Folder)
}

class FolderEditVC: BaseViewController {
    private let viewModel: IFolderEditVM
    private weak var tableView: UITableView!
    private weak var folderNameField: UITextField!
    private weak var errorLabel: UILabel!
    private weak var doneBarButton: UIBarButtonItem!
    
    private var sections: [UITableView.Section] = []
    
    var delegate: FolderEditDelegate?
    var flowDelegate: FolderEditFlowDelegate?
    
    init(_ viewModel: IFolderEditVM) {
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "folderEditCell")
        view.addSubview(tableView)
        self.tableView = tableView
        
        prepareRows()
    }
    
    private func prepareRows() {
        let secEditFolder = UITableView.Section(rows: 1, header: L10n.RssEditView.feedDetails)
        
        // Create rows
        // Folder details rows
        let folderNameField = UITextField()
        folderNameField.placeholder = L10n.RssEditView.namePlaceholder
        folderNameField.enablesReturnKeyAutomatically = true
        
        let errorLabel = UILabel()
        errorLabel.text = "Error occured."
        
        secEditFolder.rows[0].contentView = UIView().addSubViews(folderNameField, errorLabel)
        self.folderNameField = folderNameField
        self.errorLabel = errorLabel
        
        folderNameField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(8)
            make.bottom.equalTo(errorLabel.snp_top).offset(-8)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
        }
        
        // Add sections to the array
        sections.append(secEditFolder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.folderForUpdate.value != nil ? L10n.RssEditView.titleUpdate : L10n.RssEditView.titleCreate
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionBarButtonTapped(_:)))
        doneBarButton = navigationItem.rightBarButtonItem
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarButtonTapped(_:)))
        
        setupBindings()
    }
    
    private func setupBindings() {
        folderNameField <~> viewModel.folderName
        
        doneBarButton.reactive.isEnabled <~ viewModel.canCreateFolderSignal
        
        errorLabel.reactive.textColor <~ viewModel.canCreateFolderSignal.map({ canCreate -> UIColor in
            return canCreate ? UIColor.black : UIColor.red
        })
        errorLabel.reactive.isHidden <~ viewModel.canCreateFolderSignal
        
        viewModel.createFolderAction.values.producer.startWithValues { [weak self] folder in
            if let self = self {
                self.delegate?.created(folder: folder)
                self.flowDelegate?.editSuccessful(in: self)
            }
        }
    }
    
    @objc
    private func actionBarButtonTapped(_ sender: UIBarButtonItem) {
        let title = viewModel.folderName.value
        
        let folderData: IFolderEditVM.CreateFolderInput = (title, nil)
        self.viewModel.createFolderAction.apply(folderData).start()

    }
    
    @objc
    private func cancelBarButtonTapped(_ sender: UIBarButtonItem) {
        flowDelegate?.editSuccessful(in: self)
    }
}

//MARK: UITableView Delegate and DataSource methods

extension FolderEditVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.filter { !$0.isHidden }.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "folderEditCell", for: indexPath)
        let rows = sections[indexPath.section].rows.filter { !$0.isHidden }
        
        if let view = rows[indexPath.row].contentView {
            cell.contentView.addSubview(view)
            view.snp.makeConstraints { make in
                make.top.bottom.leading.trailing.equalToSuperview()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let action = sections[indexPath.section].rows[indexPath.row].onSelected {
            action()
            tableView.reloadData()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

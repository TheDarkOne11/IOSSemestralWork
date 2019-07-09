import UIKit
import SnapKit
import ReactiveSwift
import ReactiveCocoa
import RealmSwift

protocol RSSFeedEditFlowDelegate {
    func editSuccessful(in viewController: RSSFeedEditVC)
}

class RSSFeedEditVC: BaseViewController {
    private let viewModel: IRSSFeedEditVM
    private weak var tableView: UITableView!
    private weak var feedNameField: UITextField!
    private weak var linkField: UITextField!
    private weak var addFolderLabel: UILabel!
    private weak var folderLabel: UILabel!
    private weak var folderNameLabel: UILabel!
    private weak var pickerView: UIPickerView!
    
    private var sections: [UITableView.Section] = []
    
    var flowDelegate: RSSFeedEditFlowDelegate?
    
    init(_ viewModel: IRSSFeedEditVM) {
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "rssFeedEditCell")
        view.addSubview(tableView)
        self.tableView = tableView
        
        prepareRows()
    }
    
    private func prepareRows() {
        let feedDetails = UITableView.Section(rows: 2, header: L10n.RssEditView.feedDetails)
        let specifyFolder = UITableView.Section(rows: 3, header: L10n.RssEditView.specifyFolder)
        
        // Create rows
        // Feed details rows
        let feedNameField = UITextField()
        feedDetails.rows[0].contentView = UIView().addSubViews(feedNameField)
        feedNameField.placeholder = L10n.RssEditView.namePlaceholder
        feedNameField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.top.equalToSuperview().inset(8)
        }
        self.feedNameField = feedNameField
    
        let linkField = UITextField()
        feedDetails.rows[1].contentView = UIView().addSubViews(linkField)
        linkField.placeholder = L10n.RssEditView.linkPlaceholder
        linkField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.top.equalToSuperview().inset(8)
        }
        self.linkField = linkField
        
        if(!AppDelegate.isProduction) {
            linkField.text = "https://servis.idnes.cz/rss.aspx?c=zpravodaj"
        }
        
        // Specify folder rows
        let addFolderLabel = UILabel()
        specifyFolder.rows[0].contentView = UIView().addSubViews(addFolderLabel)
        addFolderLabel.text = L10n.RssEditView.addFolder
        addFolderLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.top.equalToSuperview().inset(8)
        }
        self.addFolderLabel = addFolderLabel
        
        let folderLabel = UILabel()
        let folderNameLabel = UILabel()
        specifyFolder.rows[1].contentView = UIView().addSubViews(folderLabel, folderNameLabel)
        folderLabel.text = L10n.RssEditView.folderLabel
        folderLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        folderLabel.setContentHuggingPriority(.init(250), for: .horizontal)
        folderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.bottom.top.equalToSuperview().inset(8)
            make.trailing.equalTo(folderNameLabel.snp_leading).offset(-16)
        }
        folderNameLabel.snp.makeConstraints{ make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.top.equalToSuperview().inset(8)
            make.leading.equalTo(folderLabel.snp_trailing).offset(-16)
        }
        self.folderLabel = folderLabel
        self.folderNameLabel = folderNameLabel
        
        
        let pickerView = UIPickerView()
        specifyFolder.rows[2].contentView = UIView().addSubViews(pickerView)
        specifyFolder.rows[2].isHidden = true
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalToSuperview()
        }
        self.pickerView = pickerView
        
        // Add sections to the array
        sections.append(feedDetails)
        sections.append(specifyFolder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOnSelectActions()
        setupBindings()
        
        navigationItem.title = viewModel.feedForUpdate.value != nil ? L10n.RssEditView.titleUpdate : L10n.RssEditView.titleCreate
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionBarButtonTapped(_:)))
    }
    
    private func setupOnSelectActions() {
        let specifyFolder = sections[1]
        specifyFolder.rows[0].onSelected = { [weak self] in
            self?.presentCreateFolderAlert()
        }
        
        specifyFolder.rows[1].onSelected = { [weak self] in
            let row = specifyFolder.rows[2]
            row.isHidden = !row.isHidden
            self?.folderNameLabel.textColor = row.isHidden ? UIColor.black : UIColor.red
        }
    }
    
    private func setupBindings() {
        feedNameField <~> viewModel.feedName
        linkField <~> viewModel.link
        
        pickerView.reactive.selectedRow(inComponent: 0) <~ viewModel.selectedFolder.map({ [weak self] selectedFolder -> Int in
            self?.pickerView.reloadAllComponents()
            if let index = self?.viewModel.folders.index(of: selectedFolder) {
                return index + 1
            } else {
                // Root folder
                return 0
            }
        })
        
        folderNameLabel.reactive.text <~ viewModel.selectedFolder.map({ (folder: Folder) -> String in
            return folder.title
        })
        
        viewModel.saveBtnAction.errors.producer.startWithValues { (errors) in
            //FIXME: Show error
            print("Error occured: \(errors)")
        }
        
        viewModel.saveBtnAction.completed
            .observe(on: UIScheduler()).observeValues { [weak self] _ in
                self?.flowDelegate?.editSuccessful(in: self!)
        }
    }
    
    @objc
    private func actionBarButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.saveBtnAction.apply().start()
    }
    
    private func presentCreateFolderAlert() {
        var textField = UITextField()
        
        let alert = UIAlertController(title: L10n.RssEditView.addFolderTitle, message: "", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: L10n.Base.actionCancel, style: .cancel)
        let actionDone = UIAlertAction(title: L10n.Base.actionDone, style: .default) { [weak self] (action) in
            self?.viewModel.createFolder(title: textField.text!)
            self?.pickerView.reloadAllComponents()
        }
        actionDone.isEnabled = false
        
        alert.addAction(actionDone)
        alert.addAction(actionCancel)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = L10n.RssEditView.folderNamePlaceholder
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
    
}

//MARK: UITableView Delegate and DataSource methods

extension RSSFeedEditVC: UITableViewDelegate, UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "rssFeedEditCell", for: indexPath)
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

//MARK: UIPickerView Delegate and DataSource methods

extension RSSFeedEditVC: UIPickerViewDelegate, UIPickerViewDataSource {
    /**
     Number of columns.
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    /**
     Number of rows.
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.folders.count + 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.getFolder(at: row).title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        folderNameLabel.text = viewModel.getFolder(at: row).title
    }
}

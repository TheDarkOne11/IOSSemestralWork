import UIKit
import SnapKit
import ReactiveSwift
import ReactiveCocoa
import RealmSwift

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
        let feedDetails = UITableView.Section(rows: 2, header: "Feed Details")
        let specifyFolder = UITableView.Section(rows: 3, header: "Specify Folder")
        
        // Create rows
        // Feed details rows
        let feedNameField = UITextField()
        feedDetails.rows[0].contentView = UIView().addSubViews(feedNameField)
        feedNameField.placeholder = "Name"
        feedNameField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.top.equalToSuperview().inset(8)
        }
        self.feedNameField = feedNameField
    
        let linkField = UITextField()
        feedDetails.rows[1].contentView = UIView().addSubViews(linkField)
        linkField.placeholder = "http://..."
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
        addFolderLabel.text = "Add a new Folder"
        addFolderLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.top.equalToSuperview().inset(8)
        }
        self.addFolderLabel = addFolderLabel
        
        let folderLabel = UILabel()
        let folderNameLabel = UILabel()
        specifyFolder.rows[1].contentView = UIView().addSubViews(folderLabel, folderNameLabel)
        folderLabel.text = "Folder:"
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
        
        navigationItem.title = "Edit RSS feed"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionBarButtonTapped(_:)))
    }
    
    private func setupOnSelectActions() {
        let specifyFolder = sections[1]
        specifyFolder.rows[0].onSelected = { [weak self] in
            self?.addFolderTapped()
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
        
        self.pickerView.reactive.selectedRow(inComponent: 0) <~ viewModel.selectedFolder.map({ [weak self] selectedFolder -> Int in
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
            print("Error occured: \(errors)")
        }
        
        viewModel.saveBtnAction.completed
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                print("SaveBtnCompleted")
        }
    }
    
    @objc
    private func actionBarButtonTapped(_ sender: UIBarButtonItem) {
        print("Done bar button tapped.")
        viewModel.saveBtnAction.apply().start()
    }
    
    private func addFolderTapped() {
        //TODO: Add folder
        fatalError("Not implemented")
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
        var rows = sections[indexPath.section].rows.filter { !$0.isHidden }
        
        if let view = rows[indexPath.row].contentView {
            cell.contentView.addSubview(view)
            view.snp.makeConstraints { make in
                make.top.bottom.leading.trailing.equalToSuperview()
            }
        } else {
            cell.textLabel?.text = "This is row \(indexPath.row)"
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

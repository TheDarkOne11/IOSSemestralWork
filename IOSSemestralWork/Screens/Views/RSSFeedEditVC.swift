import UIKit
import SnapKit
import ReactiveSwift
import RealmSwift

extension UIView {
    func addSubViews(_ subViews: UIView...) -> UIView {
        for subView in subViews {
            self.addSubview(subView)
        }
        
        return self
    }
}

struct Section {
    var rows: [UIView?]
    var header: String?
    var footer: String?
    
    init(rows: Int, header: String? = nil, footer: String? = nil) {
        self.rows = Array(repeating: nil, count: rows)
        self.header = header
        self.footer = footer
    }
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
    
    private var sections: [Section] = []
    
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
        
        //FIXME: Change to ItemCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "my")
        view.addSubview(tableView)
        self.tableView = tableView
        
        prepareRows()
    }
    
    private func prepareRows() {
        var feedDetails = Section(rows: 2, header: "Feed Details")
        var specifyFolder = Section(rows: 3, header: "Specify Folder")
        
        // Create rows
        // Feed details rows
        let feedNameField = UITextField()
        feedDetails.rows[0] = UIView().addSubViews(feedNameField)
        feedNameField.placeholder = "Name"
        feedNameField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.top.equalToSuperview().inset(8)
        }
        self.feedNameField = feedNameField
        
        let linkField = UITextField()
        feedDetails.rows[1] = UIView().addSubViews(linkField)
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
        specifyFolder.rows[0] = UIView().addSubViews(addFolderLabel)
        addFolderLabel.text = "Add a new Folder"
        addFolderLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.top.equalToSuperview().inset(8)
        }
        self.addFolderLabel = addFolderLabel
        
        let folderLabel = UILabel()
        let folderNameLabel = UILabel()
        specifyFolder.rows[1] = UIView().addSubViews(folderLabel, folderNameLabel)
        folderLabel.text = "Folder:"
        folderNameLabel.text = "TEMP"   //FIXME: Add folder name
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
        specifyFolder.rows[2] = UIView().addSubViews(pickerView)
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
        
        setupBindings()
        
        navigationItem.title = "Edit RSS feed"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionBarButtonTapped(_:)))
    }
    
    private func setupBindings() {
        let realm = try! Realm()
        let folder: Folder = realm.objects(Folder.self).filter("title == %@", "None").first!
        let feedForUpdate = realm.objects(MyRSSFeed.self).filter("title == %@", "Custom title").first
        
        viewModel.title.value = "Custom title"
        viewModel.link.value = "Custom link"
        viewModel.folder.value = folder
        viewModel.feedForUpdate.value = feedForUpdate
        
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
    
}

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
        //FIXME: Use Sections enum
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "my", for: indexPath)
        
        if let view = sections[indexPath.section].rows[indexPath.row] {
            cell.contentView.addSubview(view)
            view.snp.makeConstraints { make in
                make.top.bottom.leading.trailing.equalToSuperview()
            }
        } else {
            cell.textLabel?.text = "This is row \(indexPath.row)"
        }
        
        return cell
    }
    
    
}

//extension RSSFeedEditVC: UIPickerViewDelegate, UIPickerViewDataSource {
//    /**
//     Number of columns.
//     */
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    /**
//     Number of rows.
//     */
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if let folders = self.folders {
//            return folders.count + 1
//        }
//
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return getFolder(at: row).title
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        folderNameLabel.text = getFolder(at: row).title
//    }
//
//    /**
//     Selects the folder in the pickerView.
//     */
//    func selectPickerRow(for folder: Folder) {
//        folderNameLabel.text = folder.title
//
//        if folder.title == noneFolder.title {
//            picker.selectRow(0, inComponent: 0, animated: false)
//        } else {
//            guard let index = folders?.index(of: folder) else {
//                fatalError("The selected folder has to exist in Realm.")
//            }
//
//            picker.selectRow(index + 1, inComponent: 0, animated: false)
//        }
//    }
//}

import UIKit
import SnapKit
import ReactiveSwift
import RealmSwift

struct Section {
    var rows: Int
    var header: String?
    var footer: String?
    
    init(rows: Int, header: String? = nil, footer: String? = nil) {
        self.rows = rows
        self.header = header
        self.footer = footer
    }
}

class RSSFeedEditVC: BaseViewController {
    private let viewModel: IRSSFeedEditVM
    //    private weak var versionLabel: UILabel!
    private var tableView: UITableView!
    
    private let sections: [Section]
    
    init(_ viewModel: IRSSFeedEditVM) {
        self.viewModel = viewModel
        
        sections = [
            Section(rows: 2, header: "Feed Details"),
            Section(rows: 3, header: "Specify Folder")
        ]
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        
        tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.white
        
        //FIXME: Change to ItemCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "my")
        view.addSubview(tableView)
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

extension RSSFeedEditVC: UITableViewDelegate {
    
}

extension RSSFeedEditVC: UITableViewDataSource {
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
        return sections[section].rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "my", for: indexPath)
        cell.textLabel?.text = "This is row \(indexPath.row)"
        
        return cell
    }
    
    
}

import UIKit
import SnapKit
import ReactiveSwift
import RealmSwift

class ViewController: BaseViewController {
    private let viewModel: IRSSFeedEditVM
    
    private weak var versionLabel: UILabel!
    private weak var buildNumberLabel: UILabel!
    
    init(_ viewModel: IRSSFeedEditVM) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        let versionText = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
        let buildNumberText = (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? ""
        
        let versionLabel = UILabel()
        versionLabel.text = "\(L10n.Start.appVersion): \(versionText)"
        versionLabel.accessibilityIdentifier = "versionLabel"
        self.versionLabel = versionLabel
        
        let buildNumberLabel = UILabel()
        buildNumberLabel.text = "\(L10n.Start.buildNumber): \(buildNumberText)"
        buildNumberLabel.accessibilityIdentifier = "buildNumberLabel"
        self.buildNumberLabel = buildNumberLabel
        
        // ----- Stack View -----
        let stackView = UIStackView(arrangedSubviews: [versionLabel, buildNumberLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.leading.trailing.equalToSuperview().inset(48)
        }
        
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        
        navigationItem.title = "Custom Title"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionBarButtonTapped(_:)))
    }
    
    private func setupBindings() {
        let realm = try! Realm()
        let folder: Folder = realm.objects(Folder.self).filter("title == %@", "None").first!
        let feedForUpdate = realm.objects(MyRSSFeed.self).filter("title == %@", "Custom title").first
        
        viewModel.feedName.value = "Custom title"
        viewModel.link.value = "Custom link"
        viewModel.selectedFolder.value = folder
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


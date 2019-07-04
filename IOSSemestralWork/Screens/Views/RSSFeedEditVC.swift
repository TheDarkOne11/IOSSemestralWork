import UIKit
import SnapKit
import ReactiveSwift
import RealmSwift

class RSSFeedEditVC: BaseViewController {
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
        view.backgroundColor = .white
        
        
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


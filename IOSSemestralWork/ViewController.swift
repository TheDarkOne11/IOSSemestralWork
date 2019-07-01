//
//  ViewController.swift
//  mi-ios-2019
//
//  Created by Jan Misar on 19/02/2019.
//  Copyright © 2019 ČVUT. All rights reserved.
//

//import UIKit
//
//class ViewController: UIViewController {
//
//    @IBOutlet weak var versionLabel: UILabel!
//    @IBOutlet weak var buildNumberLabel: UILabel!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let versionText = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
//        let buildNumberText = (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? ""
//
//        versionLabel.text = "\(L10n.Start.appVersion): \(versionText)"
//        buildNumberLabel.text = "\(L10n.Start.buildNumber): \(buildNumberText)"
//    }
//
//
//}

//
//  ViewController.swift
//  mi-ios-2019
//
//  Created by Jan Misar on 19/02/2019.
//  Copyright © 2019 ČVUT. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    private weak var versionLabel: UILabel!
    private weak var buildNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        navigationItem.title = "Custom Title"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonTapped(_:)))
    }
    
    @objc
    private func doneBarButtonTapped(_ sender: UIBarButtonItem) {
        print("Done bar button tapped.")
    }
    
}


//
//  RSSItemVC.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 14/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveCocoa
import ReactiveSwift
import UIKit
import WebKit

class RSSItemVC: BaseViewController {
    private let viewModel: IRSSItemVM
    private weak var toolbar: UIToolbar!
    
    /**
     The WKWebView used to display data of RSSItems.
     It's created as singleton because creating its instance every time caused a significant delay.
     */
    private static var webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        
        // Load HTML template
        if let url = Bundle.main.url(forResource: "RSSItemFormat", withExtension: "html", subdirectory: "Web") {
            print("Loading webView")
            webView.loadFileURL(url, allowingReadAccessTo: url)
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }()
    
    init(_ viewModel: IRSSItemVM) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        view.addSubview(RSSItemVC.webView)
        
        self.toolbar = initBottomToolbar()
        
        RSSItemVC.webView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
            make.bottom.equalTo(toolbar.snp_top)
        }
        
        toolbar.snp.makeConstraints { make in
            make.trailing.leading.bottom.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        
        navigationItem.title = viewModel.selectedItem.value.rssFeed.first?.title
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonTapped(_:)))
    }
    
    //TODO: Make UIBarButtonItem with custom UIView to show title and image
    private func initBottomToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        view.addSubview(toolbar)
        
        let readButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(readBarButtonTapped(_:)))
        readButton.reactive.image <~ viewModel.selectedItem.producer.map({ rssItem -> UIImage in
            let asset = rssItem.isRead ? Asset.tabRead : Asset.tabUnread
            return UIImage(asset: asset)
        })
        
        let starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(starBarButtonTapped(_:)))
        starButton.reactive.image <~ viewModel.selectedItem.producer.map({ rssItem -> UIImage in
            let asset = rssItem.isStarred ? Asset.tabStarred : Asset.tabUnstarred
            return UIImage(asset: asset)
        })
        
        let upButton = UIBarButtonItem(image: UIImage(asset: Asset.tabUp), style: .plain, target: self, action: #selector(upBarButtonTapped(_:)))
        
        let downButton = UIBarButtonItem(image: UIImage(asset: Asset.tabDown), style: .plain, target: self, action: #selector(downBarButtonTapped(_:)))
        
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.items = [readButton, flexibleSpace, starButton, flexibleSpace, upButton, flexibleSpace, downButton]
        
        return toolbar
    }
    
    private func setupBindings() {
        
    }
    
    @objc
    private func readBarButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @objc
    private func starBarButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @objc
    private func upBarButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @objc
    private func downBarButtonTapped(_ sender: UIBarButtonItem) {
        
    }
}

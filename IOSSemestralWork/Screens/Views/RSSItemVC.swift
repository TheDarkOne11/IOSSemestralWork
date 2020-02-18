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
import Resources

class RSSItemVC: BaseViewController {
    private let viewModel: IRSSItemVM
    private weak var toolbar: UIToolbar!
    private weak var readButton: UIBarButtonItem!
    private weak var starButton: UIBarButtonItem!
    private weak var upButton: UIBarButtonItem!
    private weak var downButton: UIBarButtonItem!
    
    /**
     The WKWebView used to display data of RSSItems.
     It's created as singleton because creating its instance every time caused a significant delay.
     */
    private static var webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        
        // Load HTML template
        if let url = Bundle.resources.url(forResource: "RSSItemFormat", withExtension: "html") {
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
        RSSItemVC.webView.navigationDelegate = self
        
        self.toolbar = initBottomToolbar()
        
        RSSItemVC.webView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
            make.bottom.equalTo(toolbar.snp.top)
        }
        
        toolbar.snp.makeConstraints { make in
            make.trailing.leading.bottom.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(asset: Asset.toWebsite), style: .plain, target: self, action: #selector(toWebsiteButtonTapped(_:)))
    }
    
    //TODO: Make UIBarButtonItem with custom UIView to show title and image
    private func initBottomToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        view.addSubview(toolbar)
        
        let readButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(readBarButtonTapped(_:)))
        let starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(starBarButtonTapped(_:)))
        let upButton = UIBarButtonItem(image: UIImage(asset: Asset.tabUp), style: .plain, target: self, action: #selector(upBarButtonTapped(_:)))
        let downButton = UIBarButtonItem(image: UIImage(asset: Asset.tabDown), style: .plain, target: self, action: #selector(downBarButtonTapped(_:)))
        
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.items = [readButton, flexibleSpace, starButton, flexibleSpace, upButton, flexibleSpace, downButton]
        
        self.readButton = readButton
        self.starButton = starButton
        self.upButton = upButton
        self.downButton = downButton
        
        return toolbar
    }
    
    private func setupBindings() {
        viewModel.selectedItem.producer.startWithValues { _ in RSSItemVC.webView.reload() }
        
        readButton.reactive.image <~ viewModel.selectedItem.producer.map({ rssItem -> UIImage in
            let asset = rssItem.isRead ? Asset.tabRead : Asset.tabUnread
            return UIImage(asset: asset)
        })
        
        starButton.reactive.image <~ viewModel.selectedItem.producer.map({ rssItem -> UIImage in
            return UIImage(asset: (rssItem.isStarred ? Asset.tabStarred : Asset.tabUnstarred))
        })
        
        upButton.reactive.isEnabled <~ viewModel.canGoUp
        downButton.reactive.isEnabled <~ viewModel.canGoDown
        navigationItem.reactive.title <~ viewModel.selectedItem.map({ rssItem -> String in
            return rssItem.rssFeed.first?.title ?? ""
        })
    }
    
    // MARK: Bar buttons
    
    @objc
    private func readBarButtonTapped(_ sender: UIBarButtonItem) {
        let newValue = !viewModel.selectedItem.value.isRead
        viewModel.set(isRead: newValue)
        
        readButton.image = UIImage(asset: newValue ? Asset.tabRead : Asset.tabUnread)
    }
    
    @objc
    private func starBarButtonTapped(_ sender: UIBarButtonItem) {
        let newValue = !viewModel.selectedItem.value.isStarred
        viewModel.set(isStarred: newValue)
        
        starButton.image = UIImage(asset: newValue ? Asset.tabStarred : Asset.tabUnstarred)
    }
    
    @objc
    private func upBarButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.goUp()
    }
    
    @objc
    private func downBarButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.goDown()
    }
    
    @objc
    private func toWebsiteButtonTapped(_ sender: UIBarButtonItem) {
        if let link = viewModel.selectedItem.value.articleLink {
            goToWeb(url: URL(string: link))
        }
    }
}

// MARK: WKNavigationDelegate

extension RSSItemVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            // A link inside the webView was clicked
            goToWeb(url: navigationAction.request.url)
            
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    /**
     Opens the URL of the current RSSItem in the Safari app browser.
     */
    private func goToWeb(url: URL?) {
        if let url = url {
            UIApplication.shared.open(url)
        }
    }
    
    /**
     Loads new RSSItem data in the HTML template using a Javascript script.
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        RSSItemVC.webView.evaluateJavaScript(viewModel.getScriptCode()) { (result, error) in
            if let error = error {
                print("Error occured when passing data to WKWebView: \(error)")
            }
        }
        
    }
}

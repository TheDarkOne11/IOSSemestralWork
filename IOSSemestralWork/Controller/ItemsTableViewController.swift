//
//  ItemsTableViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireRSSParser
import NavigationDrawer

class ItemsTableViewController: UITableViewController {
    let interactor = Interactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        fetchData()
    }
    
//    func fetchData() {
//        let url = "http://servis.idnes.cz/rss.aspx?c=zpravodaj"
//
//        Alamofire.request(url).responseRSS() { (response) -> Void in
//            if let feed: RSSFeed = response.result.value {
//                //do something with your new RSSFeed object!
//                for item in feed.items {
//                    let myItem = MyRSSItem()
//                    myItem.title = item.title ?? "Unknown"
//                    myItem.link = item.link ?? "Unknown"
//                    myItem.author = item.author ?? "Unknown"
//                    myItem.itemDescription = item.itemDescription ?? "Unknown"
//
//                    print(item)
//                }
//            }
//        }
//    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        return cell
    }
    
    // MARK: TableView methods
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}

// MARK: NavigationDrawer

extension ItemsTableViewController: UIViewControllerTransitioningDelegate {
    @IBAction func navDrawerPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showSlidingMenu", sender: nil)
    }
    
    @IBAction func edgePanGesture(_ sender: UIPanGestureRecognizer) {        
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.performSegue(withIdentifier: "showSlidingMenu", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SlidingViewController {
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = self.interactor
        }
    }
    
    // MARK: UIViewControllerTransitioningDelegate functions
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

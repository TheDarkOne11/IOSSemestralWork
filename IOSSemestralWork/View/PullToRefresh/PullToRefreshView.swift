//
//  PullToRefreshView.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 27/01/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import UIKit
import Foundation

class PullToRefreshView: UIView {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let defaults = UserDefaults.standard
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.hidesWhenStopped = true
    }
    
    func startUpdating() {
        activityIndicator.startAnimating()
    }
    
    func stopUpdating() {
        activityIndicator.stopAnimating()
    }
    
    /**
     Updates infoLabels text according to the date when the last update occured
     */
    public func updateLabelText() {
        let date = defaults.object(forKey: "LastUpdate") as! NSDate
        let minuteAgo = Date(timeIntervalSinceNow: -60)
        let hourAgo = Date(timeIntervalSinceNow: -3600)
        let yesterday = Date(timeIntervalSinceNow: -3600*24)
        let weekAgo = Date(timeIntervalSinceNow: -3600*24*7)
        
        let timeDifSeconds: Int = Int(-date.timeIntervalSinceNow)
        
        // Within 1 min
        if date.compare(minuteAgo) == .orderedDescending {
            infoLabel.text = "Last update: < 1 minute ago"
            return
        }
        
        // Within 1 hour
        if date.compare(hourAgo) == .orderedDescending {
            let minDif = timeDifSeconds/60
            if minDif == 1 {
                infoLabel.text = "Last update: a minute ago"
            } else {
                infoLabel.text = "Last update: \(minDif) minutes ago"
            }
            return
        }
        
        // Within 1 day
        if date.compare(yesterday) == .orderedDescending {
            let hourDif = timeDifSeconds/3600
            if hourDif == 1 {
                infoLabel.text = "Last update: an hour ago"
            } else {
                infoLabel.text = "Last update: \(hourDif) hours ago"
            }
            return
        }
        
        // Within 1 week
        if date.compare(weekAgo) == .orderedDescending {
            let dayDif = timeDifSeconds/(3600*24)
            if dayDif == 1 {
                infoLabel.text = "Last update: yesterday"
            } else {
                infoLabel.text = "Last update: \(dayDif) days ago"
            }
            return
        }
        
        // Last update: earlier
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_GB")  // "cs_CZ"
        
        infoLabel.text = "Last update was " + formatter.string(from: date as Date)
    }
}

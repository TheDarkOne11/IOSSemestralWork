//
//  Globals.swift
//  Data
//
//  Created by Petr Budík on 20/02/2020.
//  Copyright © 2020 Petr Budík. All rights reserved.
//

import Foundation

public typealias AllDependencies = HasRepository & HasTitleValidator & HasItemCreateableValidator
    & HasRSSFeedResponseValidator & HasUserDefaults
    & HasUserDefaults & HasRealm

public class Globals {
    /**
     Returns true when the scheme is set to production. Otherwise false.
     */
    public static let isProduction : Bool = {
        #if DEBUG
            print("DEBUG")
            let dic = ProcessInfo.processInfo.environment
            if let forceProduction = dic["forceProduction"] , forceProduction == "true" {
                return true
            }
            return false
        
        #else
            print("PRODUCTION")
            return true
        #endif
    }()
    
    public static let isUITesting = ProcessInfo.processInfo.arguments.contains("--uitesting")
    
    public static let dependencies: AllDependencies = {
        if Globals.isUITesting {
            return TestDependency()
        } else {
            return AppDependency.shared
        }
    }()
}

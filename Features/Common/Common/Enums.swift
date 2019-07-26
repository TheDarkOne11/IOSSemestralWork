//
//  Errors.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 02/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation

public enum RealmObjectError: Error {
    case unknown
    case exists
    case titleInvalid
}

public enum DownloadStatus: String {
    case OK
    case emptyFeed
    case unreachable
    case doesNotExist
    case notRSSFeed
}

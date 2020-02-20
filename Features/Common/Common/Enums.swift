//
//  Errors.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 02/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation

/**
 All possible error states that can happen when using Realm objects.
 */
public enum RealmObjectError: Error {
    case unknown
    case exists
    case titleInvalid
}

/**
 All possible states that can happen when new `MyRSSItem`s are being downloaded.
 */
public enum DownloadStatus: String {
    case OK
    case emptyFeed
    case unreachable
    case doesNotExist
    case notRSSFeed
}

// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Base {
    /// Cancel
    internal static let actionCancel = L10n.tr("Localizable", "base.actionCancel")
    /// Done
    internal static let actionDone = L10n.tr("Localizable", "base.actionDone")
    /// Edit
    internal static let actionEdit = L10n.tr("Localizable", "base.actionEdit")
    /// Remove
    internal static let actionRemove = L10n.tr("Localizable", "base.actionRemove")
    /// All items
    internal static let allItems = L10n.tr("Localizable", "base.allItems")
    /// App version
    internal static let appVersion = L10n.tr("Localizable", "base.app_version")
    /// Build number
    internal static let buildNumber = L10n.tr("Localizable", "base.build_number")
    /// None
    internal static let rootFolder = L10n.tr("Localizable", "base.rootFolder")
    /// Starred items
    internal static let starredItems = L10n.tr("Localizable", "base.starredItems")
    /// Unread items
    internal static let unreadItems = L10n.tr("Localizable", "base.unreadItems")
  }

  internal enum Error {
    /// Internet is unreachable. Please try updating later.
    internal static let internetUnreachable = L10n.tr("Localizable", "error.internetUnreachable")
  }

  internal enum ItemTableView {
    /// RSSFeed reader
    internal static let baseTitle = L10n.tr("Localizable", "itemTableView.baseTitle")
    /// Edit folder
    internal static let editFolderTitle = L10n.tr("Localizable", "itemTableView.editFolderTitle")
    /// Folder name
    internal static let folderNamePlaceholder = L10n.tr("Localizable", "itemTableView.folderNamePlaceholder")
  }

  internal enum RssEditView {
    /// Add a new Folder
    internal static let addFolder = L10n.tr("Localizable", "rssEditView.addFolder")
    /// Create folder
    internal static let addFolderTitle = L10n.tr("Localizable", "rssEditView.addFolderTitle")
    /// Feed Details
    internal static let feedDetails = L10n.tr("Localizable", "rssEditView.feedDetails")
    /// Folder:
    internal static let folderLabel = L10n.tr("Localizable", "rssEditView.folderLabel")
    /// Folder name
    internal static let folderNamePlaceholder = L10n.tr("Localizable", "rssEditView.folderNamePlaceholder")
    /// http://
    internal static let linkPlaceholder = L10n.tr("Localizable", "rssEditView.linkPlaceholder")
    /// Name
    internal static let namePlaceholder = L10n.tr("Localizable", "rssEditView.namePlaceholder")
    /// Specify Folder
    internal static let specifyFolder = L10n.tr("Localizable", "rssEditView.specifyFolder")
    /// Add RSS feed
    internal static let titleCreate = L10n.tr("Localizable", "rssEditView.titleCreate")
    /// Edit RSS feed
    internal static let titleUpdate = L10n.tr("Localizable", "rssEditView.titleUpdate")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}

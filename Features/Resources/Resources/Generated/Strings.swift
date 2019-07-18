// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum L10n {

  public enum Base {
    /// Cancel
    public static let actionCancel = L10n.tr("Localizable", "base.actionCancel")
    /// Done
    public static let actionDone = L10n.tr("Localizable", "base.actionDone")
    /// Edit
    public static let actionEdit = L10n.tr("Localizable", "base.actionEdit")
    /// Remove
    public static let actionRemove = L10n.tr("Localizable", "base.actionRemove")
    /// All items
    public static let allItems = L10n.tr("Localizable", "base.allItems")
    /// App version
    public static let appVersion = L10n.tr("Localizable", "base.app_version")
    /// Build number
    public static let buildNumber = L10n.tr("Localizable", "base.build_number")
    /// None
    public static let rootFolder = L10n.tr("Localizable", "base.rootFolder")
    /// Starred items
    public static let starredItems = L10n.tr("Localizable", "base.starredItems")
    /// Unread items
    public static let unreadItems = L10n.tr("Localizable", "base.unreadItems")
  }

  public enum Error {
    /// Internet is unreachable. Please try updating later.
    public static let internetUnreachable = L10n.tr("Localizable", "error.internetUnreachable")
  }

  public enum ItemTableView {
    /// RSSFeed reader
    public static let baseTitle = L10n.tr("Localizable", "itemTableView.baseTitle")
    /// Edit folder
    public static let editFolderTitle = L10n.tr("Localizable", "itemTableView.editFolderTitle")
    /// Folder name
    public static let folderNamePlaceholder = L10n.tr("Localizable", "itemTableView.folderNamePlaceholder")
  }

  public enum MyRssItem {
    /// No description provided
    public static let missingDescription = L10n.tr("Localizable", "myRssItem.missingDescription")
    /// No title provided
    public static let missingTitle = L10n.tr("Localizable", "myRssItem.missingTitle")
  }

  public enum RssEditView {
    /// Add a new Folder
    public static let addFolder = L10n.tr("Localizable", "rssEditView.addFolder")
    /// Create folder
    public static let addFolderTitle = L10n.tr("Localizable", "rssEditView.addFolderTitle")
    /// Feed Details
    public static let feedDetails = L10n.tr("Localizable", "rssEditView.feedDetails")
    /// Folder:
    public static let folderLabel = L10n.tr("Localizable", "rssEditView.folderLabel")
    /// Folder name
    public static let folderNamePlaceholder = L10n.tr("Localizable", "rssEditView.folderNamePlaceholder")
    /// http://
    public static let linkPlaceholder = L10n.tr("Localizable", "rssEditView.linkPlaceholder")
    /// Name
    public static let namePlaceholder = L10n.tr("Localizable", "rssEditView.namePlaceholder")
    /// Specify Folder
    public static let specifyFolder = L10n.tr("Localizable", "rssEditView.specifyFolder")
    /// Add RSS feed
    public static let titleCreate = L10n.tr("Localizable", "rssEditView.titleCreate")
    /// Edit RSS feed
    public static let titleUpdate = L10n.tr("Localizable", "rssEditView.titleUpdate")
  }

  public enum RssItemVM {
    /// by %@
    public static func authorPart(_ p1: String) -> String {
      return L10n.tr("Localizable", "rssItemVM.authorPart", p1)
    }
    /// Published %@
    public static func timeString(_ p1: String) -> String {
      return L10n.tr("Localizable", "rssItemVM.timeString", p1)
    }
  }

  public enum TodayVC {
    /// Starred items: %@
    public static func starredLabel(_ p1: String) -> String {
      return L10n.tr("Localizable", "todayVC.starredLabel", p1)
    }
    /// Unread items: %@
    public static func unreadLabel(_ p1: String) -> String {
      return L10n.tr("Localizable", "todayVC.unreadLabel", p1)
    }
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

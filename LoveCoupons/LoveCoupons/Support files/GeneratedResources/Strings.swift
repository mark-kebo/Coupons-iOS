// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  /// An error has occurred; try again later
  internal static let apiDefaultError = L10n.tr("Localizable", "api default error")

  internal enum Alert {
    /// No Internet connection
    internal static let noInternetConnection = L10n.tr("Localizable", "alert.noInternetConnection")
    internal enum Button {
      /// Cancel
      internal static let cancel = L10n.tr("Localizable", "alert.button.cancel")
    }
    internal enum Info {
      internal enum Offline {
        /// Cannot detect your internet connection. Please makes sure you have a valid connection and try again
        internal static let message = L10n.tr("Localizable", "alert.info.offline.message")
      }
    }
    internal enum Offline {
      /// Offline
      internal static let title = L10n.tr("Localizable", "alert.offline.title")
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

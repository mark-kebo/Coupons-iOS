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
  /// Error
  internal static let error = L10n.tr("Localizable", "error")
  /// Fill in all the fields
  internal static let errorFields = L10n.tr("Localizable", "error fields")
  /// Loading...
  internal static let indicator = L10n.tr("Localizable", "indicator")
  /// No internet connection.\nPlease connect and try again
  internal static let noInternetConnection = L10n.tr("Localizable", "noInternetConnection")

  internal enum Alert {
    /// Coupons not found
    internal static let coupons = L10n.tr("Localizable", "alert.coupons")
    /// Can't send emails from this device
    internal static let mail = L10n.tr("Localizable", "alert.mail")
    /// No Internet connection
    internal static let noInternetConnection = L10n.tr("Localizable", "alert.noInternetConnection")
    /// A password reset link has been sent to your email address
    internal static let resetPassword = L10n.tr("Localizable", "alert.resetPassword")
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
    internal enum Success {
      /// Success
      internal static let title = L10n.tr("Localizable", "alert.success.title")
    }
  }

  internal enum Button {
    /// Add
    internal static let add = L10n.tr("Localizable", "button.add")
    /// Delete
    internal static let delete = L10n.tr("Localizable", "button.delete")
    /// Edit
    internal static let edit = L10n.tr("Localizable", "button.edit")
    /// Reload app
    internal static let refresh = L10n.tr("Localizable", "button.refresh")
  }

  internal enum Coupon {
    /// New Coupon
    internal static let add = L10n.tr("Localizable", "coupon.add")
    /// Coupon
    internal static let title = L10n.tr("Localizable", "coupon.title")
    /// Use coupon
    internal static let use = L10n.tr("Localizable", "coupon.use")
  }

  internal enum LoginSignUp {
    /// Email
    internal static let email = L10n.tr("Localizable", "login&SignUp.email")
    /// Your pair unique id
    internal static let id = L10n.tr("Localizable", "login&SignUp.id")
    /// Your name
    internal static let name = L10n.tr("Localizable", "login&SignUp.name")
    /// Password
    internal static let password = L10n.tr("Localizable", "login&SignUp.password")
    /// Love Coupons
    internal static let title = L10n.tr("Localizable", "login&SignUp.title")
    internal enum Button {
      /// Create
      internal static let create = L10n.tr("Localizable", "login&SignUp.button.create")
      /// Login
      internal static let login = L10n.tr("Localizable", "login&SignUp.button.login")
      /// Restore password
      internal static let restPassword = L10n.tr("Localizable", "login&SignUp.button.restPassword")
      /// Send
      internal static let send = L10n.tr("Localizable", "login&SignUp.button.send")
      /// Sign up
      internal static let signUp = L10n.tr("Localizable", "login&SignUp.button.signUp")
    }
  }

  internal enum Mail {
    /// Coupon Request ❤️
    internal static let subject = L10n.tr("Localizable", "mail.subject")
  }

  internal enum MyCoupons {
    /// My Coupons
    internal static let title = L10n.tr("Localizable", "myCoupons.title")
  }

  internal enum PairCoupons {
    /// Pair Coupons
    internal static let title = L10n.tr("Localizable", "pairCoupons.title")
  }

  internal enum Settings {
    /// Logout
    internal static let logout = L10n.tr("Localizable", "settings.logout")
    /// Submit
    internal static let submit = L10n.tr("Localizable", "settings.submit")
    /// Settings
    internal static let tab = L10n.tr("Localizable", "settings.tab")
    /// Your unique id:
    internal static let yourId = L10n.tr("Localizable", "settings.yourId")
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

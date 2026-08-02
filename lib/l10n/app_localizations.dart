import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'BAROM.ME'**
  String get appName;

  /// No description provided for @signInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @pleaseEnterEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get pleaseEnterEmailAndPassword;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @leaves.
  ///
  /// In en, this message translates to:
  /// **'Leaves'**
  String get leaves;

  /// No description provided for @approvals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvals;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @khmer.
  ///
  /// In en, this message translates to:
  /// **'Khmer'**
  String get khmer;

  /// No description provided for @telegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get telegram;

  /// No description provided for @connectTelegramForNotifications.
  ///
  /// In en, this message translates to:
  /// **'Connect Telegram for notifications'**
  String get connectTelegramForNotifications;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @lockAppWithPinAndBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Lock app with PIN and biometrics'**
  String get lockAppWithPinAndBiometrics;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// No description provided for @pinAndBiometricsLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN + biometrics'**
  String get pinAndBiometricsLabel;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @useFaceFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Use Face / Fingerprint'**
  String get useFaceFingerprint;

  /// No description provided for @noBiometricsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No biometrics available on this device'**
  String get noBiometricsAvailable;

  /// No description provided for @manageBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Add / manage fingerprint or face'**
  String get manageBiometrics;

  /// No description provided for @openPhoneSecurityToEnroll.
  ///
  /// In en, this message translates to:
  /// **'Open your phone\'s security settings to enroll'**
  String get openPhoneSecurityToEnroll;

  /// No description provided for @disableAppLock.
  ///
  /// In en, this message translates to:
  /// **'Disable App Lock?'**
  String get disableAppLock;

  /// No description provided for @disableAppLockMessage.
  ///
  /// In en, this message translates to:
  /// **'Your PIN and biometric setting will be removed.'**
  String get disableAppLockMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @addFingerprintOrFace.
  ///
  /// In en, this message translates to:
  /// **'Add fingerprint or face'**
  String get addFingerprintOrFace;

  /// No description provided for @iosEnrollInstructions.
  ///
  /// In en, this message translates to:
  /// **'On iOS, enroll your biometrics here:\n\nSettings → Face ID & Passcode (or Touch ID & Passcode) → Enroll a Face / Fingerprint.'**
  String get iosEnrollInstructions;

  /// No description provided for @androidEnrollInstructions.
  ///
  /// In en, this message translates to:
  /// **'Open your phone\'s Settings → Security → Fingerprint (or Face Unlock) and follow the on-screen steps to enroll.'**
  String get androidEnrollInstructions;

  /// No description provided for @setAppLockPin.
  ///
  /// In en, this message translates to:
  /// **'Set App Lock PIN'**
  String get setAppLockPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @chooseFourDigitPin.
  ///
  /// In en, this message translates to:
  /// **'Choose a 4-digit PIN to lock this app'**
  String get chooseFourDigitPin;

  /// No description provided for @reenterSamePin.
  ///
  /// In en, this message translates to:
  /// **'Re-enter the same PIN to confirm'**
  String get reenterSamePin;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Try again.'**
  String get pinsDoNotMatch;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @appIsLocked.
  ///
  /// In en, this message translates to:
  /// **'BAROM.ME is locked'**
  String get appIsLocked;

  /// No description provided for @placeFingerToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Place your finger to unlock'**
  String get placeFingerToUnlock;

  /// No description provided for @enterPinOrUseBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN or use biometrics'**
  String get enterPinOrUseBiometrics;

  /// No description provided for @enterPinToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to unlock'**
  String get enterPinToUnlock;

  /// No description provided for @incorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Try again.'**
  String get incorrectPin;

  /// No description provided for @biometricAuthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed. Use your PIN.'**
  String get biometricAuthenticationFailed;

  /// No description provided for @notRecognizedTapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Not recognized. Tap to try again.'**
  String get notRecognizedTapToRetry;

  /// No description provided for @reAddFingerprintHint.
  ///
  /// In en, this message translates to:
  /// **'Not recognizing? Re-add your fingerprint in Settings → Security → Fingerprint.'**
  String get reAddFingerprintHint;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @enterPinInstead.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN instead'**
  String get enterPinInstead;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPin;

  /// No description provided for @tapAgainToSignOutResetPin.
  ///
  /// In en, this message translates to:
  /// **'Tap again to sign out & reset PIN'**
  String get tapAgainToSignOutResetPin;

  /// No description provided for @connectTelegram.
  ///
  /// In en, this message translates to:
  /// **'Connect Telegram'**
  String get connectTelegram;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @couldNotOpenTelegram.
  ///
  /// In en, this message translates to:
  /// **'Could not open Telegram. Try again.'**
  String get couldNotOpenTelegram;

  /// No description provided for @telegramConnected.
  ///
  /// In en, this message translates to:
  /// **'Telegram Connected'**
  String get telegramConnected;

  /// No description provided for @telegramConnectedDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive leave status updates and notifications via Telegram.'**
  String get telegramConnectedDescription;

  /// No description provided for @openTelegramAndLink.
  ///
  /// In en, this message translates to:
  /// **'Open Telegram & Link'**
  String get openTelegramAndLink;

  /// No description provided for @failedToDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Failed to disconnect'**
  String get failedToDisconnect;

  /// No description provided for @telegramBotNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Telegram bot not configured by your company.'**
  String get telegramBotNotConfigured;

  /// No description provided for @disconnectTelegram.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Telegram'**
  String get disconnectTelegram;

  /// No description provided for @disconnectTelegramTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Telegram?'**
  String get disconnectTelegramTitle;

  /// No description provided for @disconnectTelegramMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Telegram account will be unlinked. You can reconnect later with another account.'**
  String get disconnectTelegramMessage;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @linkTelegramDescription.
  ///
  /// In en, this message translates to:
  /// **'Link your Telegram account to receive notifications about your leave requests.'**
  String get linkTelegramDescription;

  /// No description provided for @afterOpeningTelegramInstruction.
  ///
  /// In en, this message translates to:
  /// **'After opening Telegram, press Start on the chat with our bot to link your account. Return here and your status will update automatically.'**
  String get afterOpeningTelegramInstruction;

  /// No description provided for @myAttendance.
  ///
  /// In en, this message translates to:
  /// **'My Attendance'**
  String get myAttendance;

  /// No description provided for @todaysLocation.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Location'**
  String get todaysLocation;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @failedToGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Failed to get location'**
  String get failedToGetLocation;

  /// No description provided for @myLeaves.
  ///
  /// In en, this message translates to:
  /// **'My Leaves'**
  String get myLeaves;

  /// No description provided for @noLeaveRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'No leave requests yet'**
  String get noLeaveRequestsYet;

  /// No description provided for @tapPlusToCreateOne.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create one'**
  String get tapPlusToCreateOne;

  /// No description provided for @cancelLeave.
  ///
  /// In en, this message translates to:
  /// **'Cancel Leave'**
  String get cancelLeave;

  /// No description provided for @areYouSureCancelLeave.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel the {leaveType} request?'**
  String areYouSureCancelLeave(Object leaveType);

  /// No description provided for @leaveRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Leave request cancelled'**
  String get leaveRequestCancelled;

  /// No description provided for @failedToCancel.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel'**
  String get failedToCancel;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @inReview.
  ///
  /// In en, this message translates to:
  /// **'In Review'**
  String get inReview;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @newLeaveRequest.
  ///
  /// In en, this message translates to:
  /// **'New Leave Request'**
  String get newLeaveRequest;

  /// No description provided for @leaveTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Leave Type *'**
  String get leaveTypeRequired;

  /// No description provided for @dateRangeRequired.
  ///
  /// In en, this message translates to:
  /// **'Date Range *'**
  String get dateRangeRequired;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Reason *'**
  String get reasonRequired;

  /// No description provided for @phoneOrEmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone number or email (optional)'**
  String get phoneOrEmailOptional;

  /// No description provided for @selectLeaveType.
  ///
  /// In en, this message translates to:
  /// **'Select leave type'**
  String get selectLeaveType;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @contactDuringLeave.
  ///
  /// In en, this message translates to:
  /// **'Contact During Leave'**
  String get contactDuringLeave;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @halfDay.
  ///
  /// In en, this message translates to:
  /// **'Half Day'**
  String get halfDay;

  /// No description provided for @enterReasonForLeave.
  ///
  /// In en, this message translates to:
  /// **'Enter reason for leave'**
  String get enterReasonForLeave;

  /// No description provided for @pleaseSelectLeaveType.
  ///
  /// In en, this message translates to:
  /// **'Please select a leave type'**
  String get pleaseSelectLeaveType;

  /// No description provided for @pleaseSelectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Please select start date'**
  String get pleaseSelectStartDate;

  /// No description provided for @pleaseSelectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Please select end date'**
  String get pleaseSelectEndDate;

  /// No description provided for @pleaseEnterReason.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason'**
  String get pleaseEnterReason;

  /// No description provided for @leaveRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Leave request submitted successfully'**
  String get leaveRequestSubmitted;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @leaveDetails.
  ///
  /// In en, this message translates to:
  /// **'Leave Details'**
  String get leaveDetails;

  /// No description provided for @leaveRequest.
  ///
  /// In en, this message translates to:
  /// **'Leave Request'**
  String get leaveRequest;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @leaveType.
  ///
  /// In en, this message translates to:
  /// **'Leave Type'**
  String get leaveType;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @adminRemark.
  ///
  /// In en, this message translates to:
  /// **'Admin Remark'**
  String get adminRemark;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @cancelThisRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel This Request'**
  String get cancelThisRequest;

  /// No description provided for @leaveCancelled.
  ///
  /// In en, this message translates to:
  /// **'Leave cancelled'**
  String get leaveCancelled;

  /// No description provided for @myApprovals.
  ///
  /// In en, this message translates to:
  /// **'My Approvals'**
  String get myApprovals;

  /// No description provided for @approvalsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Approvals coming soon'**
  String get approvalsComingSoon;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

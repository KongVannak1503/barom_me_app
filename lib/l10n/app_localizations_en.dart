// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BAROM.ME';

  @override
  String get signInToAccount => 'Sign in to your account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get pleaseEnterEmailAndPassword => 'Please enter email and password';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get attendance => 'Attendance';

  @override
  String get leaves => 'Leaves';

  @override
  String get approvals => 'Approvals';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get khmer => 'Khmer';

  @override
  String get telegram => 'Telegram';

  @override
  String get connectTelegramForNotifications =>
      'Connect Telegram for notifications';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light mode';

  @override
  String get signOut => 'Sign Out';

  @override
  String get appLock => 'App Lock';

  @override
  String get lockAppWithPinAndBiometrics => 'Lock app with PIN and biometrics';

  @override
  String get pinLabel => 'PIN';

  @override
  String get pinAndBiometricsLabel => 'PIN + biometrics';

  @override
  String get changePin => 'Change PIN';

  @override
  String get useFaceFingerprint => 'Use Face / Fingerprint';

  @override
  String get noBiometricsAvailable => 'No biometrics available on this device';

  @override
  String get manageBiometrics => 'Add / manage fingerprint or face';

  @override
  String get openPhoneSecurityToEnroll =>
      'Open your phone\'s security settings to enroll';

  @override
  String get disableAppLock => 'Disable App Lock?';

  @override
  String get disableAppLockMessage =>
      'Your PIN and biometric setting will be removed.';

  @override
  String get cancel => 'Cancel';

  @override
  String get disable => 'Disable';

  @override
  String get ok => 'OK';

  @override
  String get addFingerprintOrFace => 'Add fingerprint or face';

  @override
  String get iosEnrollInstructions =>
      'On iOS, enroll your biometrics here:\n\nSettings → Face ID & Passcode (or Touch ID & Passcode) → Enroll a Face / Fingerprint.';

  @override
  String get androidEnrollInstructions =>
      'Open your phone\'s Settings → Security → Fingerprint (or Face Unlock) and follow the on-screen steps to enroll.';

  @override
  String get setAppLockPin => 'Set App Lock PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get chooseFourDigitPin => 'Choose a 4-digit PIN to lock this app';

  @override
  String get reenterSamePin => 'Re-enter the same PIN to confirm';

  @override
  String get pinsDoNotMatch => 'PINs do not match. Try again.';

  @override
  String get delete => 'Delete';

  @override
  String get appIsLocked => 'BAROM.ME is locked';

  @override
  String get placeFingerToUnlock => 'Place your finger to unlock';

  @override
  String get enterPinOrUseBiometrics => 'Enter your PIN or use biometrics';

  @override
  String get enterPinToUnlock => 'Enter your PIN to unlock';

  @override
  String get incorrectPin => 'Incorrect PIN. Try again.';

  @override
  String get biometricAuthenticationFailed =>
      'Biometric authentication failed. Use your PIN.';

  @override
  String get notRecognizedTapToRetry => 'Not recognized. Tap to try again.';

  @override
  String get reAddFingerprintHint =>
      'Not recognizing? Re-add your fingerprint in Settings → Security → Fingerprint.';

  @override
  String get scanning => 'Scanning...';

  @override
  String get enterPinInstead => 'Enter PIN instead';

  @override
  String get forgotPin => 'Forgot PIN?';

  @override
  String get tapAgainToSignOutResetPin => 'Tap again to sign out & reset PIN';

  @override
  String get connectTelegram => 'Connect Telegram';

  @override
  String get connected => 'Connected';

  @override
  String get retry => 'Retry';

  @override
  String get somethingWentWrong => 'Something went wrong.';

  @override
  String get couldNotOpenTelegram => 'Could not open Telegram. Try again.';

  @override
  String get telegramConnected => 'Telegram Connected';

  @override
  String get telegramConnectedDescription =>
      'You\'ll receive leave status updates and notifications via Telegram.';

  @override
  String get openTelegramAndLink => 'Open Telegram & Link';

  @override
  String get failedToDisconnect => 'Failed to disconnect';

  @override
  String get telegramBotNotConfigured =>
      'Telegram bot not configured by your company.';

  @override
  String get disconnectTelegram => 'Disconnect Telegram';

  @override
  String get disconnectTelegramTitle => 'Disconnect Telegram?';

  @override
  String get disconnectTelegramMessage =>
      'Your Telegram account will be unlinked. You can reconnect later with another account.';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get linkTelegramDescription =>
      'Link your Telegram account to receive notifications about your leave requests.';

  @override
  String get afterOpeningTelegramInstruction =>
      'After opening Telegram, press Start on the chat with our bot to link your account. Return here and your status will update automatically.';

  @override
  String get myAttendance => 'My Attendance';

  @override
  String get todaysLocation => 'Today\'s Location';

  @override
  String get history => 'History';

  @override
  String get failedToGetLocation => 'Failed to get location';

  @override
  String get myLeaves => 'My Leaves';

  @override
  String get noLeaveRequestsYet => 'No leave requests yet';

  @override
  String get tapPlusToCreateOne => 'Tap + to create one';

  @override
  String get cancelLeave => 'Cancel Leave';

  @override
  String areYouSureCancelLeave(Object leaveType) {
    return 'Are you sure you want to cancel the $leaveType request?';
  }

  @override
  String get leaveRequestCancelled => 'Leave request cancelled';

  @override
  String get failedToCancel => 'Failed to cancel';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get inReview => 'In Review';

  @override
  String get submitted => 'Submitted';

  @override
  String get newLeaveRequest => 'New Leave Request';

  @override
  String get leaveTypeRequired => 'Leave Type *';

  @override
  String get dateRangeRequired => 'Date Range *';

  @override
  String get reasonRequired => 'Reason *';

  @override
  String get phoneOrEmailOptional => 'Phone number or email (optional)';

  @override
  String get selectLeaveType => 'Select leave type';

  @override
  String get select => 'Select';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get contactDuringLeave => 'Contact During Leave';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get halfDay => 'Half Day';

  @override
  String get enterReasonForLeave => 'Enter reason for leave';

  @override
  String get pleaseSelectLeaveType => 'Please select a leave type';

  @override
  String get pleaseSelectStartDate => 'Please select start date';

  @override
  String get pleaseSelectEndDate => 'Please select end date';

  @override
  String get pleaseEnterReason => 'Please enter a reason';

  @override
  String get leaveRequestSubmitted => 'Leave request submitted successfully';

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get leaveDetails => 'Leave Details';

  @override
  String get leaveRequest => 'Leave Request';

  @override
  String get details => 'Details';

  @override
  String get dateRange => 'Date Range';

  @override
  String get status => 'Status';

  @override
  String get reason => 'Reason';

  @override
  String get leaveType => 'Leave Type';

  @override
  String get contact => 'Contact';

  @override
  String get attachment => 'Attachment';

  @override
  String get adminRemark => 'Admin Remark';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get cancelThisRequest => 'Cancel This Request';

  @override
  String get leaveCancelled => 'Leave cancelled';

  @override
  String get myApprovals => 'My Approvals';

  @override
  String get approvalsComingSoon => 'Approvals coming soon';
}

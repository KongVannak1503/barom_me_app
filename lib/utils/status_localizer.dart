import '../l10n/app_localizations.dart';

String statusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'Pending':
      return l10n.pending;
    case 'In Review':
      return l10n.inReview;
    case 'Approved':
      return l10n.approved;
    case 'Rejected':
      return l10n.rejected;
    case 'Cancelled':
      return l10n.cancelled;
    case 'Submitted':
      return l10n.submitted;
    default:
      return status;
  }
}

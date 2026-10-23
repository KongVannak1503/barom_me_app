import '../utils/date_formatter.dart';

class OutsideWorkRequest {
  final int id;
  final String type;

  /// Calendar date `YYYY-MM-DD` (date part of the Laravel cast, no TZ shift).
  final String startDate;

  /// Calendar date `YYYY-MM-DD`; equals [startDate] for single-day requests.
  final String endDate;
  final String reason;
  final String status;
  final String? adminRemark;
  final int? leaveApprovalFlowId;
  final int? currentStepOrder;
  final List<OutsideWorkApprovalAction> approvalActions;
  final String createdAt;

  const OutsideWorkRequest({
    required this.id,
    this.type = 'outside_work',
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.adminRemark,
    this.leaveApprovalFlowId,
    this.currentStepOrder,
    this.approvalActions = const [],
    required this.createdAt,
  });

  bool get isPending => status == 'Pending';
  bool get isApproved => status == 'Approved';
  bool get isRejected => status == 'Rejected';
  bool get isCancelled => status == 'Cancelled';
  bool get isInReview => status == 'In Review';
  bool get isCancellable => isPending || isInReview;

  DateTime? get start => _toDate(startDate);
  DateTime? get end => _toDate(endDate);

  String get endDateDisplay {
    final e = end;
    return e == null ? endDate : DateFormatter.formatDisplay(e);
  }

  String get dateRangeDisplay {
    final s = start;
    final e = end;
    if (s == null || e == null) {
      return startDate == endDate ? startDate : '$startDate ~ $endDate';
    }
    if (s == e) return DateFormatter.formatDisplay(s);
    return '${DateFormatter.formatDisplay(s)} ~ ${DateFormatter.formatDisplay(e)}';
  }

  /// Takes only the `YYYY-MM-DD` prefix so `2026-10-23T00:00:00.000000Z`
  /// stays on the 23rd regardless of the device timezone.
  static String datePart(String? value) {
    if (value == null || value.isEmpty) return '';
    final match = RegExp(r'^\d{4}-\d{2}-\d{2}').firstMatch(value);
    return match?.group(0) ?? value;
  }

  static DateTime? _toDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  factory OutsideWorkRequest.fromJson(Map<String, dynamic> json) {
    final start = datePart(json['start_date'] as String?);
    final end = datePart(json['end_date'] as String?);
    return OutsideWorkRequest(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'outside_work',
      startDate: start,
      endDate: end.isEmpty ? start : end,
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      adminRemark: json['admin_remark'] as String?,
      leaveApprovalFlowId: json['leave_approval_flow_id'] as int?,
      currentStepOrder: json['current_step_order'] as int?,
      approvalActions:
          (json['approval_actions'] as List<dynamic>?)
              ?.map(
                (e) => OutsideWorkApprovalAction.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class OutsideWorkApprovalAction {
  final String action;
  final String? remark;
  final String? stepLabel;
  final int? stepOrder;
  final String? actorName;

  const OutsideWorkApprovalAction({
    required this.action,
    this.remark,
    this.stepLabel,
    this.stepOrder,
    this.actorName,
  });

  factory OutsideWorkApprovalAction.fromJson(Map<String, dynamic> json) {
    final step = json['step'] as Map<String, dynamic>?;
    final actor = json['actor'] as Map<String, dynamic>?;
    return OutsideWorkApprovalAction(
      action: json['action'] as String? ?? '',
      remark: json['remark'] as String?,
      stepLabel: step?['step_label'] as String?,
      stepOrder: step?['step_order'] as int?,
      actorName: actor?['name'] as String?,
    );
  }
}

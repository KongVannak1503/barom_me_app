import '../utils/date_formatter.dart';

class LeaveRequest {
  final int id;
  final int employeeId;
  final int leaveTypeId;
  final String startDate;
  final String endDate;
  final String reason;
  final bool halfDay;
  final String? halfDaySession;
  final String? contactDuringLeave;
  final String status;
  final String? adminRemark;
  final String? attachment;
  final LeaveTypeBrief? leaveType;
  final int? leaveApprovalFlowId;
  final int? currentStepOrder;
  final String createdAt;
  final String updatedAt;

  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.halfDay = false,
    this.halfDaySession,
    this.contactDuringLeave,
    required this.status,
    this.adminRemark,
    this.attachment,
    this.leaveType,
    this.leaveApprovalFlowId,
    this.currentStepOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'Pending';
  bool get isApproved => status == 'Approved';
  bool get isRejected => status == 'Rejected';
  bool get isCancelled => status == 'Cancelled';
  bool get isInReview => status == 'In Review';
  bool get isCancellable => isPending || isInReview;

  String get statusDisplay {
    switch (status) {
      case 'Pending': return 'Pending';
      case 'In Review': return 'In Review';
      case 'Approved': return 'Approved';
      case 'Rejected': return 'Rejected';
      case 'Cancelled': return 'Cancelled';
      default: return status;
    }
  }

  String get dateRangeDisplay {
    final start = _parseDate(startDate);
    final end = _parseDate(endDate);
    if (start == null || end == null) {
      return startDate == endDate ? startDate : '$startDate ~ $endDate';
    }
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return DateFormatter.formatDisplay(start);
    }
    return '${DateFormatter.formatDisplay(start)} ~ ${DateFormatter.formatDisplay(end)}';
  }

  DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;
    return DateTime.tryParse(value.replaceFirst(' ', 'T'));
  }

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      leaveTypeId: json['leave_type_id'] as int,
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      halfDay: json['half_day'] as bool? ?? false,
      halfDaySession: json['half_day_session'] as String?,
      contactDuringLeave: json['contact_during_leave'] as String?,
      status: json['status'] as String? ?? 'Pending',
      adminRemark: json['admin_remark'] as String?,
      attachment: json['attachment'] as String?,
      leaveType: json['leave_type'] != null
          ? LeaveTypeBrief.fromJson(json['leave_type'] as Map<String, dynamic>)
          : null,
      leaveApprovalFlowId: json['leave_approval_flow_id'] as int?,
      currentStepOrder: json['current_step_order'] as int?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}

class LeaveTypeBrief {
  final String name;
  final String code;
  final String? color;

  const LeaveTypeBrief({
    required this.name,
    required this.code,
    this.color,
  });

  factory LeaveTypeBrief.fromJson(Map<String, dynamic> json) {
    return LeaveTypeBrief(
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      color: json['color'] as String?,
    );
  }
}

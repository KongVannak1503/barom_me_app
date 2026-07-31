class LeaveEntitlement {
  final int id;
  final int employeeId;
  final int leaveTypeId;
  final int year;
  final double entitledDays;
  final double usedDays;
  final double remainingDays;
  final String? leaveTypeName;
  final String? leaveTypeCode;
  final String? leaveTypeColor;

  const LeaveEntitlement({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.year,
    required this.entitledDays,
    required this.usedDays,
    required this.remainingDays,
    this.leaveTypeName,
    this.leaveTypeCode,
    this.leaveTypeColor,
  });

  factory LeaveEntitlement.fromJson(Map<String, dynamic> json) {
    return LeaveEntitlement(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      leaveTypeId: json['leave_type_id'] as int,
      year: json['year'] as int? ?? DateTime.now().year,
      entitledDays: (json['entitled_days'] as num?)?.toDouble() ?? 0,
      usedDays: (json['used_days'] as num?)?.toDouble() ?? 0,
      remainingDays: (json['remaining_days'] as num?)?.toDouble() ?? 0,
      leaveTypeName: json['leave_type'] is Map
          ? (json['leave_type'] as Map)['name'] as String?
          : null,
      leaveTypeCode: json['leave_type'] is Map
          ? (json['leave_type'] as Map)['code'] as String?
          : null,
      leaveTypeColor: json['leave_type'] is Map
          ? (json['leave_type'] as Map)['color'] as String?
          : null,
    );
  }
}

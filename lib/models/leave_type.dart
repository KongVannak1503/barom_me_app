class LeaveType {
  final int id;
  final String code;
  final String name;
  final String? color;
  final bool isPaid;
  final int? maxDays;
  final bool requiresDocument;
  final String status;

  const LeaveType({
    required this.id,
    required this.code,
    required this.name,
    this.color,
    this.isPaid = false,
    this.maxDays,
    this.requiresDocument = false,
    this.status = 'Active',
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      color: json['color'] as String?,
      isPaid: json['is_paid'] as bool? ?? false,
      maxDays: json['max_days'] as int?,
      requiresDocument: json['requires_document'] as bool? ?? false,
      status: json['status'] as String? ?? 'Active',
    );
  }
}

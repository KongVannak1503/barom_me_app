class Employee {
  final int id;
  final int? companyId;
  final int? userId;
  final String? employeeId;
  final String? firstNameEn;
  final String? lastNameEn;
  final String? nameEn;
  final String? nameKh;
  final String? gender;
  final String? position;
  final String? positionName;
  final int? branchId;
  final String? profileImage;
  final Branch? branch;

  const Employee({
    required this.id,
    this.companyId,
    this.userId,
    this.employeeId,
    this.firstNameEn,
    this.lastNameEn,
    this.nameEn,
    this.nameKh,
    this.gender,
    this.position,
    this.positionName,
    this.branchId,
    this.profileImage,
    this.branch,
  });

  String get displayName => nameEn ?? '${firstNameEn ?? ''} ${lastNameEn ?? ''}'.trim();
  String? get resolvedPosition => positionName ?? position;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      companyId: json['company_id'] as int?,
      userId: json['user_id'] as int?,
      employeeId: json['employee_id'] as String?,
      firstNameEn: json['first_name_en'] as String?,
      lastNameEn: json['last_name_en'] as String?,
      nameEn: json['name_en'] as String?,
      nameKh: json['name_kh'] as String?,
      gender: json['gender'] as String?,
      position: _parsePosition(json['position']),
      positionName: json['position_name'] as String?,
      branchId: json['branch_id'] as int?,
      profileImage: json['profile_image'] as String?,
      branch: json['branch'] != null
          ? Branch.fromJson(json['branch'] as Map<String, dynamic>)
          : null,
    );
  }

  static String? _parsePosition(dynamic value) {
    if (value is String) return value;
    if (value is Map) return value['name'] as String?;
    return null;
  }
}

class Branch {
  final int id;
  final int? companyId;
  final String? name;
  final double? latitude;
  final double? longitude;
  final int? radiusMeters;

  const Branch({
    required this.id,
    this.companyId,
    this.name,
    this.latitude,
    this.longitude,
    this.radiusMeters,
  });

  static double? _parseNum(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as int,
      companyId: json['company_id'] as int?,
      name: json['name'] as String?,
      latitude: _parseNum(json['latitude']),
      longitude: _parseNum(json['longitude']),
      radiusMeters: (json['radius_meters'] as num?)?.toInt(),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../services/api_constants.dart';
import '../../themes/app_colors.dart';
class ProfileHeaderCard extends StatelessWidget {
  final Employee? employee;
  final bool loading;

  const ProfileHeaderCard({
    super.key,
    required this.employee,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final employee = this.employee;

    if (loading || employee == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 90,
                      height: 12,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final name = employee.displayName.trim();
    final nameKh = employee.nameKh?.trim();
    final position = employee.resolvedPosition?.trim();
    final branch = employee.branch?.name?.trim();
    final subtitle = [
      if (nameKh != null && nameKh.isNotEmpty) nameKh,
      if (position != null && position.isNotEmpty) position,
      if (branch != null && branch.isNotEmpty) branch,
    ].join('  ·  ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _avatar(employee, name),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(Employee employee, String name) {
    final profileImage = employee.profileImage?.trim();
    ImageProvider? provider;
    if (profileImage != null && profileImage.isNotEmpty) {
      final url = profileImage.startsWith('http') ? profileImage : '${ApiConstants.storageBaseUrl}$profileImage';
      provider = NetworkImage(url);
    }
    if (provider == null) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.primary,
        child: Text(
          _initials(name),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.primary,
      foregroundImage: provider,
      onForegroundImageError: (_, _) {},
      child: Text(
        _initials(name),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.take(2).toString().toUpperCase();
    return (parts.first.characters.first.toString() + parts.last.characters.first.toString()).toUpperCase();
  }
}

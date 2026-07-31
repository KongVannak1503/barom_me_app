import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/leave_type.dart';
import '../../providers/leave_provider.dart';
import '../../themes/app_colors.dart';

class CreateLeaveScreen extends ConsumerStatefulWidget {
  const CreateLeaveScreen({super.key});

  @override
  ConsumerState<CreateLeaveScreen> createState() => _CreateLeaveScreenState();
}

class _CreateLeaveScreenState extends ConsumerState<CreateLeaveScreen> {
  LeaveType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _halfDay = false;
  String? _halfDaySession;
  final _reasonController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now),
      firstDate: isStart ? now : (_startDate ?? now),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (_selectedType == null) {
      _showError('Please select a leave type');
      return;
    }
    if (_startDate == null) {
      _showError('Please select start date');
      return;
    }
    if (_endDate == null) {
      _showError('Please select end date');
      return;
    }
    if (_reasonController.text.trim().isEmpty) {
      _showError('Please enter a reason');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(leaveProvider.notifier).createLeaveRequest(
        leaveTypeId: _selectedType!.id,
        startDate: _formatDate(_startDate!),
        endDate: _formatDate(_endDate!),
        reason: _reasonController.text.trim(),
        halfDay: _halfDay,
        halfDaySession: _halfDay ? _halfDaySession : null,
        contactDuringLeave: _contactController.text.trim().isEmpty
            ? null
            : _contactController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave request submitted successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaveProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Leave Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Leave Type *'),
            const SizedBox(height: 8),
            DropdownButtonFormField<LeaveType>(
              initialValue: _selectedType,
              isExpanded: true,
              decoration: _inputDecoration(),
              hint: const Text('Select leave type'),
              items: state.leaveTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _parseColor(type.color) ?? AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(type.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedType = val),
            ),
            const SizedBox(height: 20),
            _buildSectionLabel('Date Range *'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _dateField(
                    label: 'Start Date',
                    date: _startDate,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('~', style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
                ),
                Expanded(
                  child: _dateField(
                    label: 'End Date',
                    date: _endDate,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Switch(
                  value: _halfDay,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() {
                    _halfDay = v;
                    if (!v) _halfDaySession = null;
                  }),
                ),
                const SizedBox(width: 8),
                const Text('Half Day', style: TextStyle(fontSize: 14)),
              ],
            ),
            if (_halfDay) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _sessionChip('Morning', Icons.wb_sunny),
                  const SizedBox(width: 12),
                  _sessionChip('Afternoon', Icons.nights_stay),
                ],
              ),
            ],
            const SizedBox(height: 20),
            _buildSectionLabel('Reason *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: _inputDecoration(hint: 'Enter reason for leave'),
            ),
            const SizedBox(height: 20),
            _buildSectionLabel('Contact During Leave'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contactController,
              decoration: _inputDecoration(hint: 'Phone number or email (optional)'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary));
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _dateField({required String label, required DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: date != null ? AppColors.textPrimary : AppColors.textHint),
                const SizedBox(width: 6),
                Text(
                  date != null ? _formatDate(date) : 'Select',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null ? AppColors.textPrimary : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionChip(String label, IconData icon) {
    final selected = _halfDaySession == label.toLowerCase();
    return GestureDetector(
      onTap: () => setState(() => _halfDaySession = label.toLowerCase()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primaryLight : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final c = hex.replaceFirst('#', '');
    if (c.length != 6) return null;
    return Color(int.parse('FF$c', radix: 16));
  }
}

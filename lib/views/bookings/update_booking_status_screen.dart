import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../common/topbar.dart';

class UpdateBookingStatusScreen extends StatefulWidget {
  final String bookingId;
  const UpdateBookingStatusScreen({super.key, required this.bookingId});

  @override
  State<UpdateBookingStatusScreen> createState() =>
      _UpdateBookingStatusScreenState();
}

class _UpdateBookingStatusScreenState
    extends State<UpdateBookingStatusScreen> {
  String? _selectedStatus;

  final _statuses = [
    _StatusOption(
      status: AppConstants.statusPending,
      label: 'Pending',
      description: 'Booking has been received and awaiting confirmation.',
      icon: Icons.hourglass_empty,
      color: AppColors.pending,
    ),
    _StatusOption(
      status: AppConstants.statusConfirmed,
      label: 'Confirmed',
      description: 'Booking is confirmed and scheduled.',
      icon: Icons.check_circle_outline,
      color: AppColors.confirmed,
    ),
    _StatusOption(
      status: AppConstants.statusCompleted,
      label: 'Completed',
      description: 'Service has been delivered successfully.',
      icon: Icons.task_alt,
      color: AppColors.completed,
    ),
    _StatusOption(
      status: AppConstants.statusCancelled,
      label: 'Cancelled',
      description: 'Booking has been cancelled.',
      icon: Icons.cancel_outlined,
      color: AppColors.cancelled,
    ),
  ];

  Future<void> _submit() async {
    if (_selectedStatus == null) {
      Helpers.showSnackBar(context, 'Please select a status', isError: true);
      return;
    }
    final provider = context.read<BookingProvider>();
    await provider.updateStatus(widget.bookingId, _selectedStatus!);
    if (provider.error == null && mounted) {
      Helpers.showSnackBar(context, 'Booking status updated');
      context.go('/bookings/${widget.bookingId}');
    } else if (provider.error != null && mounted) {
      Helpers.showSnackBar(context, provider.error!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final booking = provider.bookings.firstWhere(
      (b) => b.id == widget.bookingId,
      orElse: () => BookingModel(
        id: widget.bookingId,
        userId: '',
        patientName: 'Loading...',
        patientAge: '',
        patientPhone: '',
        doctorSpecialization: '',
        title: '',
        productId: '',
        amount: 0,
        bookingNumber: 0,
        status: 'pending',
        paymentMethod: '',
        date: '',
      ),
    );

    _selectedStatus ??= booking.status;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/bookings/${widget.bookingId}'),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                const Text('Update Booking Status',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  // Booking summary chip
                  ContentCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.receipt_outlined, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${booking.id.length > 8 ? booking.id.substring(0, 8).toUpperCase() : booking.id.toUpperCase()}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              Text(
                                '${booking.patientName} — ${booking.title}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(status: booking.status),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ContentCard(
                    title: 'Select New Status',
                    child: Column(
                      children: _statuses.map((s) {
                        final isSelected = _selectedStatus == s.status;
                        final isCurrent = booking.status == s.status;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedStatus = s.status),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? s.color.withOpacity(0.06) : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? s.color : AppColors.cardBorder,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: s.color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(s.icon, color: s.color, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(s.label,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: isSelected ? s.color : AppColors.textPrimary,
                                              )),
                                          if (isCurrent) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primarySurface,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text('Current',
                                                  style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(s.description,
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                Radio<String>(
                                  value: s.status,
                                  groupValue: _selectedStatus,
                                  onChanged: (v) => setState(() => _selectedStatus = v),
                                  activeColor: s.color,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlineButton(
                        label: 'Cancel',
                        onPressed: () => context.go('/bookings/${widget.bookingId}'),
                      ),
                      const SizedBox(width: 12),
                      PrimaryButton(
                        label: 'Update Status',
                        onPressed: _submit,
                        isLoading: provider.isLoading,
                        icon: Icons.check,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusOption {
  final String status;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  const _StatusOption({
    required this.status,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}

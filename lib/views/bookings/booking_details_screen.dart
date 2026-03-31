import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../common/topbar.dart';

class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;
  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final booking = provider.bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => BookingModel(
        id: bookingId,
        userId: '',
        patientName: '',
        patientAge: '',
        patientPhone: '',
        doctorSpecialization: '',
        title: '',
        productId: '',
        amount: 0,
        bookingNumber: 0,
        status: 'Pending',
        paymentMethod: '',
        date: '',
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(onPressed: () => context.go('/bookings'), icon: const Icon(Icons.arrow_back)),
                const SizedBox(width: 8),
                const Text('Booking Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => context.go('/bookings/$bookingId/status'),
                  icon: const Icon(Icons.update, size: 16),
                  label: const Text('Update Status'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 700;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _BookingInfoCard(booking: booking)),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _BookingSideCard(booking: booking)),
                  ],
                );
              }
              return Column(children: [
                _BookingInfoCard(booking: booking),
                const SizedBox(height: 16),
                _BookingSideCard(booking: booking),
              ]);
            }),
          ],
        ),
      ),
    );
  }
}

class _BookingInfoCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingInfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      title: 'Booking Information',
      child: Column(
        children: [
          _Row(label: 'Booking ID', value: '#${booking.id.substring(0, 8).toUpperCase()}', valueBold: true),
          const SizedBox(height: 12),
          _Row(label: 'Status', valueWidget: StatusBadge(status: booking.status)),
          const SizedBox(height: 12),
          _Row(label: 'Date', value: booking.date),
          const Divider(height: 28, color: AppColors.cardBorder),
          // Patient section
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Patient Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 12),
          _Row(label: 'Name', value: booking.patientName),
          const SizedBox(height: 8),
          _Row(label: 'Age', value: booking.patientAge),
          const SizedBox(height: 8),
          _Row(label: 'Phone', value: booking.patientPhone),
          const Divider(height: 28, color: AppColors.cardBorder),
          // Doctor section
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Service Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 12),
          _Row(label: 'Title', value: booking.title),
          const SizedBox(height: 8),
          _Row(label: 'Specialization', value: booking.doctorSpecialization),
          const SizedBox(height: 8),
          _Row(label: 'Booking #', value: booking.bookingNumber.toString()),
        ],
      ),
    );
  }
}

class _BookingSideCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingSideCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BookingProvider>();
    return Column(
      children: [
        ContentCard(
          title: 'Payment Summary',
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Payment Method', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text(booking.paymentMethod.isEmpty ? '—' : booking.paymentMethod, style: const TextStyle(fontSize: 13)),
                ],
              ),
              const Divider(height: 20, color: AppColors.cardBorder),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(
                    '\$${booking.amount}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ContentCard(
          title: 'Quick Actions',
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/bookings/${ booking.id}/status'),
                  icon: const Icon(Icons.update, size: 16),
                  label: const Text('Update Status'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await Helpers.showConfirmDialog(
                      context,
                      title: 'Delete Booking',
                      message: 'Delete this booking permanently?',
                    );
                    if (ok && context.mounted) {
                      await provider.deleteBooking(booking.id);
                      context.go('/bookings');
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete Booking'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String? value;
  final bool valueBold;
  final Widget? valueWidget;
  const _Row({required this.label, this.value, this.valueBold = false, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        const SizedBox(width: 8),
        Expanded(
          child: valueWidget ??
              Text(value ?? '—',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

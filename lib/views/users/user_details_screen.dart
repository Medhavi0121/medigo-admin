import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/user_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/user_provider.dart';
import '../common/topbar.dart';

class UserDetailsScreen extends StatelessWidget {
  final String userId;
  const UserDetailsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    final user = userProvider.users.firstWhere(
      (u) => u.id == userId,
      orElse: () => UserModel(id: userId, uid: '', name: '', email: '', phone: '', profilePicUrl: ''),
    );

    final userBookings = bookingProvider.bookings
        .where((b) => b.userId == userId)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back + Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/users'),
                ),
                const SizedBox(width: 8),
                const Text('User Details',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 24),

            LayoutBuilder(builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 700;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 300,
                        child: _UserProfileCard(user: user, userBookings: userBookings)),
                    const SizedBox(width: 16),
                    Expanded(child: _UserBookingsCard(bookings: userBookings)),
                  ],
                );
              }
              return Column(
                children: [
                  _UserProfileCard(user: user, userBookings: userBookings),
                  const SizedBox(height: 16),
                  _UserBookingsCard(bookings: userBookings),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _UserProfileCard extends StatelessWidget {
  final UserModel user;
  final List userBookings;
  const _UserProfileCard({required this.user, required this.userBookings});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<UserProvider>();
    return ContentCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primarySurface,
            backgroundImage:
                user.profilePicUrl.isNotEmpty ? NetworkImage(user.profilePicUrl) : null,
            child: user.profilePicUrl.isEmpty
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(user.name,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(user.email,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          const Divider(height: 32, color: AppColors.cardBorder),
          _InfoRow(icon: Icons.phone_outlined, label: 'Phone',
              value: user.phone.isEmpty ? '—' : user.phone),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.fingerprint, label: 'UID',
              value: user.uid),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.bookmark_outline, label: 'Bookings',
              value: userBookings.length.toString()),
          const Divider(height: 32, color: AppColors.cardBorder),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await Helpers.showConfirmDialog(
                      context,
                      title: 'Delete User',
                      message: 'Delete this user permanently?',
                    );
                    if (ok && context.mounted) {
                      await provider.deleteUser(user.id);
                      context.go('/users');
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text('$label:',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        const Spacer(),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _UserBookingsCard extends StatelessWidget {
  final List bookings;
  const _UserBookingsCard({required this.bookings});

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      title: 'Booking History',
      padding: EdgeInsets.zero,
      child: bookings.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(40),
              child: EmptyWidget(message: 'No bookings found'),
            )
          : Column(
              children: bookings
                  .map((b) => _BookingTile(booking: b))
                  .toList(),
            ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final dynamic booking;
  const _BookingTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.receipt_outlined,
            color: AppColors.primary, size: 20),
      ),
      title: Text(
        booking.title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        booking.date,
        style: const TextStyle(
            fontSize: 12, color: AppColors.textMuted),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${booking.amount}',
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          StatusBadge(status: booking.status),
        ],
      ),
    );
  }
}

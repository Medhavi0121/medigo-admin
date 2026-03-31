import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/booking_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes/route_names.dart';
import '../common/topbar.dart';
import 'widgets/stats_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = context.watch<UserProvider>();
    final products = context.watch<ProductProvider>();
    final bookings = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Dashboard',
              subtitle: 'Welcome back! Here\'s what\'s happening today.',
            ),
            const SizedBox(height: 24),

            // Stats Grid
            LayoutBuilder(builder: (ctx, constraints) {
              final cols = constraints.maxWidth > 900
                  ? 4
                  : constraints.maxWidth > 600
                      ? 2
                      : 1;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  StatsCard(
                    title: 'Total Users',
                    value: users.totalCount.toString(),
                    icon: Icons.people,
                    color: AppColors.primary,
                    subtitle: 'Registered users',
                    change: 0,
                  ),
                  StatsCard(
                    title: 'Total Bookings',
                    value: bookings.totalCount.toString(),
                    icon: Icons.calendar_month,
                    color: AppColors.accent,
                    subtitle: '${bookings.countByStatus('Pending')} pending',
                    change: 0,
                  ),
                  StatsCard(
                    title: 'Products',
                    value: products.totalCount.toString(),
                    icon: Icons.inventory_2,
                    color: AppColors.success,
                    subtitle: '${products.activeCount} active',
                    change: 0,
                  ),
                  StatsCard(
                    title: 'Revenue',
                    value: DateFormatter.formatCurrency(bookings.totalRevenue),
                    icon: Icons.attach_money,
                    color: const Color(0xFFF57F17),
                    subtitle: 'From completed bookings',
                    change: 0,
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Recent Bookings Table
            ContentCard(
              title: 'Recent Bookings',
              titleAction: TextButton(
                onPressed: () => context.go(RouteNames.bookings),
                child: const Text('View All'),
              ),
              padding: EdgeInsets.zero,
              child: bookings.isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _RecentBookingsTable(
                        bookings: bookings.bookings.take(5).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentBookingsTable extends StatelessWidget {
  final List bookings;
  const _RecentBookingsTable({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
            child: Text('No bookings yet',
                style: TextStyle(color: AppColors.textMuted))),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: AppColors.cardBorder)),
            color: AppColors.surfaceVariant,
          ),
          child: const Row(
            children: [
              Expanded(flex: 2, child: _HeaderCell('Booking ID')),
              Expanded(flex: 2, child: _HeaderCell('Patient')),
              Expanded(flex: 2, child: _HeaderCell('Title')),
              Expanded(child: _HeaderCell('Amount')),
              Expanded(child: _HeaderCell('Status')),
              Expanded(child: _HeaderCell('Date')),
            ],
          ),
        ),
        ...bookings.map((b) => _BookingRow(booking: b)),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary));
  }
}

class _BookingRow extends StatelessWidget {
  final dynamic booking;
  const _BookingRow({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AppColors.cardBorder))),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '#${booking.id.substring(0, 8).toUpperCase()}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(booking.patientName,
                style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(booking.title,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              DateFormatter.formatCurrency(booking.amount),
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: StatusBadge(status: booking.status)),
          Expanded(
            child: Text(
              booking.date,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

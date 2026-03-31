import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/loading_widget.dart';
import '../../providers/booking_provider.dart';
import '../common/topbar.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'all';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Bookings',
              subtitle: '${provider.totalCount} total bookings',
            ),
            const SizedBox(height: 16),

            // Status summary cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusSummaryCard(
                    label: 'All',
                    count: provider.totalCount,
                    color: AppColors.primary,
                    isSelected: _statusFilter == 'all',
                    onTap: () {
                      setState(() => _statusFilter = 'all');
                      provider.setStatusFilter('all');
                    },
                  ),
                  const SizedBox(width: 12),
                  _StatusSummaryCard(
                    label: 'Pending',
                    count: provider.countByStatus('Pending'),
                    color: AppColors.pending,
                    isSelected: _statusFilter == 'Pending',
                    onTap: () {
                      setState(() => _statusFilter = 'Pending');
                      provider.setStatusFilter('Pending');
                    },
                  ),
                  const SizedBox(width: 12),
                  _StatusSummaryCard(
                    label: 'Confirmed',
                    count: provider.countByStatus('Confirmed'),
                    color: AppColors.confirmed,
                    isSelected: _statusFilter == 'Confirmed',
                    onTap: () {
                      setState(() => _statusFilter = 'Confirmed');
                      provider.setStatusFilter('Confirmed');
                    },
                  ),
                  const SizedBox(width: 12),
                  _StatusSummaryCard(
                    label: 'Completed',
                    count: provider.countByStatus('Completed'),
                    color: AppColors.completed,
                    isSelected: _statusFilter == 'Completed',
                    onTap: () {
                      setState(() => _statusFilter = 'Completed');
                      provider.setStatusFilter('Completed');
                    },
                  ),
                  const SizedBox(width: 12),
                  _StatusSummaryCard(
                    label: 'Cancelled',
                    count: provider.countByStatus('Cancelled'),
                    color: AppColors.cancelled,
                    isSelected: _statusFilter == 'Cancelled',
                    onTap: () {
                      setState(() => _statusFilter = 'Cancelled');
                      provider.setStatusFilter('Cancelled');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search
            ContentCard(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: provider.setSearch,
                decoration: InputDecoration(
                  hintText: 'Search by patient, title or booking ID...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Table
            Expanded(
              child: ContentCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _BookingTableHeader(),
                    Expanded(
                      child: provider.isLoading
                          ? const LoadingWidget()
                          : provider.bookings.isEmpty
                              ? const EmptyWidget(
                                  message: 'No bookings found',
                                  icon: Icons.calendar_month_outlined)
                              : ListView.separated(
                                  itemCount: provider.bookings.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.cardBorder),
                                  itemBuilder: (ctx, i) {
                                    final b = provider.bookings[i];
                                    return _BookingRow(
                                      booking: b,
                                      onView: () => context.go('/bookings/${b.id}'),
                                      onUpdateStatus: () => context.go('/bookings/${b.id}/status'),
                                      onDelete: () async {
                                        final ok = await Helpers.showConfirmDialog(
                                          ctx,
                                          title: 'Delete Booking',
                                          message: 'Delete booking #${b.id.substring(0, 8).toUpperCase()}?',
                                        );
                                        if (ok) provider.deleteBooking(b.id);
                                      },
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusSummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusSummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : AppColors.cardBorder, width: isSelected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 130, child: _H('Booking ID')),
          Expanded(flex: 2, child: _H('Patient')),
          Expanded(flex: 2, child: _H('Title')),
          Expanded(child: _H('Amount')),
          Expanded(child: _H('Status')),
          Expanded(child: _H('Date')),
          SizedBox(width: 100, child: _H('Actions')),
        ],
      ),
    );
  }
}

class _H extends StatelessWidget {
  final String label;
  const _H(this.label);
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary));
}

class _BookingRow extends StatelessWidget {
  final dynamic booking;
  final VoidCallback onView;
  final VoidCallback onUpdateStatus;
  final VoidCallback onDelete;

  const _BookingRow({
    required this.booking,
    required this.onView,
    required this.onUpdateStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '#${booking.id.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.patientName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(booking.patientPhone, style: const TextStyle(fontSize: 11, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(booking.title,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: Text(DateFormatter.formatCurrency(booking.amount),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          Expanded(child: StatusBadge(status: booking.status)),
          Expanded(
            child: Text(booking.date,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                  onPressed: onView,
                  tooltip: 'View',
                ),
                IconButton(
                  icon: const Icon(Icons.update, size: 18, color: AppColors.accent),
                  onPressed: onUpdateStatus,
                  tooltip: 'Update Status',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

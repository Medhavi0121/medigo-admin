import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BookingBarChart extends StatelessWidget {
  final Map<String, int> data;
  const BookingBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    if (entries.isEmpty) {
      return const Center(
          child: Text('No data', style: TextStyle(color: AppColors.textMuted)));
    }
    final maxY = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxY + 2).toDouble(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toInt().toString(),
                const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11),
              ),
              reservedSize: 28,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) {
                  return const SizedBox();
                }
                final key = entries[idx].key;
                final parts = key.split('-');
                final months = [
                  '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                ];
                final label = parts.length == 2
                    ? months[int.tryParse(parts[1]) ?? 0]
                    : key;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(label,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                );
              },
              reservedSize: 28,
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.cardBorder, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value.toDouble(),
                color: AppColors.primary,
                width: 28,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: (maxY + 2).toDouble(),
                  color: AppColors.primarySurface,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class BookingStatusPieChart extends StatelessWidget {
  final int pending;
  final int confirmed;
  final int completed;
  final int cancelled;

  const BookingStatusPieChart({
    super.key,
    required this.pending,
    required this.confirmed,
    required this.completed,
    required this.cancelled,
  });

  @override
  Widget build(BuildContext context) {
    final total = pending + confirmed + completed + cancelled;
    if (total == 0) {
      return const Center(
          child: Text('No bookings yet',
              style: TextStyle(color: AppColors.textMuted)));
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                if (pending > 0)
                  _section(pending, total, AppColors.pending, 'Pending'),
                if (confirmed > 0)
                  _section(confirmed, total, AppColors.confirmed, 'Confirmed'),
                if (completed > 0)
                  _section(completed, total, AppColors.completed, 'Completed'),
                if (cancelled > 0)
                  _section(cancelled, total, AppColors.cancelled, 'Cancelled'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Legend(color: AppColors.pending, label: 'Pending', count: pending),
              const SizedBox(height: 10),
              _Legend(color: AppColors.confirmed, label: 'Confirmed', count: confirmed),
              const SizedBox(height: 10),
              _Legend(color: AppColors.completed, label: 'Completed', count: completed),
              const SizedBox(height: 10),
              _Legend(color: AppColors.cancelled, label: 'Cancelled', count: cancelled),
            ],
          ),
        ),
      ],
    );
  }

  PieChartSectionData _section(
      int value, int total, Color color, String title) {
    final pct = (value / total * 100);
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: '${pct.toStringAsFixed(0)}%',
      radius: 50,
      titleStyle: const TextStyle(
          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  const _Legend(
      {required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ),
        Text(count.toString(),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/order_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(orderListProvider);
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final todayOrders = allOrders.where((o) =>
        o.createdAt.year == now.year &&
        o.createdAt.month == now.month &&
        o.createdAt.day == now.day).toList();

    final todayRevenue = todayOrders.fold<int>(0, (sum, o) => sum + o.total);
    final todayItems = todayOrders.fold<int>(0, (sum, o) => sum + o.totalItems);
    final avgTicket = todayOrders.isEmpty ? 0 : (todayRevenue / todayOrders.length).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Ringkasan WARDON'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Stat Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return GridView.count(
                  crossAxisCount: isWide ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: isWide ? 1.5 : 1.3,
                  children: [
                    _buildStatCard(
                      context,
                      title: 'Pendapatan Hari Ini',
                      value: CurrencyFormatter.format(todayRevenue),
                      icon: Icons.payments_rounded,
                      color: AppColors.primaryLight,
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Total Transaksi',
                      value: '${todayOrders.length} Pesanan',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.amberCoffee,
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Rata-rata Order',
                      value: CurrencyFormatter.format(avgTicket),
                      icon: Icons.analytics_rounded,
                      color: AppColors.info,
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Item Terjual',
                      value: '$todayItems Porsi',
                      icon: Icons.coffee_rounded,
                      color: AppColors.secondary,
                      isDark: isDark,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Charts Section
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                return Flex(
                  direction: isDesktop ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sales trend chart
                    Expanded(
                      flex: isDesktop ? 6 : 0,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Tren Penjualan 7 Hari Terakhir',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Icon(Icons.show_chart_rounded, color: isDark ? AppColors.primaryLight : AppColors.primary),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 220,
                                child: _buildBarChart(allOrders, isDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (isDesktop) const SizedBox(width: 16) else const SizedBox(height: 16),

                    // Top Selling Items
                    Expanded(
                      flex: isDesktop ? 4 : 0,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Menu Paling Laris',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 16),
                              Consumer(
                                builder: (context, ref, _) {
                                  final topItems = ref.watch(topSellingItemsProvider);
                                  if (topItems.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 40),
                                      child: Center(
                                        child: Text('Belum ada transaksi tercatat', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      ),
                                    );
                                  }

                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: topItems.take(5).length,
                                    separatorBuilder: (_, __) => const Divider(height: 12),
                                    itemBuilder: (context, idx) {
                                      final item = topItems[idx];
                                      return Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                            child: Text('${idx + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '${item.totalQty}x',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Recent Transactions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Transaksi Terbaru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    if (allOrders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: Text('Belum ada riwayat pesanan', style: TextStyle(color: Colors.grey))),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allOrders.take(6).length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final o = allOrders[idx];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.receipt_rounded, size: 20, color: AppColors.primary),
                            ),
                            title: Text(o.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('${DateFormatter.formatFull(o.createdAt)} • ${o.cashierName}'),
                            trailing: Text(
                              CurrencyFormatter.format(o.total),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? AppColors.primaryLight : AppColors.primary,
                              ),
                            ),
                          );
                        },
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

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
              ],
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<dynamic> orders, bool isDark) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                final idx = val.toInt();
                if (idx >= 0 && idx < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(days[idx], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _barGroup(0, 8, isDark),
          _barGroup(1, 12, isDark),
          _barGroup(2, 6, isDark),
          _barGroup(3, 14, isDark),
          _barGroup(4, 18, isDark),
          _barGroup(5, 15, isDark),
          _barGroup(6, 11, isDark),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, bool isDark) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isDark ? AppColors.primaryLight : AppColors.primary,
          width: 14,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}


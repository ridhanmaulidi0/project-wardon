import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../services/excel_export_service.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  bool _isExporting = false;

  Future<void> _exportExcel() async {
    final orders = ref.read(filteredOrdersProvider);
    final period = ref.read(reportPeriodProvider);

    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada transaksi pada periode ini untuk diexport.')),
      );
      return;
    }

    setState(() => _isExporting = true);

    String periodName = 'Hari Ini';
    switch (period) {
      case ReportPeriod.hariIni:
        periodName = 'Hari Ini';
        break;
      case ReportPeriod.mingguIni:
        periodName = 'Minggu Ini';
        break;
      case ReportPeriod.bulanIni:
        periodName = 'Bulan Ini';
        break;
      case ReportPeriod.tahunIni:
        periodName = 'Tahun Ini';
        break;
      case ReportPeriod.semua:
        periodName = 'Semua Transaksi';
        break;
    }

    final filePath = await ExcelExportService.exportOrdersToExcel(orders, periodName: periodName);

    setState(() => _isExporting = false);

    if (!mounted) return;
    if (filePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Laporan Excel berhasil disimpan di: $filePath'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengekspor file Excel.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(reportPeriodProvider);
    final orders = ref.watch(filteredOrdersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalRevenue = orders.fold<int>(0, (sum, o) => sum + o.total);
    final totalItems = orders.fold<int>(0, (sum, o) => sum + o.totalItems);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan WARDON'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              icon: _isExporting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.table_view_rounded, size: 18),
              label: Text(_isExporting ? 'Mengekspor...' : 'Export ke Excel (.xlsx)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              onPressed: _isExporting ? null : _exportExcel,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Filter Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPeriodChip('Hari Ini', ReportPeriod.hariIni, period),
                _buildPeriodChip('Minggu Ini', ReportPeriod.mingguIni, period),
                _buildPeriodChip('Bulan Ini', ReportPeriod.bulanIni, period),
                _buildPeriodChip('Tahun Ini', ReportPeriod.tahunIni, period),
                _buildPeriodChip('Semua Transaksi', ReportPeriod.semua, period),
              ],
            ),
            const SizedBox(height: 20),

            // Summary row
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Penjualan', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                          const SizedBox(height: 6),
                          Text(
                            CurrencyFormatter.format(totalRevenue),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jumlah Transaksi', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                          const SizedBox(height: 6),
                          Text('${orders.length} Order', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Item Terjual', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                          const SizedBox(height: 6),
                          Text('$totalItems Porsi', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Data Table / List
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Daftar Transaksi Periode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${orders.length} rekaman data', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (orders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text('Tidak ada data penjualan pada periode ini.', style: TextStyle(color: Colors.grey))),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 24,
                          headingRowColor: WidgetStatePropertyAll(
                            isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                          ),
                          columns: const [
                            DataColumn(label: Text('No. Order', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Tanggal & Waktu', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Kasir', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Metode', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: orders.map((o) {
                            return DataRow(
                              cells: [
                                DataCell(Text(o.orderNumber, style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text(DateFormatter.formatFull(o.createdAt))),
                                DataCell(Text(o.cashierName)),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: (o.paymentMethod == PaymentMethod.tunai ? AppColors.info : AppColors.amberCoffee).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      o.paymentMethod.name.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: o.paymentMethod == PaymentMethod.tunai ? AppColors.info : AppColors.amberCoffee,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text('${o.totalItems} item')),
                                DataCell(Text(CurrencyFormatter.format(o.total), style: const TextStyle(fontWeight: FontWeight.bold))),
                              ],
                            );
                          }).toList(),
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

  Widget _buildPeriodChip(String label, ReportPeriod p, ReportPeriod current) {
    final isSelected = p == current;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) ref.read(reportPeriodProvider.notifier).setPeriod(p);
      },
    );
  }
}

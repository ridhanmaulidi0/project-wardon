import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../pos/widgets/receipt_dialog.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = orders.where((o) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return o.orderNumber.toLowerCase().contains(q) ||
          o.cashierName.toLowerCase().contains(q) ||
          (o.customerName != null && o.customerName!.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi WARDON'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari No. Order atau Nama Kasir...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                isDense: true,
              ),
              onChanged: (val) => setState(() => _query = val.trim()),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded, size: 54, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                        const SizedBox(height: 12),
                        const Text('Tidak ada riwayat transaksi ditemukan'),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final order = filtered[idx];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: (order.paymentMethod == PaymentMethod.tunai ? AppColors.info : AppColors.amberCoffee).withValues(alpha: 0.15),
                            child: Icon(
                              order.paymentMethod == PaymentMethod.tunai ? Icons.money_rounded : Icons.qr_code_2_rounded,
                              color: order.paymentMethod == PaymentMethod.tunai ? AppColors.info : AppColors.amberCoffee,
                              size: 20,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'LUNAS',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${DateFormatter.formatFull(order.createdAt)} • Kasir: ${order.cashierName} • ${order.totalItems} item',
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                CurrencyFormatter.format(order.total),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Lihat / Cetak Struk',
                                icon: const Icon(Icons.print_outlined, size: 20),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => ReceiptDialog(order: order),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


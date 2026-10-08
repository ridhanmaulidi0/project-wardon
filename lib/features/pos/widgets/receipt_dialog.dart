import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/order_model.dart';
import '../../../providers/store_settings_provider.dart';
import '../../../services/receipt_service.dart';

class ReceiptDialog extends ConsumerWidget {
  final OrderModel order;

  const ReceiptDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider);
    final receiptText = ReceiptService.generateReceiptText(order, settings);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Struk Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      receiptText,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.4,
                        color: isDark ? Colors.grey[300] : Colors.grey[900],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Salin Teks'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: receiptText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Struk berhasil disalin ke clipboard!')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: const Text('Cetak Struk'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Mencetak struk #${order.orderNumber} ke Printer Thermal Bluetooth/USB...'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Mulai Transaksi Baru'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


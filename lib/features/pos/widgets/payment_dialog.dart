import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/order_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import 'receipt_dialog.dart';

class PaymentDialog extends ConsumerStatefulWidget {
  const PaymentDialog({super.key});

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  PaymentMethod _selectedMethod = PaymentMethod.tunai;
  final _cashCtrl = TextEditingController();
  int _cashReceived = 0;

  @override
  void initState() {
    super.initState();
    final total = ref.read(cartProvider).total;
    _cashReceived = total;
    _cashCtrl.text = total.toString();
  }

  @override
  void dispose() {
    _cashCtrl.dispose();
    super.dispose();
  }

  void _setCash(int amount) {
    setState(() {
      _cashReceived = amount;
      _cashCtrl.text = amount.toString();
    });
  }

  Future<void> _processPayment() async {
    final cart = ref.read(cartProvider);
    final user = ref.read(authProvider);
    final cashierName = user?.name ?? 'Kasir WARDON';

    if (_selectedMethod == PaymentMethod.tunai && _cashReceived < cart.total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uang tunai kurang dari total belanja!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final newOrder = await ref.read(orderListProvider.notifier).completeCheckout(
          cashierName: cashierName,
          paymentMethod: _selectedMethod,
          cashReceived: _cashReceived,
        );

    if (!mounted) return;
    Navigator.of(context).pop(); // Close payment dialog

    if (newOrder != null) {
      showDialog(
        context: context,
        builder: (_) => ReceiptDialog(order: newOrder),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final change = (_cashReceived - cart.total).clamp(0, 999999999);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pembayaran Pesanan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Total Amount Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.primaryLight.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL YANG HARUS DIBAYAR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(cart.total),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Method Switcher
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Uang Tunai')),
                      selected: _selectedMethod == PaymentMethod.tunai,
                      onSelected: (val) {
                        if (val) setState(() => _selectedMethod = PaymentMethod.tunai);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('QRIS / Digital')),
                      selected: _selectedMethod == PaymentMethod.qris,
                      onSelected: (val) {
                        if (val) setState(() => _selectedMethod = PaymentMethod.qris);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Dynamic content per method
              if (_selectedMethod == PaymentMethod.tunai) ...[
                // Cash shortcuts
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Uang Pas'),
                      onPressed: () => _setCash(cart.total),
                    ),
                    ActionChip(
                      label: const Text('20.000'),
                      onPressed: () => _setCash(20000),
                    ),
                    ActionChip(
                      label: const Text('50.000'),
                      onPressed: () => _setCash(50000),
                    ),
                    ActionChip(
                      label: const Text('100.000'),
                      onPressed: () => _setCash(100000),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Cash Input
                TextField(
                  controller: _cashCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nominal Tunai Diterima',
                    prefixText: 'Rp ',
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(val) ?? 0;
                    setState(() => _cashReceived = parsed);
                  },
                ),
                const SizedBox(height: 12),

                // Change Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: change > 0 ? AppColors.success.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kembalian:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        CurrencyFormatter.format(change),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: change > 0 ? AppColors.success : (isDark ? AppColors.textLight : AppColors.textDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // QRIS Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorderLight),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code_2_rounded, size: 100, color: AppColors.primary),
                      const SizedBox(height: 8),
                      const Text(
                        'QRIS WARDON POS',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Auto-detect via Payment Gateway Midtrans',
                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(_selectedMethod == PaymentMethod.tunai ? 'Selesaikan Pembayaran' : 'Verifikasi & Selesai'),
                onPressed: _processPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


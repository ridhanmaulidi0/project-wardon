import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/order_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/store_settings_provider.dart';
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

    final newOrder = await ref
        .read(orderListProvider.notifier)
        .completeCheckout(
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

  void _showZoomQrisDialog(
    BuildContext context,
    String imagePath,
    String storeName,
    int total,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QRIS $storeName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${CurrencyFormatter.format(total)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
              const SizedBox(height: 12),
              const Text(
                'Arahkan kamera e-wallet / mobile banking ke barcode di atas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _quickUploadQris() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 92,
      );
      if (picked == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'qris_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedFile = await File(
        picked.path,
      ).copy('${appDir.path}/$fileName');

      await ref
          .read(storeSettingsProvider.notifier)
          .updateQrisImagePath(savedFile.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto barcode QRIS toko berhasil disimpan!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final storeSettings = ref.watch(storeSettingsProvider);
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
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.2 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.primaryLight.withValues(alpha: 0.3)
                        : AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL YANG HARUS DIBAYAR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(cart.total),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
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
                        if (val) {
                          setState(() => _selectedMethod = PaymentMethod.tunai);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('QRIS / Digital')),
                      selected: _selectedMethod == PaymentMethod.qris,
                      onSelected: (val) {
                        if (val) {
                          setState(() => _selectedMethod = PaymentMethod.qris);
                        }
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: change > 0
                        ? AppColors.success.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kembalian:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        CurrencyFormatter.format(change),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: change > 0
                              ? AppColors.success
                              : (isDark
                                    ? AppColors.textLight
                                    : AppColors.textDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // QRIS Box
                if (storeSettings.qrisImagePath != null &&
                    File(storeSettings.qrisImagePath!).existsSync())
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.cardBorderDark
                            : AppColors.cardBorderLight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.2 : 0.04,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 18,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Pindai QRIS ${storeSettings.storeName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // The Real QRIS Image
                        GestureDetector(
                          onTap: () => _showZoomQrisDialog(
                            context,
                            storeSettings.qrisImagePath!,
                            storeSettings.storeName,
                            cart.total,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Image.file(
                                  File(storeSettings.qrisImagePath!),
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                                Container(
                                  margin: const EdgeInsets.all(6),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.fullscreen_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ketuk gambar untuk memperbesar',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.cardBorderDark
                            : AppColors.cardBorderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.amberCoffee.withValues(
                              alpha: 0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            size: 44,
                            color: AppColors.amberCoffee,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Foto QRIS Belum Diunggah',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Owner belum mengunggah foto / scan QRIS toko di menu Pengaturan Toko.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: const Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 16,
                          ),
                          label: const Text('Unggah Foto QRIS Sekarang'),
                          onPressed: _quickUploadQris,
                        ),
                      ],
                    ),
                  ),
              ],

              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  _selectedMethod == PaymentMethod.tunai
                      ? 'Selesaikan Pembayaran'
                      : 'Verifikasi & Selesai',
                ),
                onPressed: _processPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/order_item_model.dart';
import '../../../providers/cart_provider.dart';
import 'payment_dialog.dart';

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key});

  void _showNotesDialog(BuildContext context, WidgetRef ref, OrderItemModel item) {
    final ctrl = TextEditingController(text: item.notes);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Catatan untuk ${item.name}'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Contoh: Less ice, gula aren pisah, extra shot'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).updateNotes(item.menuItemId, ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDiscountDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController(text: ref.read(cartProvider).discount.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Beri Diskon Pesanan'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Potongan Harga (Rp)', prefixText: 'Rp '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(ctrl.text) ?? 0;
              ref.read(cartProvider.notifier).setDiscount(val);
              Navigator.pop(context);
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          left: BorderSide(
            color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 20),
                    const SizedBox(width: 8),
                    const Text('Keranjang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${cart.totalQuantity}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!cart.isEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Kosongkan', style: TextStyle(fontSize: 12)),
                    onPressed: () => ref.read(cartProvider.notifier).clearCart(),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Customer Name Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Nama Pelanggan (opsional)',
                prefixIcon: Icon(Icons.person_outline, size: 18),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (val) => ref.read(cartProvider.notifier).setCustomerName(val.trim()),
            ),
          ),

          // Items List
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 48,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Keranjang masih kosong',
                          style: TextStyle(
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pilih menu di samping untuk memesan',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemBuilder: (context, idx) {
                      final item = cart.items[idx];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      CurrencyFormatter.format(item.unitPrice),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity Controls
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => ref.read(cartProvider.notifier).decreaseQuantity(item.menuItemId),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 18),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => ref.read(cartProvider.notifier).increaseQuantity(item.menuItemId),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),

                              // Subtotal
                              Text(
                                CurrencyFormatter.format(item.subtotal),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),

                          // Notes
                          InkWell(
                            onTap: () => _showNotesDialog(context, ref, item),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_note_rounded, size: 14, color: isDark ? AppColors.primaryLight : AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.notes?.isNotEmpty == true ? item.notes! : '+ Tambah catatan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: item.notes?.isNotEmpty == true ? FontStyle.italic : FontStyle.normal,
                                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Summary and Checkout Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDark : AppColors.bgLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(fontSize: 13)),
                    Text(CurrencyFormatter.format(cart.subtotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),

                // Discount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _showDiscountDialog(context, ref),
                      child: Row(
                        children: [
                          const Text('Diskon', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Icon(Icons.edit_outlined, size: 13, color: isDark ? AppColors.primaryLight : AppColors.primary),
                        ],
                      ),
                    ),
                    Text(
                      cart.discount > 0 ? '-${CurrencyFormatter.format(cart.discount)}' : 'Rp 0',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cart.discount > 0 ? AppColors.error : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 6),

                // Total Final
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text(
                      CurrencyFormatter.format(cart.total),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment_rounded),
                    label: const Text('BAYAR SEKARANG'),
                    onPressed: cart.isEmpty
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (_) => const PaymentDialog(),
                            );
                          },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/sample_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/menu_item_model.dart';
import '../../providers/menu_provider.dart';

class MenuManagementScreen extends ConsumerWidget {
  const MenuManagementScreen({super.key});

  void _showFormDialog(BuildContext context, WidgetRef ref, [MenuItemModel? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(text: existing?.price.toString() ?? '');
    final stockCtrl = TextEditingController(text: existing?.stock.toString() ?? '50');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String selectedCat = existing?.categoryId ?? 'kopi';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(existing == null ? 'Tambah Menu WARDON' : 'Edit Menu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Menu (contoh: Es Kopi Susu)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCat,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: SampleData.defaultCategories
                      .where((c) => c.id != 'all')
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedCat = val);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Harga', prefixText: 'Rp '),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Stok (Porsi)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Deskripsi singkat (opsional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final price = int.tryParse(priceCtrl.text) ?? 0;
                final stock = int.tryParse(stockCtrl.text) ?? 0;

                if (name.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama dan harga valid wajib diisi!')),
                  );
                  return;
                }

                if (existing == null) {
                  final newItem = MenuItemModel(
                    id: const Uuid().v4(),
                    categoryId: selectedCat,
                    name: name,
                    price: price,
                    stock: stock,
                    description: descCtrl.text.trim(),
                  );
                  ref.read(menuListProvider.notifier).addItem(newItem);
                } else {
                  final updated = existing.copyWith(
                    name: name,
                    categoryId: selectedCat,
                    price: price,
                    stock: stock,
                    description: descCtrl.text.trim(),
                  );
                  ref.read(menuListProvider.notifier).updateItem(updated);
                }

                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStockDialog(BuildContext context, WidgetRef ref, MenuItemModel item) {
    final ctrl = TextEditingController(text: item.stock.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Atur Stok: ${item.name}'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Jumlah Porsi Tersedia'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(ctrl.text) ?? item.stock;
              ref.read(menuListProvider.notifier).updateStock(item.id, newStock);
              Navigator.pop(context);
            },
            child: const Text('Update Stok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = ref.watch(menuListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Menu & Stok WARDON'),
        actions: [
          IconButton(
            tooltip: 'Reset ke data menu awal',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(menuListProvider.notifier).resetToDefault();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu direset ke daftar default WARDON.')),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tambah Menu'),
              onPressed: () => _showFormDialog(context, ref),
            ),
          ),
        ],
      ),
      body: menuItems.isEmpty
          ? const Center(child: Text('Belum ada menu.'))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: menuItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final item = menuItems[idx];
                final isOutOfStock = item.stock <= 0;

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.coffee_rounded,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(item.categoryId.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${CurrencyFormatter.format(item.price)} • ${item.description ?? "Tanpa deskripsi"}',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _showStockDialog(context, ref, item),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: (isOutOfStock ? AppColors.error : AppColors.success).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 14, color: isOutOfStock ? AppColors.error : AppColors.success),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.stock} porsi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isOutOfStock ? AppColors.error : AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => _showFormDialog(context, ref, item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          onPressed: () {
                            ref.read(menuListProvider.notifier).deleteItem(item.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

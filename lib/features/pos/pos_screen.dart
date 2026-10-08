import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/sample_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../../providers/menu_provider.dart';
import 'widgets/cart_panel.dart';
import 'widgets/menu_card.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMenu = ref.watch(filteredMenuProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);
    final cart = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      body: Row(
        children: [
          // Left: Menu & Categories
          Expanded(
            flex: isDesktop ? 6 : 10,
            child: Column(
              children: [
                // Search & Filter Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Cari kopi, makanan, camilan WARDON...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 20),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      ref.read(searchQueryProvider.notifier).setQuery('');
                                      setState(() {});
                                    },
                                  )
                                : null,
                            isDense: true,
                          ),
                          onChanged: (val) {
                            ref.read(searchQueryProvider.notifier).setQuery(val);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Chips
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: SampleData.defaultCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = SampleData.defaultCategories[idx];
                      final isSelected = selectedCat == cat.id;

                      return ChoiceChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            ref.read(selectedCategoryProvider.notifier).setCategory(cat.id);
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Menu Grid
                Expanded(
                  child: filteredMenu.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 54,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada menu yang sesuai',
                                style: TextStyle(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            // Calculate column count based on available width
                            int crossAxisCount = 2;
                            if (constraints.maxWidth > 800) {
                              crossAxisCount = 4;
                            } else if (constraints.maxWidth > 550) {
                              crossAxisCount = 3;
                            }

                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.88,
                              ),
                              itemCount: filteredMenu.length,
                              itemBuilder: (context, index) {
                                final item = filteredMenu[index];
                                return MenuCard(
                                  item: item,
                                  onAddToCart: () {
                                    ref.read(cartProvider.notifier).addItem(item);
                                  },
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Right: Cart Panel for Desktop / Tablet
          if (isDesktop)
            const SizedBox(
              width: 380,
              child: CartPanel(),
            ),
        ],
      ),

      // Mobile Bottom Cart Sheet Bar
      bottomNavigationBar: !isDesktop && !cart.isEmpty
          ? Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cart.totalQuantity} Item dalam Keranjang',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(cart.total),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Buka Keranjang'),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (_) => const SizedBox(
                          height: 600,
                          child: CartPanel(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

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
      body: SafeArea(
        child: Row(
          children: [
            // Left: Menu & Categories
            Expanded(
              flex: isDesktop ? 6 : 10,
              child: Column(
                children: [
                  // Modern Card Header below Status Bar
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    padding: const EdgeInsets.all(10),
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
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                (isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary)
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.coffee_rounded,
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              hintText: 'Cari menu kopi, makanan, camilan...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                size: 20,
                              ),
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear_rounded,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        ref
                                            .read(searchQueryProvider.notifier)
                                            .setQuery('');
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              isDense: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 10,
                              ),
                            ),
                            onChanged: (val) {
                              ref
                                  .read(searchQueryProvider.notifier)
                                  .setQuery(val);
                              setState(() {});
                            },
                          ),
                        ),
                        if (!isDesktop) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            tooltip: 'Buka Keranjang',
                            icon: Badge(
                              isLabelVisible: !cart.isEmpty,
                              label: Text('${cart.totalQuantity}'),
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary,
                              ),
                            ),
                            onPressed: () => _openCartBottomSheet(context),
                          ),
                        ],
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
                              ref
                                  .read(selectedCategoryProvider.notifier)
                                  .setCategory(cat.id);
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
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tidak ada menu yang sesuai',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight,
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
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
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
                                      ref
                                          .read(cartProvider.notifier)
                                          .addItem(item);
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
            if (isDesktop) const SizedBox(width: 380, child: CartPanel()),
          ],
        ),
      ),

      // Mobile Floating Cart Button
      floatingActionButton: !isDesktop && !cart.isEmpty
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: Badge(
                label: Text('${cart.totalQuantity}'),
                child: const Icon(Icons.shopping_bag_rounded),
              ),
              label: Text(
                'Keranjang (${CurrencyFormatter.format(cart.total)})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _openCartBottomSheet(context),
            )
          : null,
    );
  }

  void _openCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          child: CartPanel(),
        ),
      ),
    );
  }
}

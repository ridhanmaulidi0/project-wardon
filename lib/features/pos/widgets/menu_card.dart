import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/menu_item_model.dart';

class MenuCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onAddToCart;

  const MenuCard({
    super.key,
    required this.item,
    required this.onAddToCart,
  });

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'kopi':
        return Icons.coffee_rounded;
      case 'non_kopi':
        return Icons.local_drink_rounded;
      case 'makanan':
        return Icons.restaurant_rounded;
      case 'snack':
        return Icons.bakery_dining_rounded;
      default:
        return Icons.fastfood_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOutOfStock = item.stock <= 0;
    final isLowStock = item.stock > 0 && item.stock <= 5;

    return InkWell(
      onTap: isOutOfStock ? null : onAddToCart,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon + Stock Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCategoryIcon(item.categoryId),
                      size: 20,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? AppColors.error.withValues(alpha: 0.15)
                          : isLowStock
                              ? AppColors.warning.withValues(alpha: 0.15)
                              : AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isOutOfStock ? 'Habis' : 'Stok: ${item.stock}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isOutOfStock
                            ? AppColors.error
                            : isLowStock
                                ? AppColors.warning
                                : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Name
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),

              // Price & Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyFormatter.format(item.price),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.primaryLight : AppColors.amberCoffee,
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? Colors.grey.withValues(alpha: 0.2)
                          : (isDark ? AppColors.primaryLight : AppColors.primary),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: isOutOfStock
                          ? Colors.grey
                          : (isDark ? AppColors.bgDark : Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


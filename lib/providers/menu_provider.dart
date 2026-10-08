import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_item_model.dart';
import '../services/storage_service.dart';
import '../core/constants/sample_data.dart';

class MenuListNotifier extends Notifier<List<MenuItemModel>> {
  @override
  List<MenuItemModel> build() {
    _load();
    return SampleData.defaultMenuItems;
  }

  Future<void> _load() async {
    final items = await StorageService.loadMenuItems();
    state = items;
  }

  Future<void> addItem(MenuItemModel item) async {
    final updated = [...state, item];
    state = updated;
    await StorageService.saveMenuItems(updated);
  }

  Future<void> updateItem(MenuItemModel updatedItem) async {
    final updated = state.map((item) {
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();
    state = updated;
    await StorageService.saveMenuItems(updated);
  }

  Future<void> deleteItem(String id) async {
    final updated = state.where((item) => item.id != id).toList();
    state = updated;
    await StorageService.saveMenuItems(updated);
  }

  Future<void> updateStock(String id, int newStock) async {
    final updated = state.map((item) {
      if (item.id == id) {
        return item.copyWith(stock: newStock);
      }
      return item;
    }).toList();
    state = updated;
    await StorageService.saveMenuItems(updated);
  }

  Future<void> decrementStocks(Map<String, int> itemQuantities) async {
    final updated = state.map((item) {
      if (itemQuantities.containsKey(item.id)) {
        final qty = itemQuantities[item.id]!;
        final newStock = (item.stock - qty).clamp(0, 99999);
        return item.copyWith(stock: newStock);
      }
      return item;
    }).toList();
    state = updated;
    await StorageService.saveMenuItems(updated);
  }

  Future<void> resetToDefault() async {
    state = SampleData.defaultMenuItems;
    await StorageService.saveMenuItems(SampleData.defaultMenuItems);
  }
}

final menuListProvider = NotifierProvider<MenuListNotifier, List<MenuItemModel>>(MenuListNotifier.new);

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void setCategory(String category) => state = category;
}

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, String>(SelectedCategoryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final filteredMenuProvider = Provider<List<MenuItemModel>>((ref) {
  final menuList = ref.watch(menuListProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  return menuList.where((item) {
    final matchesCategory = category == 'all' || item.categoryId == category;
    final matchesQuery = query.isEmpty ||
        item.name.toLowerCase().contains(query) ||
        (item.description != null && item.description!.toLowerCase().contains(query));
    return matchesCategory && matchesQuery;
  }).toList();
});


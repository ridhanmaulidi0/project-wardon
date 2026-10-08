import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_item_model.dart';
import '../models/order_item_model.dart';

class CartState {
  final List<OrderItemModel> items;
  final int discount;
  final double taxRate;
  final bool enableTax;
  final String? customerName;

  const CartState({
    this.items = const [],
    this.discount = 0,
    this.taxRate = 0.11,
    this.enableTax = false,
    this.customerName,
  });

  int get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  int get tax => enableTax ? (subtotal * taxRate).round() : 0;
  int get total => (subtotal - discount + tax).clamp(0, 999999999);
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<OrderItemModel>? items,
    int? discount,
    double? taxRate,
    bool? enableTax,
    String? customerName,
  }) {
    return CartState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
      enableTax: enableTax ?? this.enableTax,
      customerName: customerName ?? this.customerName,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return const CartState();
  }

  void addItem(MenuItemModel menuItem) {
    if (menuItem.stock <= 0) return;

    final index = state.items.indexWhere((e) => e.menuItemId == menuItem.id);
    if (index >= 0) {
      final current = state.items[index];
      if (current.quantity >= menuItem.stock) return;

      final updatedList = List<OrderItemModel>.from(state.items);
      updatedList[index] = current.copyWith(quantity: current.quantity + 1);
      state = state.copyWith(items: updatedList);
    } else {
      final newItem = OrderItemModel(
        menuItemId: menuItem.id,
        name: menuItem.name,
        unitPrice: menuItem.price,
        quantity: 1,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void increaseQuantity(String menuItemId) {
    final index = state.items.indexWhere((e) => e.menuItemId == menuItemId);
    if (index >= 0) {
      final current = state.items[index];
      final updatedList = List<OrderItemModel>.from(state.items);
      updatedList[index] = current.copyWith(quantity: current.quantity + 1);
      state = state.copyWith(items: updatedList);
    }
  }

  void decreaseQuantity(String menuItemId) {
    final index = state.items.indexWhere((e) => e.menuItemId == menuItemId);
    if (index >= 0) {
      final current = state.items[index];
      if (current.quantity > 1) {
        final updatedList = List<OrderItemModel>.from(state.items);
        updatedList[index] = current.copyWith(quantity: current.quantity - 1);
        state = state.copyWith(items: updatedList);
      } else {
        removeItem(menuItemId);
      }
    }
  }

  void removeItem(String menuItemId) {
    final updatedList = state.items.where((e) => e.menuItemId != menuItemId).toList();
    state = state.copyWith(items: updatedList);
  }

  void updateNotes(String menuItemId, String? notes) {
    final index = state.items.indexWhere((e) => e.menuItemId == menuItemId);
    if (index >= 0) {
      final updatedList = List<OrderItemModel>.from(state.items);
      updatedList[index] = updatedList[index].copyWith(notes: notes);
      state = state.copyWith(items: updatedList);
    }
  }

  void setDiscount(int discountAmount) {
    state = state.copyWith(discount: discountAmount);
  }

  void setCustomerName(String? name) {
    state = state.copyWith(customerName: name);
  }

  void setTaxEnabled(bool enabled, [double? rate]) {
    state = state.copyWith(enableTax: enabled, taxRate: rate ?? state.taxRate);
  }

  void clearCart() {
    state = const CartState();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../services/storage_service.dart';
import 'cart_provider.dart';
import 'menu_provider.dart';

class OrderListNotifier extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final orders = await StorageService.loadOrders();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = orders;
  }

  Future<OrderModel?> completeCheckout({
    required String cashierName,
    required PaymentMethod paymentMethod,
    required int cashReceived,
  }) async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return null;

    final now = DateTime.now();
    final todayCount = state.where((o) =>
        o.createdAt.year == now.year &&
        o.createdAt.month == now.month &&
        o.createdAt.day == now.day).length + 1;

    final dateCode = DateFormat('yyyyMMdd').format(now);
    final orderNum = 'WRD-$dateCode-${todayCount.toString().padLeft(3, '0')}';

    final change = (cashReceived - cart.total).clamp(0, 999999999).toInt();

    final newOrder = OrderModel(
      id: const Uuid().v4(),
      orderNumber: orderNum,
      cashierName: cashierName,
      items: List.from(cart.items),
      paymentMethod: paymentMethod,
      paymentStatus: 'paid',
      subtotal: cart.subtotal,
      discount: cart.discount,
      tax: cart.tax,
      total: cart.total,
      cashReceived: paymentMethod == PaymentMethod.tunai ? cashReceived : cart.total,
      change: paymentMethod == PaymentMethod.tunai ? change : 0,
      createdAt: now,
      customerName: cart.customerName,
    );

    // Decrement stocks
    final stockMap = <String, int>{};
    for (final item in cart.items) {
      stockMap[item.menuItemId] = (stockMap[item.menuItemId] ?? 0) + item.quantity;
    }
    await ref.read(menuListProvider.notifier).decrementStocks(stockMap);

    // Save order
    final updatedOrders = [newOrder, ...state];
    state = updatedOrders;
    await StorageService.saveOrders(updatedOrders);

    // Clear cart
    ref.read(cartProvider.notifier).clearCart();

    return newOrder;
  }
}

final orderListProvider = NotifierProvider<OrderListNotifier, List<OrderModel>>(OrderListNotifier.new);

enum ReportPeriod { hariIni, mingguIni, bulanIni, tahunIni, semua }

class ReportPeriodNotifier extends Notifier<ReportPeriod> {
  @override
  ReportPeriod build() => ReportPeriod.hariIni;

  void setPeriod(ReportPeriod period) => state = period;
}

final reportPeriodProvider = NotifierProvider<ReportPeriodNotifier, ReportPeriod>(ReportPeriodNotifier.new);

final filteredOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(orderListProvider);
  final period = ref.watch(reportPeriodProvider);
  final now = DateTime.now();

  return orders.where((order) {
    switch (period) {
      case ReportPeriod.hariIni:
        return order.createdAt.year == now.year &&
            order.createdAt.month == now.month &&
            order.createdAt.day == now.day;
      case ReportPeriod.mingguIni:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final cleanStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return order.createdAt.isAfter(cleanStart.subtract(const Duration(seconds: 1)));
      case ReportPeriod.bulanIni:
        return order.createdAt.year == now.year && order.createdAt.month == now.month;
      case ReportPeriod.tahunIni:
        return order.createdAt.year == now.year;
      case ReportPeriod.semua:
        return true;
    }
  }).toList();
});

class TopSellingItem {
  final String name;
  final int totalQty;
  final int totalRevenue;

  TopSellingItem({required this.name, required this.totalQty, required this.totalRevenue});
}

final topSellingItemsProvider = Provider<List<TopSellingItem>>((ref) {
  final orders = ref.watch(filteredOrdersProvider);
  final map = <String, Map<String, dynamic>>{};

  for (final order in orders) {
    for (final item in order.items) {
      if (!map.containsKey(item.name)) {
        map[item.name] = {'qty': 0, 'revenue': 0};
      }
      map[item.name]!['qty'] = (map[item.name]!['qty'] as int) + item.quantity;
      map[item.name]!['revenue'] = (map[item.name]!['revenue'] as int) + item.subtotal;
    }
  }

  final list = map.entries.map((e) {
    return TopSellingItem(
      name: e.key,
      totalQty: e.value['qty'] as int,
      totalRevenue: e.value['revenue'] as int,
    );
  }).toList();

  list.sort((a, b) => b.totalQty.compareTo(a.totalQty));
  return list;
});


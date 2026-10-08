import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';
import '../models/store_settings_model.dart';
import '../models/user_model.dart';
import '../core/constants/sample_data.dart';

class StorageService {
  static const _keyMenu = 'wardon_menu_items';
  static const _keyOrders = 'wardon_orders';
  static const _keySettings = 'wardon_settings';
  static const _keyUser = 'wardon_current_user';
  static const _keyTheme = 'wardon_is_dark_mode';

  static Future<List<MenuItemModel>> loadMenuItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyMenu);
    if (data == null) {
      await saveMenuItems(SampleData.defaultMenuItems);
      return SampleData.defaultMenuItems;
    }
    try {
      final list = jsonDecode(data) as List;
      return list.map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return SampleData.defaultMenuItems;
    }
  }

  static Future<void> saveMenuItems(List<MenuItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_keyMenu, jsonString);
  }

  static Future<List<OrderModel>> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyOrders);
    if (data == null) return [];
    try {
      final list = jsonDecode(data) as List;
      return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveOrders(List<OrderModel> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(orders.map((e) => e.toJson()).toList());
    await prefs.setString(_keyOrders, jsonString);
  }

  static Future<StoreSettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keySettings);
    if (data == null) return const StoreSettingsModel();
    try {
      return StoreSettingsModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return const StoreSettingsModel();
    }
  }

  static Future<void> saveSettings(StoreSettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, jsonEncode(settings.toJson()));
  }

  static Future<UserModel?> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUser);
    if (data == null) return SampleData.defaultUsers.first; // Default Admin
    try {
      return UserModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return SampleData.defaultUsers.first;
    }
  }

  static Future<void> saveCurrentUser(UserModel? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_keyUser);
    } else {
      await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    }
  }

  static Future<bool> loadIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTheme) ?? false;
  }

  static Future<void> saveIsDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTheme, isDark);
  }
}


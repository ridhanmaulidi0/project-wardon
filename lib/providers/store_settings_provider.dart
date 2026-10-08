import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store_settings_model.dart';
import '../services/storage_service.dart';

class StoreSettingsNotifier extends Notifier<StoreSettingsModel> {
  @override
  StoreSettingsModel build() {
    _init();
    return const StoreSettingsModel();
  }

  Future<void> _init() async {
    final settings = await StorageService.loadSettings();
    state = settings;
  }

  Future<void> updateSettings(StoreSettingsModel newSettings) async {
    state = newSettings;
    await StorageService.saveSettings(newSettings);
  }
}

final storeSettingsProvider = NotifierProvider<StoreSettingsNotifier, StoreSettingsModel>(StoreSettingsNotifier.new);


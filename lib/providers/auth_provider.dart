import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../core/constants/sample_data.dart';

class AuthNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() {
    _init();
    return SampleData.defaultUsers.first;
  }

  Future<void> _init() async {
    final user = await StorageService.loadCurrentUser();
    state = user ?? SampleData.defaultUsers.first;
  }

  Future<void> loginAs(UserModel user) async {
    state = user;
    await StorageService.saveCurrentUser(user);
  }

  Future<void> loginWithCredentials(String email, String password) async {
    final match = SampleData.defaultUsers.firstWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@').first.toUpperCase(),
        email: email,
        role: email.contains('admin') ? UserRole.admin : UserRole.kasir,
      ),
    );
    state = match;
    await StorageService.saveCurrentUser(match);
  }

  Future<void> logout() async {
    state = null;
    await StorageService.saveCurrentUser(null);
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);


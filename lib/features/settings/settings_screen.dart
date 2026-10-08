import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/store_settings_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_settings_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _taglineCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(storeSettingsProvider);
    _nameCtrl = TextEditingController(text: settings.storeName);
    _taglineCtrl = TextEditingController(text: settings.tagline);
    _addressCtrl = TextEditingController(text: settings.address);
    _phoneCtrl = TextEditingController(text: settings.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final current = ref.read(storeSettingsProvider);
    final StoreSettingsModel updated = current.copyWith(
      storeName: _nameCtrl.text.trim(),
      tagline: _taglineCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    ref.read(storeSettingsProvider.notifier).updateSettings(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan toko WARDON berhasil disimpan!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan WARDON POS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        child: Icon(
                          user?.isAdmin == true ? Icons.shield_rounded : Icons.person_rounded,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? 'Pengguna', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(
                              'Role: ${user?.role.name.toUpperCase()} • ${user?.email}',
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.logout_rounded, size: 16),
                        label: const Text('Keluar'),
                        onPressed: () => ref.read(authProvider.notifier).logout(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Appearance (Dark / Light)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColors.amberCoffee),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tema Tampilan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(
                                isDark ? 'Mode Gelap (Dark Mode)' : 'Mode Terang (Light Mode)',
                                style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: isDark,
                        onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Store Profile Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.storefront_rounded, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Profil & Struk Warung Kopi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nama Toko'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _taglineCtrl,
                        decoration: const InputDecoration(labelText: 'Tagline / Slogan'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _addressCtrl,
                        decoration: const InputDecoration(labelText: 'Alamat Toko (muncul di struk)'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Nomor Telepon / WhatsApp'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Simpan Profil WARDON'),
                        onPressed: _saveSettings,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Hardware & Gateway Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Integrasi Hardware & Payment Gateway', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.print_rounded, color: AppColors.success),
                        title: const Text('Printer Thermal (Bluetooth / USB)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Siap mencetak kertas 58mm / 80mm', style: TextStyle(fontSize: 11)),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.credit_card_rounded, color: AppColors.info),
                        title: const Text('Midtrans Payment Gateway (QRIS / GoPay / Transfer)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Status: Siap dihubungkan dengan Client Key', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

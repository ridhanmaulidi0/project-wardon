import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'menu/menu_management_screen.dart';
import 'orders/order_history_screen.dart';
import 'pos/pos_screen.dart';
import 'reports/report_screen.dart';
import 'settings/settings_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final isAdmin = user?.isAdmin == true;

    // Define navigation items based on role
    final navItems = <_NavItem>[
      const _NavItem(
        title: 'Kasir',
        icon: Icons.point_of_sale_rounded,
        screen: PosScreen(),
      ),
      const _NavItem(
        title: 'Dashboard',
        icon: Icons.dashboard_rounded,
        screen: DashboardScreen(),
      ),
      const _NavItem(
        title: 'Riwayat',
        icon: Icons.receipt_long_rounded,
        screen: OrderHistoryScreen(),
      ),
      if (isAdmin) ...[
        const _NavItem(
          title: 'Menu & Stok',
          icon: Icons.restaurant_menu_rounded,
          screen: MenuManagementScreen(),
        ),
        const _NavItem(
          title: 'Laporan',
          icon: Icons.bar_chart_rounded,
          screen: ReportScreen(),
        ),
      ],
      const _NavItem(
        title: 'Pengaturan',
        icon: Icons.settings_rounded,
        screen: SettingsScreen(),
      ),
    ];

    if (_currentIndex >= navItems.length) {
      _currentIndex = 0;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 800;

    return Scaffold(
      body: Row(
        children: [
          // Desktop / Tablet Side Navigation Rail
          if (isWide)
            NavigationRail(
              extended: screenWidth >= 1100,
              minExtendedWidth: 190,
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              selectedIndex: _currentIndex,
              onDestinationSelected: (val) =>
                  setState(() => _currentIndex = val),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.coffee_rounded,
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        size: 24,
                      ),
                    ),
                    if (screenWidth >= 1100) ...[
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'WARDON',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            user?.role.name.toUpperCase() ?? 'KASIR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                      ),
                      onPressed: () =>
                          ref.read(themeModeProvider.notifier).toggleTheme(),
                    ),
                  ),
                ),
              ),
              destinations: navItems.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(
                    item.icon,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                  label: Text(item.title),
                );
              }).toList(),
            ),

          if (isWide)
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: isDark
                  ? AppColors.cardBorderDark
                  : AppColors.cardBorderLight,
            ),

          // Main View Content
          Expanded(child: navItems[_currentIndex].screen),
        ],
      ),

      // Mobile Floating Bottom Navigation Bar
      bottomNavigationBar: !isWide
          ? SafeArea(
              top: false,
              bottom: true,
              child: Container(
                height: 60,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? AppColors.cardBorderDark
                        : AppColors.cardBorderLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.35 : 0.08,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(navItems.length, (index) {
                      final item = navItems[index];
                      final isSelected = _currentIndex == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => setState(() => _currentIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: isSelected ? 14 : 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                        ? AppColors.primaryLight.withValues(
                                            alpha: 0.2,
                                          )
                                        : AppColors.primary.withValues(
                                            alpha: 0.12,
                                          ))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 20,
                                  color: isSelected
                                      ? (isDark
                                            ? AppColors.primaryLight
                                            : AppColors.primary)
                                      : (isDark
                                            ? AppColors.textMutedDark
                                            : AppColors.textMutedLight),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _NavItem {
  final String title;
  final IconData icon;
  final Widget screen;

  const _NavItem({
    required this.title,
    required this.icon,
    required this.screen,
  });
}

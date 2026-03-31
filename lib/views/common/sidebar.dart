import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../routes/route_names.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  const _NavItem(this.label, this.icon, this.activeIcon, this.route);
}

const _navItems = [
  _NavItem('Dashboard', Icons.dashboard_outlined, Icons.dashboard,
      RouteNames.dashboard),
  _NavItem('Users', Icons.people_outlined, Icons.people, RouteNames.users),
  _NavItem('Categories', Icons.category_outlined, Icons.category,
      RouteNames.categories),
  _NavItem(
      'Products', Icons.inventory_2_outlined, Icons.inventory_2, RouteNames.products),
  _NavItem('Bookings', Icons.calendar_month_outlined, Icons.calendar_month,
      RouteNames.bookings),
];

class AdminSidebar extends StatelessWidget {
  final bool collapsed;
  const AdminSidebar({super.key, this.collapsed = false});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Material(
      color: AppColors.sidebarBg,
      child: Container(
        width: collapsed ? AppConstants.sidebarCollapsedWidth : AppConstants.sidebarWidth,
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: Color(0xFF1E2D42), width: 1),
          ),
        ),
        child: Column(
          children: [
            _buildLogo(collapsed),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                children: _navItems.map((item) {
                  final isActive = location.startsWith(item.route) &&
                      (item.route == RouteNames.dashboard
                          ? location == RouteNames.dashboard
                          : true);
                  return _NavTile(
                    item: item,
                    isActive: isActive,
                    collapsed: collapsed,
                    onTap: () => context.go(item.route),
                  );
                }).toList(),
              ),
            ),
            _buildFooter(context, collapsed),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(bool collapsed) {
    return Container(
      height: AppConstants.topbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E2D42), width: 1),
        ),
      ),
      child: collapsed
          ? const Center(
              child: Icon(Icons.medical_services, color: AppColors.primaryLighter, size: 26),
            )
          : Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.medical_services,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medigo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: AppColors.sidebarText,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildFooter(BuildContext context, bool collapsed) {
    final auth = context.read<AuthProvider>();
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF1E2D42))),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 16, vertical: 8),
        leading: collapsed 
            ? null 
            : const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white, size: 16),
              ),
        title: collapsed
            ? Center(
                child: IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.sidebarText, size: 18),
                  onPressed: () => auth.signOut(),
                ),
              )
            : Text(
                auth.currentUser?.email ?? 'Admin',
                style: const TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
        trailing: collapsed
            ? null
            : IconButton(
                icon: const Icon(Icons.logout, color: AppColors.sidebarText, size: 18),
                onPressed: () => auth.signOut(),
                tooltip: 'Logout',
              ),
        onTap: collapsed ? null : null, // Prevent double tap issue if any
        horizontalTitleGap: 10,
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isActive ? AppColors.sidebarActive : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 0 : 12,
              vertical: 11,
            ),
            child: collapsed
                ? Center(
                    child: Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: isActive
                          ? Colors.white
                          : AppColors.sidebarText,
                      size: 20,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive ? Colors.white : AppColors.sidebarText,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : AppColors.sidebarText,
                          fontSize: 14,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

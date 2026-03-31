import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'sidebar.dart';
import 'topbar.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;
  const AdminLayout({super.key, required this.child});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < AppConstants.mobileBreakpoint;
    final isTablet = width < AppConstants.tabletBreakpoint;

    if (isMobile) {
      return _MobileLayout(child: widget.child);
    }

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminSidebar(collapsed: isTablet ? true : _sidebarCollapsed),
          Expanded(
            child: Column(
              children: [
                AdminTopBar(
                  title: 'Medigo Admin',
                  onMenuTap: () => setState(
                      () => _sidebarCollapsed = !_sidebarCollapsed),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final Widget child;
  const _MobileLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(child: AdminSidebar()),
      body: Builder(
        builder: (ctx) => Column(
          children: [
            Container(
              height: AppConstants.topbarHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Medigo Admin',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

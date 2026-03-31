import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class AdminTopBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onMenuTap;

  const AdminTopBar({
    super.key,
    required this.title,
    this.actions,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.topbarHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (onMenuTap != null)
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textSecondary),
              onPressed: onMenuTap,
            ),
          // Breadcrumb
          _Breadcrumb(location: GoRouterState.of(context).matchedLocation),
          const Spacer(),
          if (actions != null) ...actions!,
          const SizedBox(width: 8),
          _NotificationBell(),
        ],
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  final String location;
  const _Breadcrumb({required this.location});

  String _routeLabel(String location) {
    if (location == '/dashboard') return 'Dashboard';
    if (location.startsWith('/users')) return 'Users';
    if (location.startsWith('/categories')) return 'Categories';
    if (location.startsWith('/products')) return 'Products';
    if (location.startsWith('/bookings')) return 'Bookings';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final label = _routeLabel(location);
    return Row(
      children: [
        const Icon(Icons.home_outlined, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        const Text('/',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textSecondary),
          onPressed: () {},
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable page header widget
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

/// Card container
class ContentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final Widget? titleAction;
  final bool expand;

  const ContentCard({
    super.key,
    required this.child,
    this.padding,
    this.title,
    this.titleAction,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );

    if (expand) {
      content = Expanded(child: content);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  Text(title!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      )),
                  const Spacer(),
                  if (titleAction != null) titleAction!,
                ],
              ),
            ),
          content,
        ],
      ),
    );
  }
}

/// Status badge
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  Color get _bg {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFFFF8E1);
      case 'confirmed': return const Color(0xFFE3F2FD);
      case 'completed': return const Color(0xFFE8F5E9);
      case 'cancelled': return const Color(0xFFFFEBEE);
      case 'active': return const Color(0xFFE8F5E9);
      case 'inactive': return const Color(0xFFFFEBEE);
      default: return const Color(0xFFF5F5F5);
    }
  }

  Color get _fg {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFF57F17);
      case 'confirmed': return const Color(0xFF1565C0);
      case 'completed': return const Color(0xFF2E7D32);
      case 'cancelled': return const Color(0xFFC62828);
      case 'active': return const Color(0xFF2E7D32);
      case 'inactive': return const Color(0xFFC62828);
      default: return const Color(0xFF616161);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? '' : status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
            color: _fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

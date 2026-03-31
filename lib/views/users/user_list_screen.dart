import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/loading_widget.dart';
import '../../providers/user_provider.dart';
import '../common/topbar.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Users',
              subtitle: '${provider.totalCount} total users',
            ),
            const SizedBox(height: 24),

            // Filters
            ContentCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: provider.setSearch,
                      decoration: InputDecoration(
                        hintText: 'Search by name, email or phone...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.cardBorder)),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Table
            Expanded(
              child: ContentCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _TableHeader(),
                    Expanded(
                      child: provider.users.isEmpty
                          ? const EmptyWidget(
                              message: 'No users found',
                              icon: Icons.people_outline)
                          : ListView.separated(
                              itemCount: provider.users.length,
                              separatorBuilder: (_, __) => const Divider(
                                  height: 1, color: AppColors.cardBorder),
                              itemBuilder: (ctx, i) => _UserRow(
                                user: provider.users[i],
                                onDelete: () async {
                                  final ok = await Helpers.showConfirmDialog(
                                    ctx,
                                    title: 'Delete User',
                                    message:
                                        'Are you sure you want to delete this user?',
                                  );
                                  if (ok) {
                                    provider.deleteUser(provider.users[i].id);
                                  }
                                },
                                onView: () => context.go(
                                    '/users/${provider.users[i].id}'),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        border:
            Border(bottom: BorderSide(color: AppColors.cardBorder)),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('User', style: _headerStyle)),
          Expanded(flex: 2, child: Text('Email', style: _headerStyle)),
          Expanded(child: Text('Phone', style: _headerStyle)),
          SizedBox(width: 100, child: Text('Actions', style: _headerStyle)),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
}

class _UserRow extends StatelessWidget {
  final dynamic user;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const _UserRow({
    required this.user,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySurface,
                  backgroundImage: user.profilePicUrl.isNotEmpty
                      ? NetworkImage(user.profilePicUrl)
                      : null,
                  child: user.profilePicUrl.isEmpty
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(user.email,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: Text(user.phone.isEmpty ? '—' : user.phone,
                style: const TextStyle(fontSize: 13)),
          ),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined,
                      size: 18, color: AppColors.primary),
                  onPressed: onView,
                  tooltip: 'View',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppColors.error),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

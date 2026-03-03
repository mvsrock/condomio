import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onLogout,
    required this.isAdmin,
    this.activeCondominioLabel,
    this.onManageCondomini,
    this.onOpenAdminUsers,
    this.onOpenAdminRoles,
  });

  final VoidCallback onLogout;
  final bool isAdmin;
  final String? activeCondominioLabel;
  final VoidCallback? onManageCondomini;
  final VoidCallback? onOpenAdminUsers;
  final VoidCallback? onOpenAdminRoles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Icon(Icons.apartment_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Condominio Control Center',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (activeCondominioLabel != null &&
              activeCondominioLabel!.trim().isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF7ED),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.home_work_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    activeCondominioLabel!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
          IconButton(
            tooltip: 'Gestisci condomini',
            onPressed: onManageCondomini,
            icon: const Icon(Icons.home_work_outlined),
          ),
          const SizedBox(width: 12),
          if (isAdmin) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Amministratore',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            PopupMenuButton<_AdminMenuAction>(
              tooltip: 'Gestione utenti e ruoli',
              position: PopupMenuPosition.under,
              offset: const Offset(0, 8),
              elevation: 10,
              color: Colors.white,
              shadowColor: Colors.black26,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              constraints: const BoxConstraints(minWidth: 260),
              onSelected: (action) {
                switch (action) {
                  case _AdminMenuAction.users:
                    onOpenAdminUsers?.call();
                    break;
                  case _AdminMenuAction.roles:
                    onOpenAdminRoles?.call();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  height: 42,
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Amministrazione',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem(
                  value: _AdminMenuAction.users,
                  height: 56,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: _AdminMenuItemTile(
                    icon: Icons.manage_accounts_outlined,
                    title: 'Gestione Utenti',
                    subtitle: 'Crea, modifica e disabilita utenti',
                  ),
                ),
                PopupMenuItem(
                  value: _AdminMenuAction.roles,
                  height: 56,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: const _AdminMenuItemTile(
                    icon: Icons.policy_outlined,
                    title: 'Gestione Ruoli',
                    subtitle: 'Definisci ruoli e permessi',
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.manage_accounts_outlined, size: 18),
                    SizedBox(width: 4),
                    Icon(Icons.shield_outlined, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          FilledButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

enum _AdminMenuAction { users, roles }

class _AdminMenuItemTile extends StatelessWidget {
  const _AdminMenuItemTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

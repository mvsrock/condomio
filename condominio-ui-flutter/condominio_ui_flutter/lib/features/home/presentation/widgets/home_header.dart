import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onLogout,
    required this.isAdmin,
    this.activeCondominioLabel,
    this.activeExerciseClosed = false,
    this.onManageCondomini,
  });

  final VoidCallback onLogout;
  final bool isAdmin;
  final String? activeCondominioLabel;
  final bool activeExerciseClosed;
  final VoidCallback? onManageCondomini;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCondominio =
        activeCondominioLabel != null &&
        activeCondominioLabel!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 980;

          if (isCompact) {
            return Row(
              children: [
                Icon(
                  Icons.apartment_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Condominio',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: hasCondominio
                      ? 'Condominio attivo: ${activeCondominioLabel!}. Tocca per cambiare'
                      : 'Scegli condominio',
                  onPressed: onManageCondomini,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFEFF7ED),
                  ),
                  icon: const Icon(Icons.swap_horiz),
                ),
                if (hasCondominio && activeExerciseClosed)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.lock_outline, size: 18),
                  ),
                IconButton(
                  tooltip: 'Logout',
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout),
                ),
              ],
            );
          }

          return Row(
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
              if (hasCondominio) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
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
                      if (activeExerciseClosed) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.lock_outline, size: 16),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Cambia esercizio',
                  onPressed: onManageCondomini,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFEFF7ED),
                  ),
                  icon: const Icon(Icons.swap_horiz),
                ),
                const SizedBox(width: 12),
              ] else ...[
                IconButton(
                  tooltip: 'Cambia esercizio',
                  onPressed: onManageCondomini,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFEFF7ED),
                  ),
                  icon: const Icon(Icons.swap_horiz),
                ),
                const SizedBox(width: 12),
              ],
              if (isAdmin) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
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
              ],
              FilledButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          );
        },
      ),
    );
  }
}

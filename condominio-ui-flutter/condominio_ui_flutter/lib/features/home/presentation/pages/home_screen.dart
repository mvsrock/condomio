import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_breakpoints.dart';
import '../../../../utils/app_logger.dart';
import '../../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../../auth/application/auth_notifier.dart';
import '../../application/home_navigation_provider.dart';
import '../../../home/application/home_ui_notifier.dart';
import '../widgets/home_bottom_navigation.dart';
import '../widgets/home_content_surface.dart';
import '../widgets/home_header.dart';
import '../widgets/home_navigation_rail.dart';

/// Shell principale dell'area autenticata.
///
/// La selezione pagina non e' piu' guidata da `selectedIndex` in provider,
/// ma dal router (`StatefulNavigationShell`) con route reali:
/// - /home/dashboard
/// - /home/map
/// - /home/anagrafica
/// - /home/session
/// - /home/documents
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _logout() async {
    ref.read(homeUiProvider.notifier).setLoggingOut(true);
    try {
      appLog('[HomeScreen] Initiating logout...');
      await ref.read(authStateProvider.notifier).logout();
    } catch (e) {
      appLog('[HomeScreen] Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout error: $e')));
      }
    } finally {
      ref.read(homeUiProvider.notifier).setLoggingOut(false);
    }
  }

  void _onBranchSelected(int index) {
    final branchCount = widget.navigationShell.route.branches.length;
    if (index < 0 || index >= branchCount) {
      appLog(
        '[HomeScreen] Ignored invalid branch index: $index (branches=$branchCount)',
      );
      return;
    }
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggingOut = ref.watch(
      homeUiProvider.select((state) => state.isLoggingOut),
    );
    final isAdmin = ref.watch(homeIsAdminProvider);
    final destinations = ref.watch(homeDestinationsProvider);
    final activeCondominio = ref.watch(selectedManagedCondominioProvider);
    final isWide = AppBreakpoints.isHomeWide(MediaQuery.of(context).size.width);
    final selectedVisibleIndex = visibleIndexForBranch(
      destinations,
      widget.navigationShell.currentIndex,
    );

    if (isLoggingOut) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(
              onLogout: _logout,
              isAdmin: isAdmin,
              activeCondominioLabel: activeCondominio?.label,
              onManageCondomini: () => context.go('/select-condominio'),
            ),
            Expanded(
              child: isWide
                  ? Row(
                      children: [
                        HomeNavigationRail(
                          selectedIndex: selectedVisibleIndex < 0
                              ? 0
                              : selectedVisibleIndex,
                          destinations: destinations,
                          onDestinationSelected: (visibleIndex) {
                            _onBranchSelected(
                              branchIndexForVisibleIndex(
                                destinations,
                                visibleIndex,
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: HomeContentSurface(
                            isWide: isWide,
                            child: widget.navigationShell,
                          ),
                        ),
                      ],
                    )
                  : HomeContentSurface(
                      isWide: isWide,
                      child: widget.navigationShell,
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : HomeBottomNavigation(
              selectedIndex: selectedVisibleIndex < 0 ? 0 : selectedVisibleIndex,
              destinations: destinations,
              onDestinationSelected: (visibleIndex) {
                _onBranchSelected(
                  branchIndexForVisibleIndex(destinations, visibleIndex),
                );
              },
            ),
    );
  }
}

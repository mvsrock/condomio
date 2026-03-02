import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_breakpoints.dart';
import '../../../../utils/app_logger.dart';
import '../../../auth/application/auth_notifier.dart';
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
/// - /home/registry
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

  void _onDestinationSelected(int index) {
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
    final isWide = AppBreakpoints.isHomeWide(MediaQuery.of(context).size.width);

    if (isLoggingOut) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(onLogout: _logout),
            Expanded(
              child: isWide
                  ? Row(
                      children: [
                        HomeNavigationRail(
                          selectedIndex: widget.navigationShell.currentIndex,
                          onDestinationSelected: _onDestinationSelected,
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
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
            ),
    );
  }
}

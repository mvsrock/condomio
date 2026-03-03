import 'package:flutter/material.dart';

/// Destinazione di navigazione nella shell Home.
class HomeNavDestination {
  const HomeNavDestination({
    required this.branchIndex,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final int branchIndex;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

import 'package:flutter/material.dart';

class HomeContentSurface extends StatelessWidget {
  const HomeContentSurface({
    super.key,
    required this.isWide,
    required this.child,
  });

  final bool isWide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(top: isWide ? 6 : 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF2F6FA), Color(0xFFE7EEF5)],
        ),
        borderRadius: isWide
            ? const BorderRadius.only(topLeft: Radius.circular(24))
            : BorderRadius.zero,
      ),
      child: child,
    );
  }
}

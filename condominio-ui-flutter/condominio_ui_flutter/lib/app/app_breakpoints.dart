/// Breakpoint centralizzati dell'app.
///
/// Manteniamo qui tutte le soglie responsive per evitare valori "sparsi"
/// nei widget e garantire comportamento coerente tra feature.
class AppBreakpoints {
  static const double mobileMaxWidth = 767;
  static const double tabletMaxWidth = 1023;

  // Soglie specifiche feature.
  static const double homeWideMinWidth = 960;
  static const double documentsWideMinWidth = 1100;
  static const double registryCompactMaxWidth = 899;

  static bool isMobileWidth(double width) => width <= mobileMaxWidth;

  static bool isTabletWidth(double width) =>
      width > mobileMaxWidth && width <= tabletMaxWidth;

  static bool isDesktopWidth(double width) => width > tabletMaxWidth;

  static bool isHomeWide(double width) => width >= homeWideMinWidth;

  static bool isDocumentsWide(double width) => width >= documentsWideMinWidth;

  static bool isRegistryCompact(double width) =>
      width <= registryCompactMaxWidth;
}

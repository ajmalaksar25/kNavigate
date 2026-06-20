import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Karunya Navigator design system.
///
/// Direction: friendly, premium, iOS-flavoured, highly legible. Built for
/// university visitors who are not necessarily tech-savvy, so it leans on
/// familiar platform conventions (Apple's "Principles of Great Design"): clear
/// visual hierarchy, generous touch targets, calm spacing, and a small,
/// consistent set of choices per screen (Miller's Law).
///
/// Brand: Karunya **royal blue** (primary) + **gold** (accent). Crimson is
/// reserved for the map control buttons (satellite / locate) — see
/// [mapControlColor].

// ---- Brand tokens -----------------------------------------------------------
const _blue = Color(0xFF034DA2); // Karunya primary (royal blue — from site + crest)
const _blueBright = Color(0xFF6BA6F0); // lighter blue for dark mode
const _gold = Color(0xFFB59758); // Karunya accent (bronze-gold — from site)
const _goldBright = Color(0xFFD8BC82); // lighter gold for dark mode

/// Crimson, reserved for map control buttons (satellite toggle / locate).
const mapControlColor = Color(0xFFCE2028);
const onMapControlColor = Colors.white;

// iOS-style neutral surfaces (grouped-background feel).
const _lightBg = Color(0xFFF2F3F7); // app background
const _lightSurface = Color(0xFFFFFFFF); // cards / sheets
const _lightInk = Color(0xFF111418); // primary text
const _lightInkSoft = Color(0xFF5B6473); // secondary text

const _darkBg = Color(0xFF0E1116);
const _darkSurface = Color(0xFF1A1F27);
const _darkInk = Color(0xFFF4F6FA);
const _darkInkSoft = Color(0xFFA8B0BE);

// Shared shape language — rounded, soft, iOS-like.
const _rCard = 18.0;
const _rButton = 14.0;
const _rSheet = 22.0;

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: _blue,
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFDCE5F8),
  onPrimaryContainer: Color(0xFF0A2A66),
  secondary: _gold,
  onSecondary: Color(0xFF2A2000),
  secondaryContainer: Color(0xFFF6E8C8),
  onSecondaryContainer: Color(0xFF4A3A00),
  tertiary: mapControlColor,
  onTertiary: Colors.white,
  error: Color(0xFFB3261E),
  onError: Colors.white,
  surface: _lightSurface,
  onSurface: _lightInk,
  surfaceContainerLowest: Colors.white,
  surfaceContainerLow: Color(0xFFF7F8FB),
  surfaceContainer: _lightBg,
  surfaceContainerHigh: Color(0xFFE9EBF1),
  surfaceContainerHighest: Color(0xFFE3E6EE),
  onSurfaceVariant: _lightInkSoft,
  outline: Color(0xFFC4C9D4),
  outlineVariant: Color(0xFFDDE1E9),
  surfaceTint: Colors.transparent,
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: _blueBright,
  onPrimary: Color(0xFF09183A),
  primaryContainer: Color(0xFF1E365F),
  onPrimaryContainer: Color(0xFFD9E2F8),
  secondary: _goldBright,
  onSecondary: Color(0xFF3A2D00),
  secondaryContainer: Color(0xFF5C4A1E),
  onSecondaryContainer: Color(0xFFFBE7C4),
  tertiary: Color(0xFFFF6B6E),
  onTertiary: Color(0xFF5C0A0C),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  surface: _darkSurface,
  onSurface: _darkInk,
  surfaceContainerLowest: Color(0xFF0B0E13),
  surfaceContainerLow: Color(0xFF161B22),
  surfaceContainer: Color(0xFF1A1F27),
  surfaceContainerHigh: Color(0xFF222834),
  surfaceContainerHighest: Color(0xFF2B313E),
  onSurfaceVariant: _darkInkSoft,
  outline: Color(0xFF49505C),
  outlineVariant: Color(0xFF333A45),
  surfaceTint: Colors.transparent,
);

TextTheme _textTheme(ColorScheme c) {
  // Inter ≈ SF Pro: crisp, neutral, excellent on-screen legibility. Slightly
  // larger than Material defaults so older / non-technical visitors read easily.
  final ink = c.onSurface;
  final soft = c.onSurfaceVariant;
  return TextTheme(
    displaySmall: GoogleFonts.inter(color: ink, fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.5),
    headlineMedium: GoogleFonts.inter(color: ink, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.4),
    headlineSmall: GoogleFonts.inter(color: ink, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3),
    titleLarge: GoogleFonts.inter(color: ink, fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -0.2),
    titleMedium: GoogleFonts.inter(color: ink, fontSize: 17, fontWeight: FontWeight.w600),
    titleSmall: GoogleFonts.inter(color: ink, fontSize: 15, fontWeight: FontWeight.w600),
    bodyLarge: GoogleFonts.inter(color: ink, fontSize: 17, fontWeight: FontWeight.w400, height: 1.45),
    bodyMedium: GoogleFonts.inter(color: ink, fontSize: 15, fontWeight: FontWeight.w400, height: 1.45),
    bodySmall: GoogleFonts.inter(color: soft, fontSize: 13, fontWeight: FontWeight.w400, height: 1.4),
    labelLarge: GoogleFonts.inter(color: ink, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0),
    labelMedium: GoogleFonts.inter(color: soft, fontSize: 13, fontWeight: FontWeight.w600),
    labelSmall: GoogleFonts.inter(color: soft, fontSize: 12, fontWeight: FontWeight.w600),
  );
}

ThemeData _build(ColorScheme c) {
  final text = _textTheme(c);
  final bg = c.brightness == Brightness.light ? _lightBg : _darkBg;
  return ThemeData(
    useMaterial3: true,
    colorScheme: c,
    scaffoldBackgroundColor: bg,
    textTheme: text,
    splashFactory: InkSparkle.splashFactory,
    // Primary CTAs: big, rounded, confident — the obvious thing on screen.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: 0,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: text.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_rButton)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        textStyle: text.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_rButton)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.primary,
        textStyle: text.labelLarge,
        minimumSize: const Size(0, 44),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_rCard)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: c.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true, // iOS convention
      titleTextStyle: text.titleLarge,
      iconTheme: IconThemeData(color: c.primary),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: c.primary,
      titleTextStyle: text.titleMedium,
      subtitleTextStyle: text.bodySmall,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(color: c.outlineVariant, thickness: 0.5, space: 1),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_rSheet)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_rSheet)),
      ),
      showDragHandle: true,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: c.outlineVariant),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    sliderTheme: const SliderThemeData(
      overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_rButton),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

ThemeData get lightThemeData => _build(lightColorScheme);
ThemeData get darkThemeData => _build(darkColorScheme);

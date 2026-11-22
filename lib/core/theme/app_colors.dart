import 'package:flutter/material.dart';

/// Design tokens shared by the app shell and feature screens.
abstract final class AppColors {
  static const Color primaryGreen = Color(0xFF0B6B57);
  static const Color emergencyRed = Color(0xFFB71C1C);
  static const Color emergencyRedLight = Color(0xFFFDECEA);

  static const Color surfaceTint = Color(0xFFEEF0FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1B1F2A);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color mintBadge = Color(0xFFBFF3DC);
  static const Color amberIcon = Color(0xFFF9E3C8);

  /// Page background used behind the cards.
  static const Color pageBackground = Color(0xFFF7F8FC);

  /// Supporting tints for pills, icon tiles and tag chips.
  static const Color lavenderTint = Color(0xFFE3E6F7);
  static const Color mintTint = Color(0xFFE4F7EE);
  static const Color amberTint = Color(0xFFFFF3E3);
  static const Color blueTint = Color(0xFFE8F0FE);
  static const Color deepGreen = Color(0xFF0A4A3D);
  static const Color grayTint = Color(0xFFF1F2F6);

  /// Icon foregrounds matching the tints above.
  static const Color blueIcon = Color(0xFF2563EB);
  static const Color amberIconDark = Color(0xFFB06A00);
  static const Color lavenderIcon = Color(0xFF4F5BD5);
}

/// Corner radii used across cards, pills and tiles.
abstract final class AppRadius {
  static const double card = 20;
  static const double tile = 16;
  static const double pill = 999;
}

/// Reusable spacing values.
abstract final class AppSpacing {
  static const double pagePadding = 16;
  static const double cardPadding = 20;
}

/// Soft card shadows (blur 16, 6% black).
abstract final class AppShadows {
  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(color: Color(0x0F000000), blurRadius: 16),
  ];

  static const List<BoxShadow> softTop = <BoxShadow>[
    BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, -4)),
  ];
}

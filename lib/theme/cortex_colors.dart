import 'package:flutter/material.dart';

/// JARVIS HUD design tokens (§8).
abstract final class CortexColors {
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF0F1830);
  static const Color elevated = Color(0xFF141F3A);

  static const Color accent = Color(0xFF22D3EE);
  static const Color secondaryGlow = Color(0xFF38BDF8);

  static const Color text = Color(0xFFE6EDF3);
  static const Color muted = Color(0xFF7C8CA6);
  static const Color hairline = Color(0x2622D3EE); // rgba(34,211,238,0.15)

  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF87171);
}

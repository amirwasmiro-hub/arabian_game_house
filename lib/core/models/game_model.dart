import 'package:flutter/material.dart';

class GameModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final int onlinePlayers;
  final int maxPlayers;
  final String badgeTag;
  final String category;
  final bool isPopular;
  final List<Color> cardGradientColors;
  final String cardEmoji;
  final String cardImagePath;

  GameModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.onlinePlayers,
    required this.maxPlayers,
    required this.badgeTag,
    required this.category,
    required this.cardGradientColors,
    required this.cardEmoji,
    required this.cardImagePath,
    this.isPopular = false,
  });

  static List<GameModel> get gamesList => [
    GameModel(
      id: 'baloot',
      titleAr: 'البلوت',
      titleEn: 'Baloot',
      subtitle: 'لعبة الورق الأولى في الخليج العربي',
      icon: Icons.style,
      primaryColor: const Color(0xFFFFD700),
      cardGradientColors: const [
        Color(0xFF1A0A00),
        Color(0xFF3D1C02),
        Color(0xFF6B3A10),
      ],
      cardEmoji: '♠️',
      cardImagePath: 'assets/images/baloot.png',
      onlinePlayers: 4250,
      maxPlayers: 4,
      badgeTag: 'الأكثر شعبية 👑',
      category: 'ألعاب الورق',
      isPopular: true,
    ),
    GameModel(
      id: 'tarneeb',
      titleAr: 'التارنيب',
      titleEn: 'Tarneeb',
      subtitle: 'لعبة التحدي والذكاء الشامية',
      icon: Icons.subtitles,
      primaryColor: const Color(0xFFFF2A6D),
      cardGradientColors: const [
        Color(0xFF1A0010),
        Color(0xFF3D0028),
        Color(0xFF7B0040),
      ],
      cardEmoji: '🃏',
      cardImagePath: 'assets/images/tarneeb.png',
      onlinePlayers: 2840,
      maxPlayers: 4,
      badgeTag: 'تحدي الشام 🎴',
      category: 'ألعاب الورق',
      isPopular: true,
    ),
    GameModel(
      id: 'jackaroo',
      titleAr: 'الجاكارو',
      titleEn: 'Jackaroo',
      subtitle: 'لعبة الألواح الشهيرة بالأحجار والأوراق',
      icon: Icons.casino,
      primaryColor: const Color(0xFF00E676),
      cardGradientColors: const [
        Color(0xFF001A08),
        Color(0xFF003D1A),
        Color(0xFF006B30),
      ],
      cardEmoji: '🎲',
      cardImagePath: 'assets/images/jackaroo.png',
      onlinePlayers: 3100,
      maxPlayers: 4,
      badgeTag: 'حماس فريقي 🎲',
      category: 'ألعاب الألواح',
      isPopular: true,
    ),
    GameModel(
      id: 'dominoes',
      titleAr: 'الدومينو',
      titleEn: 'Dominoes',
      subtitle: 'الدومينو المصرية والخليجية التنافسية',
      icon: Icons.grid_view,
      primaryColor: const Color(0xFFFFB300),
      cardGradientColors: const [
        Color(0xFF1A1000),
        Color(0xFF3D2800),
        Color(0xFF6B4500),
      ],
      cardEmoji: '🀄',
      cardImagePath: 'assets/images/dominoes.png',
      onlinePlayers: 1920,
      maxPlayers: 2,
      badgeTag: 'كلاسيكي 🀄',
      category: 'ألعاب الطاولة',
    ),
    GameModel(
      id: 'carrom',
      titleAr: 'الكاروم',
      titleEn: 'Carrom',
      subtitle: 'لعبة البلياردو الهوائي التراثية',
      icon: Icons.circle,
      primaryColor: const Color(0xFF00F2FE),
      cardGradientColors: const [
        Color(0xFF001A1A),
        Color(0xFF003D3D),
        Color(0xFF006B6B),
      ],
      cardEmoji: '🔵',
      cardImagePath: 'assets/images/carrom.png',
      onlinePlayers: 1450,
      maxPlayers: 2,
      badgeTag: 'دقة وتصويب 🔴',
      category: 'ألعاب الطاولة',
    ),
    GameModel(
      id: 'chess',
      titleAr: 'الشطرنج العربي',
      titleEn: 'Arabian Chess',
      subtitle: 'صراع عقول السلاطين والفرسان',
      icon: Icons.shield,
      primaryColor: const Color(0xFF9D4EDD),
      cardGradientColors: const [
        Color(0xFF0D001A),
        Color(0xFF230040),
        Color(0xFF450080),
      ],
      cardEmoji: '♟️',
      cardImagePath: 'assets/images/chess.png',
      onlinePlayers: 890,
      maxPlayers: 2,
      badgeTag: 'تحدي السلاطين ♟️',
      category: 'استراتيجية',
    ),
  ];
}

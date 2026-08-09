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
    this.isPopular = false,
  });

  static List<GameModel> get gamesList => [
    GameModel(
      id: 'baloot',
      titleAr: 'البلوت',
      titleEn: 'Baloot',
      subtitle: 'لعبة الورق الأولى في الخليج العربي',
      icon: Icons.style,
      primaryColor: const Color(0xFFE5C158),
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
      subtitle: 'لعبة التحدي والذكاء الشامية 41',
      icon: Icons.subtitles,
      primaryColor: const Color(0xFFE53935),
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
      primaryColor: const Color(0xFF1E88E5),
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
      primaryColor: const Color(0xFFAB47BC),
      onlinePlayers: 890,
      maxPlayers: 2,
      badgeTag: 'تحدي السلاطين ♟️',
      category: 'استراتيجية',
    ),
  ];
}

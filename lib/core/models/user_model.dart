class UserModel {
  final String id;
  final String name;
  final String title;
  final String avatarUrl;
  final int coins;
  final int gems;
  final int level;
  final double xpProgress;
  final int wins;
  final int losses;
  final String vipTier;

  UserModel({
    required this.id,
    required this.name,
    required this.title,
    required this.avatarUrl,
    required this.coins,
    required this.gems,
    required this.level,
    required this.xpProgress,
    required this.wins,
    required this.losses,
    required this.vipTier,
  });

  double get winRate {
    int total = wins + losses;
    if (total == 0) return 0.0;
    return (wins / total) * 100;
  }
}

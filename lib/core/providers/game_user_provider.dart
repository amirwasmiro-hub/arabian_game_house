import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/user_model.dart';
import '../audio/sound_manager.dart';

class GameUserProvider extends ChangeNotifier {
  UserModel _user = UserModel(
    id: 'usr_arabian_01',
    name: 'صقر العرب 🦅',
    title: 'أسطورة الدومينو',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    coins: 520000,
    gems: 680,
    level: 18,
    xpProgress: 0.72,
    wins: 142,
    losses: 38,
    vipTier: 'VIP 4',
  );

  int _pingMs = 45;
  bool _isOnline = true;
  Timer? _pingTimer;
  final Random _random = Random();
  final Set<String> _downloadedGames = {'domino_classic', 'tarneeb', 'estimation'};

  UserModel get user => _user;
  int get pingMs => _pingMs;
  bool get isOnline => _isOnline;
  Set<String> get downloadedGames => _downloadedGames;

  GameUserProvider() {
    _startPingSimulation();
    _initConnectivity();
  }

  void _startPingSimulation() {
    _pingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      // Simulate realistic mobile gaming ping (35ms - 75ms)
      _pingMs = 38 + _random.nextInt(32);
      notifyListeners();
    });
  }

  void _initConnectivity() {
    Connectivity().onConnectivityChanged.listen((results) {
      final isConnected = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      _isOnline = isConnected;
      if (!isConnected) {
        _pingMs = 999;
      }
      notifyListeners();
    });
  }

  bool isGameDownloaded(String gameId) {
    return _downloadedGames.contains(gameId);
  }

  void markGameAsDownloaded(String gameId) {
    _downloadedGames.add(gameId);
    notifyListeners();
  }

  void addCoins(int amount) {
    _user = UserModel(
      id: _user.id,
      name: _user.name,
      title: _user.title,
      avatarUrl: _user.avatarUrl,
      coins: _user.coins + amount,
      gems: _user.gems,
      level: _user.level,
      xpProgress: _user.xpProgress,
      wins: _user.wins,
      losses: _user.losses,
      vipTier: _user.vipTier,
    );
    SoundManager().playCoinSound();
    notifyListeners();
  }

  bool deductCoins(int amount) {
    if (_user.coins < amount) return false;
    _user = UserModel(
      id: _user.id,
      name: _user.name,
      title: _user.title,
      avatarUrl: _user.avatarUrl,
      coins: _user.coins - amount,
      gems: _user.gems,
      level: _user.level,
      xpProgress: _user.xpProgress,
      wins: _user.wins,
      losses: _user.losses,
      vipTier: _user.vipTier,
    );
    notifyListeners();
    return true;
  }

  void recordWin(int prizeCoins) {
    _user = UserModel(
      id: _user.id,
      name: _user.name,
      title: _user.title,
      avatarUrl: _user.avatarUrl,
      coins: _user.coins + prizeCoins,
      gems: _user.gems + 5,
      level: _user.level + (_user.xpProgress >= 0.95 ? 1 : 0),
      xpProgress: (_user.xpProgress + 0.1) % 1.0,
      wins: _user.wins + 1,
      losses: _user.losses,
      vipTier: _user.vipTier,
    );
    SoundManager().playVictorySound();
    notifyListeners();
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    super.dispose();
  }
}

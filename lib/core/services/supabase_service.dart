import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;

  Future<void> initialize({required String url, required String anonKey}) async {
    if (_isInitialized) return;
    try {
      if (url.isNotEmpty && anonKey.isNotEmpty && !url.contains('YOUR_')) {
        await Supabase.initialize(url: url, anonKey: anonKey);
        _isInitialized = true;
        debugPrint('Supabase initialized successfully.');
      } else {
        debugPrint('Supabase using mock offline mode.');
      }
    } catch (e) {
      debugPrint('Supabase init fallback: $e');
    }
  }

  SupabaseClient? get client {
    if (_isInitialized) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Current Logged In User / Sultan Profile
  Future<UserModel> fetchUserProfile() async {
    // Returns current active profile or sultan default profile
    return UserModel(
      id: 'sultan_777',
      name: 'السلطان أحمد',
      title: 'أمير البلوت',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      coins: 148500,
      gems: 420,
      level: 28,
      xpProgress: 0.75,
      wins: 142,
      losses: 38,
      vipTier: 'VIP 4 - ذهبي',
    );
  }

  // Active Game Rooms
  Future<List<RoomModel>> fetchActiveRooms() async {
    return [
      RoomModel(
        id: 'room_1',
        roomName: 'مجلس السلاطين 👑',
        gameId: 'baloot',
        gameTitle: 'بلوت خبير',
        hostName: 'الشيخ زايد',
        hostAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        currentPlayers: 3,
        maxPlayers: 4,
        betCoins: 5000,
        isPrivate: false,
        status: 'في الانتظار',
      ),
      RoomModel(
        id: 'room_2',
        roomName: 'تحدي نجد السريع ⚡',
        gameId: 'jackaroo',
        gameTitle: 'جاكارو 4 لاعبين',
        hostName: 'فهد الدوسري',
        hostAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        currentPlayers: 2,
        maxPlayers: 4,
        betCoins: 2500,
        isPrivate: false,
        status: 'في الانتظار',
      ),
      RoomModel(
        id: 'room_3',
        roomName: 'صالة الشام للتارنيب 🎴',
        gameId: 'tarneeb',
        gameTitle: 'تارنيب 41',
        hostName: 'أبو عمر الدمشقي',
        hostAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        currentPlayers: 4,
        maxPlayers: 4,
        betCoins: 10000,
        isPrivate: true,
        status: 'جاري اللعب',
      ),
      RoomModel(
        id: 'room_4',
        roomName: 'بطولة الكاروم الكبرى 🔴',
        gameId: 'carrom',
        gameTitle: 'كاروم احترافي',
        hostName: 'سلطان الخليج',
        hostAvatar: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
        currentPlayers: 1,
        maxPlayers: 2,
        betCoins: 1000,
        isPrivate: false,
        status: 'في الانتظار',
      ),
    ];
  }

  // Create Room
  Future<RoomModel> createRoom({
    required String roomName,
    required String gameId,
    required String gameTitle,
    required int betCoins,
    required int maxPlayers,
    required bool isPrivate,
  }) async {
    return RoomModel(
      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
      roomName: roomName,
      gameId: gameId,
      gameTitle: gameTitle,
      hostName: 'السلطان أحمد',
      hostAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      currentPlayers: 1,
      maxPlayers: maxPlayers,
      betCoins: betCoins,
      isPrivate: isPrivate,
      status: 'في الانتظار',
    );
  }

  // Fetch Leaderboard
  Future<List<UserModel>> fetchLeaderboard() async {
    return [
      UserModel(
        id: 'user_1',
        name: 'سلطان الرياض 👑',
        title: 'أسطورة البلوت',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        coins: 1250000,
        gems: 3500,
        level: 65,
        xpProgress: 0.9,
        wins: 890,
        losses: 120,
        vipTier: 'VIP 10 - ألماس',
      ),
      UserModel(
        id: 'user_2',
        name: 'فارس دبي 🗡️',
        title: 'قاهر التارنيب',
        avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
        coins: 980000,
        gems: 2100,
        level: 58,
        xpProgress: 0.4,
        wins: 720,
        losses: 150,
        vipTier: 'VIP 8 - ذهبي',
      ),
      UserModel(
        id: 'user_3',
        name: 'شهم الكريبتو 💎',
        title: 'بطل الجاكارو',
        avatarUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=150',
        coins: 750000,
        gems: 1800,
        level: 52,
        xpProgress: 0.8,
        wins: 540,
        losses: 110,
        vipTier: 'VIP 7 - ياقوت',
      ),
      UserModel(
        id: 'user_4',
        name: 'السلطان أحمد (أنت)',
        title: 'أمير البلوت',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        coins: 148500,
        gems: 420,
        level: 28,
        xpProgress: 0.75,
        wins: 142,
        losses: 38,
        vipTier: 'VIP 4 - ذهبي',
      ),
    ];
  }
}

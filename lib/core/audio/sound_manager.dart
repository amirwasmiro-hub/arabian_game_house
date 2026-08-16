import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();

  bool isSoundEnabled = true;
  bool isMusicEnabled = true;
  double sfxVolume = 1.0;
  double bgmVolume = 0.5;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isSoundEnabled = prefs.getBool('sound_enabled') ?? true;
      isMusicEnabled = prefs.getBool('music_enabled') ?? true;
      await _sfxPlayer.setVolume(sfxVolume);
      await _bgmPlayer.setVolume(bgmVolume);
    } catch (e) {
      debugPrint('SoundManager init error: $e');
    }
  }

  Future<void> toggleSound(bool enabled) async {
    isSoundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);
  }

  Future<void> toggleMusic(bool enabled) async {
    isMusicEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', enabled);
    if (!enabled) {
      await _bgmPlayer.stop();
    }
  }

  Future<void> _playSfx(String assetPath) async {
    if (!isSoundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (_) {
      // Audio asset optional/missing fallback
    }
  }

  void playCardFlip() {
    if (!isSoundEnabled) return;
    HapticFeedback.lightImpact();
    _playSfx('audio/card_flip.mp3');
  }

  void playCardDeal() {
    if (!isSoundEnabled) return;
    HapticFeedback.selectionClick();
    _playSfx('audio/card_deal.mp3');
  }

  void playDiceRoll() {
    if (!isSoundEnabled) return;
    HapticFeedback.mediumImpact();
    _playSfx('audio/dice_roll.mp3');
  }

  void playButtonClick() {
    if (!isSoundEnabled) return;
    HapticFeedback.lightImpact();
    _playSfx('audio/click.mp3');
  }

  void playWinFanfare() {
    if (!isSoundEnabled) return;
    HapticFeedback.heavyImpact();
    _playSfx('audio/win.mp3');
  }

  void playCoinsCollect() {
    if (!isSoundEnabled) return;
    HapticFeedback.mediumImpact();
    _playSfx('audio/coins.mp3');
  }

  void dispose() {
    _sfxPlayer.dispose();
    _bgmPlayer.dispose();
  }
}


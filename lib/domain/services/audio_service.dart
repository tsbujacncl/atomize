import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Service for playing audio feedback sounds.
///
/// Singleton pattern - use [AudioService()] to get the instance.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;
  bool _soundAvailable = false;

  /// Initialize the audio service.
  ///
  /// Should be called once during app startup.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Check if the sound file exists
      await rootBundle.load('assets/sounds/completion.mp3');
      _soundAvailable = true;
    } catch (e) {
      // Sound file not available, will use haptic feedback instead
      _soundAvailable = false;
    }
  }

  /// Play the completion sound.
  ///
  /// Falls back to haptic feedback if sound is not available.
  Future<void> playCompletionSound() async {
    if (_soundAvailable) {
      try {
        await _player.stop();
        await _player.play(AssetSource('sounds/completion.mp3'));
      } catch (e) {
        // If audio fails, use haptic feedback
        await HapticFeedback.mediumImpact();
      }
    } else {
      // Use haptic feedback as fallback
      await HapticFeedback.mediumImpact();
    }
  }

  /// Dispose of the audio player resources.
  void dispose() {
    _player.dispose();
  }
}

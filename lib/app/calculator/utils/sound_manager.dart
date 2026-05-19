// Simple sound manager - dapat diintegrasikan dengan package seperti 'audioplayers'
// Untuk saat ini, ini adalah placeholder yang bisa diperluas

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();

  factory SoundManager() {
    return _instance;
  }

  SoundManager._internal();

  bool _soundEnabled = true;

  bool get isSoundEnabled => _soundEnabled;

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  void enableSound() {
    _soundEnabled = true;
  }

  void disableSound() {
    _soundEnabled = false;
  }

  // Sound effect methods
  Future<void> playTapSound() async {
    if (!_soundEnabled) return;
    // Placeholder - akan diintegrasikan dengan audioplayers package
    // await AudioCache().play('sounds/tap.wav');
  }

  Future<void> playSuccessSound() async {
    if (!_soundEnabled) return;
    // Placeholder
    // await AudioCache().play('sounds/success.wav');
  }

  Future<void> playErrorSound() async {
    if (!_soundEnabled) return;
    // Placeholder
    // await AudioCache().play('sounds/error.wav');
  }

  Future<void> playCalculateSound() async {
    if (!_soundEnabled) return;
    // Placeholder
    // await AudioCache().play('sounds/calculate.wav');
  }

  Future<void> playSwitchSound() async {
    if (!_soundEnabled) return;
    // Placeholder
    // await AudioCache().play('sounds/switch.wav');
  }
}

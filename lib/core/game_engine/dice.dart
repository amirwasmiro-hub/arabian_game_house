import 'dart:math';
class Dice {
  static final _rng = Random();
  static int roll() => 1 + _rng.nextInt(6);
  static List<int> rollPair() => [roll(), roll()];
  static List<int> rollMultiple(int count) => List.generate(count, (_) => roll());
  static String face(int value) {
    const faces = ['⚀','⚁','⚂','⚃','⚄','⚅'];
    return faces[(value - 1).clamp(0, 5)];
  }
}

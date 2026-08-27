class DominoPiece {
  final int a;
  final int b;

  const DominoPiece(this.a, this.b);

  bool get isDouble => a == b;
  int get pip => a + b;
  int get top => a;
  int get bottom => b;

  bool canFit(int end) => a == end || b == end;

  DominoPiece orientedForLeft(int end) {
    if (b == end) return this;
    if (a == end) return DominoPiece(b, a);
    return this;
  }

  DominoPiece orientedForRight(int end) {
    if (a == end) return this;
    if (b == end) return DominoPiece(b, a);
    return this;
  }

  static List<DominoPiece> fullSet() {
    final list = <DominoPiece>[];
    for (int i = 0; i <= 6; i++) {
      for (int j = i; j <= 6; j++) {
        list.add(DominoPiece(i, j));
      }
    }
    return list;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DominoPiece &&
          runtimeType == other.runtimeType &&
          ((a == other.a && b == other.b) || (a == other.b && b == other.a));

  @override
  int get hashCode => a.hashCode ^ b.hashCode;

  @override
  String toString() => '[$a|$b]';
}

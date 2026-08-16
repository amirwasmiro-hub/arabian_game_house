class DominoPiece {
  final int a, b;
  const DominoPiece(this.a, this.b);
  bool get isDouble => a == b;
  DominoPiece get flipped => DominoPiece(b, a);
  int get pip => a + b;
  bool canFit(int end) => a == end || b == end;
  DominoPiece orientedForRight(int end) => (b == end) ? this : flipped;
  DominoPiece orientedForLeft(int end) => (a == end) ? this : flipped;
  @override String toString() => '[$a|$b]';
  @override bool operator ==(Object other) =>
      other is DominoPiece && ((other.a==a&&other.b==b)||(other.a==b&&other.b==a));
  @override int get hashCode { final mn=a<b?a:b; final mx=a>b?a:b; return mn*7+mx; }
  static List<DominoPiece> fullSet() {
    final p = <DominoPiece>[];
    for (int i=0; i<=6; i++) for (int j=i; j<=6; j++) p.add(DominoPiece(i,j));
    return p;
  }
}

enum ChessColor { white, black }
enum ChessPieceType { pawn, knight, bishop, rook, queen, king }

class ChessPiece {
  final ChessPieceType type;
  final ChessColor color;
  bool hasMoved;
  ChessPiece(this.type, this.color, {this.hasMoved = false});
  ChessPiece copy() => ChessPiece(type, color, hasMoved: hasMoved);
  String get symbol {
    if (color == ChessColor.white) {
      return ['♙','♘','♗','♖','♕','♔'][type.index];
    }
    return ['♟','♞','♝','♜','♛','♚'][type.index];
  }
  int get materialValue => [1,3,3,5,9,100][type.index];
}

class ChessMove {
  final int fromRow, fromCol, toRow, toCol;
  final ChessPieceType? promotion;
  const ChessMove(this.fromRow, this.fromCol, this.toRow, this.toCol, {this.promotion});
  String get algebraic {
    const files = 'abcdefgh';
    return '${files[fromCol]}${8-fromRow}${files[toCol]}${8-toRow}';
  }
}

enum ChessPhase { playing, check, checkmate, stalemate, draw }

class ChessState {
  final List<List<ChessPiece?>> board;
  final ChessColor turn;
  final ChessPhase phase;
  final ChessMove? lastMove;
  final int? selectedRow, selectedCol;
  final List<ChessMove> validMoves;
  final String message;

  const ChessState({
    required this.board, required this.turn, required this.phase,
    this.lastMove, this.selectedRow, this.selectedCol,
    required this.validMoves, required this.message,
  });

  ChessState copyWith({List<List<ChessPiece?>>? board, ChessColor? turn, ChessPhase? phase,
    ChessMove? lastMove, int? selectedRow, int? selectedCol, List<ChessMove>? validMoves, String? message}) =>
    ChessState(board: board??this.board, turn: turn??this.turn, phase: phase??this.phase,
      lastMove: lastMove??this.lastMove, selectedRow: selectedRow??this.selectedRow,
      selectedCol: selectedCol??this.selectedCol, validMoves: validMoves??this.validMoves,
      message: message??this.message);
}

class ChessEngine {
  late ChessState _state;
  ChessEngine() { reset(); }
  ChessState get state => _state;

  static List<List<ChessPiece?>> _initBoard() {
    final b = List.generate(8, (_) => List<ChessPiece?>.filled(8, null));
    void place(int r, int c, ChessPieceType t, ChessColor col) => b[r][c] = ChessPiece(t, col);
    final order = [ChessPieceType.rook,ChessPieceType.knight,ChessPieceType.bishop,ChessPieceType.queen,ChessPieceType.king,ChessPieceType.bishop,ChessPieceType.knight,ChessPieceType.rook];
    for (int c = 0; c < 8; c++) {
      place(0, c, order[c], ChessColor.black);
      place(1, c, ChessPieceType.pawn, ChessColor.black);
      place(6, c, ChessPieceType.pawn, ChessColor.white);
      place(7, c, order[c], ChessColor.white);
    }
    return b;
  }

  void reset() {
    final board = _initBoard();
    final moves = _allLegalMoves(board, ChessColor.white);
    _state = ChessState(board: board, turn: ChessColor.white, phase: ChessPhase.playing,
      validMoves: moves, message: 'أنت (أبيض) — اختر قطعة');
  }

  bool selectSquare(int row, int col) {
    final board = _state.board;
    final piece = board[row][col];
    if (_state.selectedRow != null) {
      // Try to move
      final move = _state.validMoves.where((m) =>
        m.fromRow == _state.selectedRow && m.fromCol == _state.selectedCol &&
        m.toRow == row && m.toCol == col).firstOrNull;
      if (move != null) {
        _applyMove(move);
        return true;
      }
    }
    // Select piece
    if (piece != null && piece.color == _state.turn) {
      final moves = _state.validMoves.where((m) => m.fromRow == row && m.fromCol == col).toList();
      _state = _state.copyWith(selectedRow: row, selectedCol: col, validMoves: moves,
        message: 'اختر وجهة الحركة');
      return true;
    }
    _state = _state.copyWith(selectedRow: null, selectedCol: null,
      validMoves: _allLegalMoves(board, _state.turn));
    return false;
  }

  void _applyMove(ChessMove move) {
    final board = _copyBoard(_state.board);
    final piece = board[move.fromRow][move.fromCol]!;
    piece.hasMoved = true;
    board[move.toRow][move.toCol] = move.promotion != null
        ? ChessPiece(move.promotion!, piece.color, hasMoved: true) : piece;
    board[move.fromRow][move.fromCol] = null;

    final nextTurn = _state.turn == ChessColor.white ? ChessColor.black : ChessColor.white;
    final nextMoves = _allLegalMoves(board, nextTurn);
    final inCheck = _isInCheck(board, nextTurn);

    ChessPhase phase;
    String msg;
    if (nextMoves.isEmpty && inCheck) { phase = ChessPhase.checkmate; msg = _state.turn == ChessColor.white ? '🏆 أنت فزت! كش مات!' : '🤖 البوت فاز! كش مات!'; }
    else if (nextMoves.isEmpty) { phase = ChessPhase.stalemate; msg = 'تعادل — باط!'; }
    else if (inCheck) { phase = ChessPhase.check; msg = nextTurn == ChessColor.white ? 'كش! اختر قطعة للدفاع' : 'البوت في كش — يفكر...'; }
    else { phase = ChessPhase.playing; msg = nextTurn == ChessColor.white ? 'دورك — اختر قطعة' : 'البوت يفكر...'; }

    _state = _state.copyWith(board: board, turn: nextTurn, phase: phase, lastMove: move,
      selectedRow: null, selectedCol: null, validMoves: nextMoves, message: msg);
  }

  ChessMove? botChooseMove({int depth = 2}) {
    final moves = _state.validMoves;
    if (moves.isEmpty) return null;
    ChessMove? best; int bestScore = -99999;
    for (final m in moves) {
      final b = _copyBoard(_state.board);
      final p = b[m.fromRow][m.fromCol]!; p.hasMoved = true;
      b[m.toRow][m.toCol] = p; b[m.fromRow][m.fromCol] = null;
      final score = -_minimax(b, depth - 1, -99999, 99999, ChessColor.white);
      if (score > bestScore) { bestScore = score; best = m; }
    }
    return best;
  }

  int _minimax(List<List<ChessPiece?>> board, int depth, int alpha, int beta, ChessColor color) {
    if (depth == 0) return _evaluate(board);
    final moves = _allLegalMoves(board, color);
    if (moves.isEmpty) return _isInCheck(board, color) ? (color == ChessColor.black ? -10000 : 10000) : 0;
    int best = color == ChessColor.black ? -99999 : 99999;
    for (final m in moves) {
      final b = _copyBoard(board);
      final p = b[m.fromRow][m.fromCol]!;
      b[m.toRow][m.toCol] = p; b[m.fromRow][m.fromCol] = null;
      final score = _minimax(b, depth-1, alpha, beta, color == ChessColor.white ? ChessColor.black : ChessColor.white);
      if (color == ChessColor.black) { best = best > score ? best : score; alpha = alpha > best ? alpha : best; }
      else { best = best < score ? best : score; beta = beta < best ? beta : best; }
      if (beta <= alpha) break;
    }
    return best;
  }

  int _evaluate(List<List<ChessPiece?>> board) {
    int score = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p == null) continue;
        final v = p.materialValue;
        score += p.color == ChessColor.black ? v : -v;
      }
    }
    return score;
  }

  void executeBotMove() {
    if (_state.turn != ChessColor.black) return;
    final move = botChooseMove();
    if (move != null) _applyMove(move);
  }

  List<ChessMove> _allLegalMoves(List<List<ChessPiece?>> board, ChessColor color) {
    final moves = <ChessMove>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p == null || p.color != color) continue;
        moves.addAll(_pieceMoves(board, r, c, p));
      }
    }
    return moves.where((m) {
      final b = _copyBoard(board);
      final p = b[m.fromRow][m.fromCol]!;
      b[m.toRow][m.toCol] = p; b[m.fromRow][m.fromCol] = null;
      return !_isInCheck(b, color);
    }).toList();
  }

  List<ChessMove> _pieceMoves(List<List<ChessPiece?>> b, int r, int c, ChessPiece p) {
    final moves = <ChessMove>[];
    bool inBounds(int r, int c) => r >= 0 && r < 8 && c >= 0 && c < 8;
    bool canCapture(int r, int c) => inBounds(r,c) && (b[r][c] == null || b[r][c]!.color != p.color);
    void addSlide(int dr, int dc) {
      int nr = r+dr, nc = c+dc;
      while (inBounds(nr,nc)) {
        if (b[nr][nc] == null) { moves.add(ChessMove(r,c,nr,nc)); }
        else { if (b[nr][nc]!.color != p.color) moves.add(ChessMove(r,c,nr,nc)); break; }
        nr += dr; nc += dc;
      }
    }
    switch (p.type) {
      case ChessPieceType.pawn:
        final dir = p.color == ChessColor.white ? -1 : 1;
        final start = p.color == ChessColor.white ? 6 : 1;
        final promRow = p.color == ChessColor.white ? 0 : 7;
        if (inBounds(r+dir,c) && b[r+dir][c] == null) {
          if (r+dir == promRow) {
            moves.add(ChessMove(r,c,r+dir,c,promotion: ChessPieceType.queen));
          } else {
            moves.add(ChessMove(r,c,r+dir,c));
            if (r == start && b[r+2*dir][c] == null) moves.add(ChessMove(r,c,r+2*dir,c));
          }
        }
        for (final dc in [-1,1]) {
          if (inBounds(r+dir,c+dc) && b[r+dir][c+dc] != null && b[r+dir][c+dc]!.color != p.color) {
            if (r+dir == promRow) {
              moves.add(ChessMove(r,c,r+dir,c+dc,promotion: ChessPieceType.queen));
            } else {
              moves.add(ChessMove(r,c,r+dir,c+dc));
            }
          }
        }
      case ChessPieceType.knight:
        for (final d in [[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]]) {
          if (canCapture(r+d[0],c+d[1])) moves.add(ChessMove(r,c,r+d[0],c+d[1]));
        }
      case ChessPieceType.bishop:
        for (final d in [[-1,-1],[-1,1],[1,-1],[1,1]]) {
          addSlide(d[0],d[1]);
        }
      case ChessPieceType.rook:
        for (final d in [[-1,0],[1,0],[0,-1],[0,1]]) {
          addSlide(d[0],d[1]);
        }
      case ChessPieceType.queen:
        for (final d in [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) {
          addSlide(d[0],d[1]);
        }
      case ChessPieceType.king:
        for (final d in [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) {
          if (canCapture(r+d[0],c+d[1])) moves.add(ChessMove(r,c,r+d[0],c+d[1]));
        }
    }
    return moves;
  }

  bool _isInCheck(List<List<ChessPiece?>> board, ChessColor color) {
    int kr = -1, kc = -1;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p != null && p.type == ChessPieceType.king && p.color == color) { kr = r; kc = c; }
      }
    }
    if (kr == -1) return false;
    final opp = color == ChessColor.white ? ChessColor.black : ChessColor.white;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p == null || p.color != opp) continue;
        for (final m in _pieceMoves(board, r, c, p)) {
          if (m.toRow == kr && m.toCol == kc) return true;
        }
      }
    }
    return false;
  }

  List<List<ChessPiece?>> _copyBoard(List<List<ChessPiece?>> board) =>
    List.generate(8, (r) => List.generate(8, (c) => board[r][c]?.copy()));
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arabian_game_house/features/splash/screens/orodragon_splash_screen.dart';
import 'package:arabian_game_house/features/splash/screens/gaming_masters_splash_screen.dart';
import 'package:arabian_game_house/games/domino_classic/domino_piece.dart';
import 'package:arabian_game_house/games/domino_classic/domino_3d_tile.dart';
import 'package:arabian_game_house/games/domino_classic/domino_tile_rack.dart';
import 'package:arabian_game_house/games/domino_classic/domino_player_hud.dart';
import 'package:arabian_game_house/games/domino_classic/domino_face_down_tile.dart';
import 'package:arabian_game_house/games/domino_classic/domino_classic_engine.dart';
import 'package:arabian_game_house/games/domino_classic/domino_table_settings_dialog.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    bool finished = false;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(932, 430),
        builder: (context, child) => MaterialApp(
          home: OrodragonSplashScreen(
            onFinish: () => finished = true,
          ),
        ),
      ),
    );
    expect(find.byType(OrodragonSplashScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(finished, isTrue);
  });

  testWidgets('GamingMastersSplashScreen smoke test', (WidgetTester tester) async {
    bool finished = false;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(932, 430),
        builder: (context, child) => MaterialApp(
          home: GamingMastersSplashScreen(
            onFinish: () => finished = true,
          ),
        ),
      ),
    );
    expect(find.byType(GamingMastersSplashScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(finished, isTrue);
  });

  testWidgets('DominoTileRack feedback tile has no glowing', (WidgetTester tester) async {
    final piece = DominoPiece(6, 6);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(932, 430),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: DominoTileRack(
              playerHand: [piece],
              validPieces: {piece},
              isPlayerTurn: true,
              onTileTap: (_) {},
            ),
          ),
        ),
      ),
    );

    final draggableFinder = find.byType(Draggable<DominoPiece>);
    expect(draggableFinder, findsOneWidget);
    final draggableWidget = tester.widget<Draggable<DominoPiece>>(draggableFinder);
    final material = draggableWidget.feedback as Material;
    final feedbackTile = material.child as Domino3DTile;
    expect(feedbackTile.glowColor, isNull);
    expect(feedbackTile.isValid, isFalse);
    expect(feedbackTile.isSelected, isFalse);
  });

  testWidgets('DominoPlayerHud renders opponent tiles with no negative margin error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(932, 430),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: DominoPlayerHud(
              name: 'المنافس',
              avatarUrl: 'https://example.com/avatar.png',
              coins: 50000,
              tilesCount: 7,
              isCurrentTurn: false,
              showFaceDownTiles: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DominoPlayerHud), findsOneWidget);
    expect(find.byType(DominoFaceDownTile), findsNWidgets(7));
  });

  testWidgets('DominoTableSettingsDialog renders authentic Arabian heritage elements', (WidgetTester tester) async {
    final engine = DominoClassicEngine();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(932, 430),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: DominoTableSettingsDialog(
              engine: engine,
              onApply: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DominoTableSettingsDialog), findsOneWidget);
    expect(find.text('إعدادات مجلس الدومينو'), findsOneWidget);
    expect(find.text('نوع اللعب'), findsOneWidget);
    expect(find.text('مستوى الذكاء '), findsOneWidget);
    expect(find.text('النقاط'), findsOneWidget);
    expect(find.text('أجواء ونغمات المقهى'), findsOneWidget);
  });

  testWidgets('DominoTileRack wraps tiles with DragTarget for hand reordering', (WidgetTester tester) async {
    final piece1 = DominoPiece(6, 6);
    final piece2 = DominoPiece(5, 5);
    bool reorderCalled = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(932, 430),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: DominoTileRack(
              playerHand: [piece1, piece2],
              validPieces: {piece1},
              isPlayerTurn: true,
              onTileTap: (_) {},
              onReorderTiles: (from, to) {
                reorderCalled = true;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DragTarget<DominoPiece>), findsNWidgets(2));
    expect(find.byType(Draggable<DominoPiece>), findsNWidgets(2));
    expect(reorderCalled, isFalse);
  });

  testWidgets('DominoTileRack shows edge drop zones when dragging is active', (WidgetTester tester) async {
    final piece1 = DominoPiece(6, 6);
    final piece2 = DominoPiece(5, 5);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(932, 430),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: DominoTileRack(
              playerHand: [piece1, piece2],
              validPieces: {piece1},
              isPlayerTurn: true,
              isDraggingActive: true,
              onTileTap: (_) {},
            ),
          ),
        ),
      ),
    );

    // When dragging is active, edge drop zones are active and invisible
    // 2 outer flanks + 2 inner edge zones + 2 tile drop targets = 6 DragTargets
    expect(find.byType(DragTarget<DominoPiece>), findsNWidgets(6));
  });

  testWidgets('DominoTileRack wraps recentlyMovedPiece in TweenAnimationBuilder for slow landing', (WidgetTester tester) async {
    final piece1 = DominoPiece(6, 6);
    final piece2 = DominoPiece(5, 5);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(932, 430),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: DominoTileRack(
              playerHand: [piece1, piece2],
              validPieces: {piece1},
              isPlayerTurn: true,
              recentlyMovedPiece: piece1,
              recentlyMovedTimestamp: 123456,
              onTileTap: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);
  });

  testWidgets('DominoPlayerHud displays 6s turn timer countdown when active', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(932, 430),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: DominoPlayerHud(
              name: 'اللاعب',
              avatarUrl: 'https://example.com/avatar.png',
              coins: 50000,
              tilesCount: 7,
              isCurrentTurn: true,
              remainingSeconds: 6,
              totalTurnSeconds: 6,
            ),
          ),
        ),
      ),
    );

    expect(find.text('⏱️ 6s'), findsOneWidget);
  });
}


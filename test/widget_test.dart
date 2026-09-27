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
}

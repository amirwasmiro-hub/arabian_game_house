import 'package:flutter_test/flutter_test.dart';
import 'package:arabian_game_house/main.dart';

void main() {
  testWidgets('Arabian Game House smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ArabianGameHouseApp());
    expect(find.text('بيت الألعاب العربية'), findsNothing);
  });
}

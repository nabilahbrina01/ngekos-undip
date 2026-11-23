import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ngekos_undip/main.dart';

void main() {
  testWidgets('NgekosUndip menampilkan bottom navigation', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const NgekosUndipApp());

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Kontrakan'), findsOneWidget);
    expect(find.text('Favorit'), findsOneWidget);
    expect(find.text('Profil'), findsWidgets);
  });
}
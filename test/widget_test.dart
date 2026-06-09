import 'package:flutter_test/flutter_test.dart';
import 'package:rssport/main.dart';

void main() {
  testWidgets('RSSportApp smoke test — renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const RSSportApp());

    // La app debe existir en el árbol de widgets
    expect(find.byType(RSSportApp), findsOneWidget);

    // Avanzamos el tiempo simulado para que el Timer del SplashPage (2.5s)
    // se dispare y no quede pendiente al finalizar el test.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}

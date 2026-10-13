import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardon_pos/main.dart';

void main() {
  testWidgets('Wardon POS smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: WardonPosApp()));
    await tester.pumpAndSettle();

    // Verify navigation or core POS elements exist
    expect(find.text('Kasir'), findsWidgets);
    expect(find.text('Semua'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:naapnama_app/main.dart';

void main() {
  test('overdue logic ignores delivered and future orders', () {
    final today = DateTime(2026, 8, 18);
    expect(Order('A', 'shirt', '', '2026-08-15').overdue(today), true);
    expect(Order('A', 'shirt', '', '2026-08-25').overdue(today), false);
    expect(Order('A', 'shirt', '', '2026-08-15', delivered: true).overdue(today), false);
  });

  testWidgets('renders the board', (tester) async {
    await tester.pumpWidget(const NaapnamaApp());
    expect(find.textContaining('pending'), findsOneWidget);
  });
}

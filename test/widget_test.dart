import 'package:flutter_test/flutter_test.dart';

import 'package:hometasks/main.dart';

void main() {
  testWidgets('HomeTasks app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HomeTasks());

    expect(find.text('HomeTasks'), findsOneWidget);
    expect(find.text('Clean Architecture Boilerplate'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:jobfy/main.dart';

void main() {
  testWidgets('JobfyApp boots and renders the home page', (WidgetTester tester) async {
    await tester.pumpWidget(const JobfyApp());
    await tester.pumpAndSettle();

    expect(find.text('Jobfy'), findsWidgets);
  });
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/shared/widgets/hover_link.dart';

void main() {
  testWidgets('HoverLink shows a click cursor and reports hover to its style callback', (tester) async {
    var tapped = false;
    var lastHovered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HoverLink(
            label: 'Click me',
            onTap: () => tapped = true,
            style: (hovered) {
              lastHovered = hovered;
              return const TextStyle();
            },
          ),
        ),
      ),
    );

    final mouseRegion = tester.widget<MouseRegion>(
      find.descendant(of: find.byType(HoverLink), matching: find.byType(MouseRegion)).first,
    );
    expect(mouseRegion.cursor, SystemMouseCursors.click);
    expect(lastHovered, isFalse);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.text('Click me')));
    await tester.pump();

    expect(lastHovered, isTrue);

    await tester.tap(find.text('Click me'));
    expect(tapped, isTrue);
  });
}

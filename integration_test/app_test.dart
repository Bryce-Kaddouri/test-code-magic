import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_screenshot/native_screenshot.dart';
import 'package:test_code_magic/main.dart';

void main() {
  // ···
  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify counter', (tester) async {
      // Load app widget.
      await tester.pumpWidget(MyApp());

      // wait for the app to settle
      await tester.pumpAndSettle();

      String? path = await NativeScreenshot.takeScreenshot();
      print('path: $path');

      // Finds the floating action button to tap on.
      await tester.tap(find.byKey(Key('button')));
      await tester.pump();

      // Emulate a tap on the floating action button.

      // Trigger a frame.
      await tester.pumpAndSettle(
        Duration(seconds: 10),
      );

      // Verify the counter increments by 1.
    });
  });
}

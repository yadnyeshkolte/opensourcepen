// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opensourcepen/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Print widget tree for debugging
    debugDumpApp();

    // Find the counter text wherever it is (using any widget that might contain it)
    final counterTextFinder = find.byWidgetPredicate((widget) {
      if (widget is Text) {
        // Check if the widget's data contains a digit
        return RegExp(r'\d+').hasMatch(widget.data ?? '');
      }
      return false;
    });

    // Verify that we found the counter text
    expect(counterTextFinder, findsOneWidget, reason: 'Could not find any widget with numeric text');

    // Get the initial value
    final initialText = (tester.widget(counterTextFinder) as Text).data;
    print('Initial counter value: $initialText');

    // Find the increment button (plus icon)
    final incrementButtonFinder = find.byIcon(Icons.add);
    expect(incrementButtonFinder, findsOneWidget, reason: 'Could not find the increment button with Icons.add');

    // Tap the '+' icon and trigger a frame.
    await tester.tap(incrementButtonFinder);
    await tester.pump();

    // Find the counter text again
    final updatedCounterFinder = find.byWidgetPredicate((widget) {
      if (widget is Text) {
        // Check if the widget's data contains a digit that's different from initial
        return widget.data != initialText && RegExp(r'\d+').hasMatch(widget.data ?? '');
      }
      return false;
    });

    // Verify that counter has changed
    expect(updatedCounterFinder, findsOneWidget, reason: 'Could not find the updated counter value');

    // Print the new value for debugging
    final newText = (tester.widget(updatedCounterFinder) as Text).data;
    print('New counter value: $newText');
  });
}
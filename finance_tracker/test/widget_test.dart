import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/main.dart';
import 'package:finance_tracker/providers/transaction_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We need to mock provider or ensure it doesn't crash on init
    // For now, we just pump the MyApp which sets up its own provider
    await tester.pumpWidget(const MyApp());

    // Verify that the title is present
    expect(find.text('Finance Tracker'), findsOneWidget);
    
    // Verify we have a Floating Action Button (Add) or similar
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}

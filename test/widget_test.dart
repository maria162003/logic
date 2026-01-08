// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_app/main.dart';

void main() {
  testWidgets('Logic app renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const LogicApp());

    // La app debe construir un MaterialApp y al menos un Scaffold (splash)
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // Avanza el tiempo para permitir que timers del splash se completen en tests
    await tester.pump(const Duration(milliseconds: 3600));
    await tester.pumpAndSettle();
  });
}

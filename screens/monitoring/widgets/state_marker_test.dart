import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/state_marker.dart';

void main() {
  testWidgets('Red State marker Widget', (WidgetTester tester) async {
    await tester.pumpWidget(StateMarker(false));

    final background = tester.firstWidget(find.byType(Container)) as Container;
    expect((background.decoration as BoxDecoration).color, Colors.redAccent);
  });

  testWidgets('Green State marker Widget', (WidgetTester tester) async {
    await tester.pumpWidget(StateMarker(true));

    final background = tester.firstWidget(find.byType(Container)) as Container;
    expect((background.decoration as BoxDecoration).color, Color(0xFF378752));
  });
}

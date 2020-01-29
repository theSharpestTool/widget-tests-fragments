import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/custom_type_field.dart';
import 'package:fooddocs_flutter_app/services/monitoring.service.dart';

import '../../../../../test_helpers/wrappers/locale_wrapper.dart';

void main() {
  final problemsList = MonitoringService.problemsList;
  testWidgets(
    'CustomValueFields displayed properly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: CustomValueFields(problemsList),
        ),
      );
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsNWidgets(problemsList.length));
      for (final customValue in problemsList)
        expect(find.text(customValue.name), findsOneWidget);
    },
  );

  testWidgets(
    'onAdd - should be triggered when used submit changes and return entered string',
    (WidgetTester tester) async {
      String addedValue;
      await tester.pumpWidget(
        LocaleWrapper(
          child: CustomValueFields(
            problemsList,
            onAdd: (value) => addedValue = value,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('custom_text_field')), 'my custom');
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(addedValue, 'my custom');
    },
  );

  testWidgets(
    'onDelete - should be triggered when user delete item and return item to delete',
    (WidgetTester tester) async {
      String deletedValueName;
      await tester.pumpWidget(
        LocaleWrapper(
          child: CustomValueFields(
            problemsList,
            onDelete: (value) => deletedValueName = value.name,
          ),
        ),
      );

      await tester.pumpAndSettle();
      for (final customValue in problemsList) {
        await tester.tap(find.byKey(Key('${customValue.name}_delete_icon')));
        await tester.pumpAndSettle();
        expect(deletedValueName, customValue.name);
      }
    },
  );

  testWidgets(
    'onChanged - should returning value which users typing',
    (WidgetTester tester) async {
      String changedValue;
      await tester.pumpWidget(
        LocaleWrapper(
          child: CustomValueFields(
            problemsList,
            onChanged: (value) => changedValue = value,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('custom_text_field')), 'changed');
      await tester.pumpAndSettle();

      expect(changedValue, 'changed');
    },
  );
}

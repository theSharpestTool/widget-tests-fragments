import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/device.dart';
import 'package:fooddocs_flutter_app/screens/auth/auth.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/device_types/tasks.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/checkbox_selector_dialog.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/measurement_button.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/notes_field.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/radios_list_field.dart';
import 'package:fooddocs_flutter_app/services/monitoring.service.dart';
import 'package:fooddocs_flutter_app/widgets/file_picker.dart';

import '../../../../../test_helpers/wrappers/locale_wrapper.dart';

void main() {
  final ratesList = MonitoringService.taskStateList;
  final selectedRate = ratesList[2];

  testWidgets(
    'Tasks Form displayed properly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TasksForm(
            Device(
              name: 'device',
              deviceTypeId: 13,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SelectorDialog), findsOneWidget);
      expect(find.byType(NotesField), findsOneWidget);
      expect(find.byType(FileOrImagePicker), findsOneWidget);
      expect(find.byType(MeasurementButton), findsOneWidget);

      for (final rate in MonitoringService.taskStateList)
        expect(find.text(rate), findsNothing);
    },
  );

  testWidgets(
    'User should be able to select rate',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TasksForm(
            Device(
              name: 'device',
              deviceTypeId: 13,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.byType(SelectorDialog));
      await tester.pumpAndSettle();
      await tester.tap(find.text(selectedRate));
      await tester.pumpAndSettle();

      expect(find.text(selectedRate), findsOneWidget);
    },
  );

  testWidgets(
    'User should be able to type notes',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TasksForm(
            Device(
              name: 'device',
              deviceTypeId: 13,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.enterText(find.byKey(Key('notes_text_field')), 'test');
      await tester.pumpAndSettle();

      expect(find.text('test'), findsOneWidget);
    },
  );

  testWidgets(
    'On the "Save" button click all fields should be frozen (should be disabled)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TasksForm(
            Device(
              name: 'device',
              deviceTypeId: 13,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(SelectorDialog));
      await tester.pumpAndSettle();
      await tester.tap(find.text(selectedRate));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('rate'));
      await tester.pumpAndSettle();
      expect(find.byType(RadiosListField), findsNothing);

      await tester.tap(find.text('Add picture'));
      await tester.pumpAndSettle();
      expect(find.text('Camera'), findsNothing);
      expect(find.text('Gallery'), findsNothing);
      expect(find.text('Cancel'), findsNothing);
    },
  );

  testWidgets(
    'On the "Save" button click the created message should appear',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TasksForm(
            Device(
              name: 'device',
              deviceTypeId: 13,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(SelectorDialog));
      await tester.pumpAndSettle();
      await tester.tap(find.text(selectedRate));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();

      expect(find.text('Created'), findsOneWidget);
    },
  );

  testWidgets(
    'On the "Save" button click the "Create new" button should appear',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TasksForm(
            Device(
              name: 'device',
              deviceTypeId: 13,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(SelectorDialog));
      await tester.pumpAndSettle();
      await tester.tap(find.text(selectedRate));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();

      expect(find.text('Create new'), findsOneWidget);
    },
  );

  testWidgets(
    'On "Create new" button click fields all fields should be reset to default state',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TasksForm(
            Device(
              name: 'device',
              deviceTypeId: 13,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(SelectorDialog));
      await tester.pumpAndSettle();
      await tester.tap(find.text(selectedRate));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create new'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('rate'));
      await tester.pumpAndSettle();
      expect(find.byType(RadiosListField), findsOneWidget);
      await tester.tap(find.text('rate'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add picture'));
      await tester.pumpAndSettle();
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    },
  );

  testWidgets(
    'On "Save" button click "Close" button should appear and it should redirect previous page',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          previousPageRoute: AuthPage.routeName,
          child: TasksForm(
            Device(
              name: 'device',
              deviceTypeId: 13,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(SelectorDialog));
      await tester.pumpAndSettle();
      await tester.tap(find.text(selectedRate));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();

      expect(find.text('close'), findsOneWidget);

      await tester.tap(find.text('close'));
      await tester.pumpAndSettle();

      expect(find.byType(AuthPage), findsOneWidget);
    },
  );
}

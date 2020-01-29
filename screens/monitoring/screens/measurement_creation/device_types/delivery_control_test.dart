import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/common/defect.dart';
import 'package:fooddocs_flutter_app/models/common/supplier_preventions.dart';
import 'package:fooddocs_flutter_app/models/device.dart';
import 'package:fooddocs_flutter_app/screens/auth/auth.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/monitoring.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/device_types/delivery_control.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/checkbox_selector_dialog.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/measurement_button.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/supplier_defects_list_field.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/supplier_preventions_list_field.dart';
import 'package:fooddocs_flutter_app/services/monitoring.service.dart';
import 'package:fooddocs_flutter_app/widgets/file_picker.dart';
import 'package:fooddocs_flutter_app/widgets/temperature_field.dart';
import '../../../../../test_helpers/wrappers/locale_wrapper.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Complaints Form displayed properly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: DeliveryControlForm(
            Device(
              name: 'device',
              deviceTypeId: 4,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.byType(FileOrImagePicker), findsOneWidget);
      expect(find.byType(TemperatureField), findsOneWidget);
      expect(find.byType(SelectorDialog), findsNWidgets(2));
      expect(find.byType(MeasurementButton), findsOneWidget);
    },
  );

  testWidgets(
    'The form requires at least one field filled',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: DeliveryControlForm(
            Device(
              name: 'device',
              deviceTypeId: 4,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();

      expect(find.text('Created'), findsNothing);
    },
  );

  testWidgets(
    'User should be able to type supplier (String)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: DeliveryControlForm(
            Device(
              name: 'device',
              deviceTypeId: 4,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.enterText(find.byKey(Key('supplier_text_field')), 'string');
      await tester.pumpAndSettle();

      expect(find.text('string'), findsOneWidget);
    },
  );

  testWidgets(
    'User should be able to type product (String)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: DeliveryControlForm(
            Device(
              name: 'device',
              deviceTypeId: 4,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.enterText(
          find.byKey(
            Key('product_text_field'),
          ),
          'string');
      await tester.pumpAndSettle();

      expect(find.text('string'), findsOneWidget);
    },
  );

  testWidgets(
    'User should be able to type temperature (Number with "," | "." | "-" symbols)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: DeliveryControlForm(
            Device(
              name: 'device',
              deviceTypeId: 4,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.enterText(find.byKey(Key('temperature_text_field')), '-1,3');
      await tester.pumpAndSettle();

      expect(find.text('-1.3'), findsOneWidget);
    },
  );

  testWidgets(
    'Temperature: other characters should cause a validation error)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: DeliveryControlForm(
            Device(
              name: 'device',
              deviceTypeId: 4,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.enterText(
          find.byKey(Key('temperature_text_field')), 'temperature');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();

      expect(find.text('Should be a number'), findsOneWidget);
    },
  );

  testWidgets(
    'User should be able to select defects or type custom value',
    (WidgetTester tester) async {
      final List<Defect> defectsList = MonitoringService.supplierDefectsList;

      await tester.pumpWidget(
        LocaleWrapper(
          child: DeliveryControlForm(
            Device(
              name: 'device',
              deviceTypeId: 4,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.text('Defects'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(defectsList[0].name));
      await tester.pumpAndSettle();
      await tester.tap(find.text(defectsList[1].name));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('custom_text_field')), 'custom');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(RaisedButton));
      await tester.pumpAndSettle();

      expect(find.text(defectsList[0].name), findsOneWidget);
      expect(find.text(defectsList[1].name), findsOneWidget);
      expect(find.text('custom'), findsOneWidget);
    },
  );

  testWidgets(
    'User should be able to select prevention actions or type custom value',
    (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(900, 1800));
      final List<SupplierPreventions> preventionsList =
          MonitoringService.supplierPreventionsList;

      await tester.pumpWidget(
        LocaleWrapper(
          child: DeliveryControlForm(
            Device(
              name: 'device',
              deviceTypeId: 4,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.text('What I did?'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(preventionsList[0].name));
      await tester.pumpAndSettle();
      await tester.tap(find.text(preventionsList[1].name));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('custom_text_field')), 'custom');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(RaisedButton));
      await tester.pumpAndSettle();

      expect(find.text(preventionsList[0].name), findsOneWidget);
      expect(find.text(preventionsList[1].name), findsOneWidget);
      expect(find.text('custom'), findsOneWidget);

      addTearDown(() => binding.setSurfaceSize(null));
    },
  );

  testWidgets(
    'On the "Save" button click all fields should be frozen (should be disabled)',
    (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(900, 1800));

      await tester.pumpWidget(
        LocaleWrapper(
          child: DeliveryControlForm(
            Device(
              name: 'device',
              deviceTypeId: 4,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.enterText(
          find.byKey(Key('supplier_text_field')), 'supplier');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Defects'));
      await tester.pumpAndSettle();
      expect(find.byType(SupplierDefectsListField), findsNothing);

      await tester.tap(find.text('What I did?'));
      await tester.pumpAndSettle();
      expect(find.byType(SupplierPreventionsListField), findsNothing);

      await tester.tap(find.text('Add picture'));
      await tester.pumpAndSettle();
      expect(find.text('Camera'), findsNothing);
      expect(find.text('Gallery'), findsNothing);
      expect(find.text('Cancel'), findsNothing);

      addTearDown(() => binding.setSurfaceSize(null));
    },
  );

  testWidgets(
    'On the "Save" button click the created message should appear',
    (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(900, 1800));

      await tester.pumpWidget(
        LocaleWrapper(
          child: DeliveryControlForm(
            Device(
              name: 'device',
              deviceTypeId: 4,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.enterText(
          find.byKey(Key('supplier_text_field')), 'supplier');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();

      expect(find.text('Created'), findsOneWidget);

      addTearDown(() => binding.setSurfaceSize(null));
    },
  );

  testWidgets(
    'On the "Save" button click the "Create new" button should appear',
    (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(900, 1800));

      await tester.pumpWidget(
        LocaleWrapper(
          child: DeliveryControlForm(
            Device(
              name: 'device',
              deviceTypeId: 4,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.enterText(
          find.byKey(Key('supplier_text_field')), 'supplier');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();

      expect(find.text('Create new'), findsOneWidget);

      addTearDown(() => binding.setSurfaceSize(null));
    },
  );

  testWidgets(
    'On "Create new" button click fields all fields should be reset to default state',
    (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(900, 1800));

      await tester.pumpWidget(
        LocaleWrapper(
          child: DeliveryControlForm(
            Device(
              name: 'device',
              deviceTypeId: 4,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.enterText(
          find.byKey(Key('supplier_text_field')), 'supplier');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create new'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Defects'));
      await tester.pumpAndSettle();
      expect(find.byType(SupplierDefectsListField), findsOneWidget);
      await tester.tap(find.byType(RaisedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('What I did?'));
      await tester.pumpAndSettle();
      expect(find.byType(SupplierPreventionsListField), findsOneWidget);
      await tester.tap(find.byType(RaisedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add picture'));
      await tester.pumpAndSettle();
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      addTearDown(() => binding.setSurfaceSize(null));
    },
  );

  testWidgets(
    'On "Save" button click "Close" button should appear and it should redirect to previous page',
    (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(900, 1800));
      await tester.pumpWidget(
        LocaleWrapper(
          previousPageRoute: AuthPage.routeName,
          child: DeliveryControlForm(
            Device(
              name: 'device',
              deviceTypeId: 4,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(Key('supplier_text_field')), 'supplier');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();

      expect(find.text('close'), findsOneWidget);

      await tester.tap(find.text('close'));
      await tester.pumpAndSettle();

      expect(find.byType(AuthPage), findsOneWidget);

      addTearDown(() => binding.setSurfaceSize(null));
    },
  );
}

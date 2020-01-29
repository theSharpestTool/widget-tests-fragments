import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/device.dart';
import 'package:fooddocs_flutter_app/models/product.dart';
import 'package:fooddocs_flutter_app/screens/auth/auth.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/monitoring.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/device_types/complaints.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/checkbox_selector_dialog.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/correcting_actions_list_field.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/measurement_button.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/preventions_list_field.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/problems_list_field.dart';
import 'package:fooddocs_flutter_app/services/correcting-actions.service.dart';
import 'package:fooddocs_flutter_app/services/monitoring.service.dart';
import 'package:fooddocs_flutter_app/widgets/file_picker.dart';
import 'package:fooddocs_flutter_app/widgets/product_select_field.dart';

import '../../../../../test_helpers/mock_services/correcting_actions_service_mock.dart';
import '../../../../../test_helpers/mock_services/production_service_mock.dart';
import '../../../../../test_helpers/wrappers/locale_wrapper.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  List<Product> products;

  setUpAll(() {
    CorrectingActionsServiceMock.mock();
    ProductionServiceMock.mock();
    products = ProductionServiceMock.products;
  });

  testWidgets(
    'Complaints Form displayed properly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: ComplaintsForm(
            Device(
              name: 'device',
              deviceTypeId: 3,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ProductSelectField), findsOneWidget);
      expect(find.byType(SelectorDialog), findsNWidgets(3));
      expect(find.byType(FileOrImagePicker), findsOneWidget);
      expect(find.byType(MeasurementButton), findsOneWidget);
    },
  );

  testWidgets(
    'The form requires at least one field filled',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: ComplaintsForm(
            Device(
              name: 'device',
              deviceTypeId: 3,
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

  group('User should be able to select: ', () {
    testWidgets(
      'Product',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: ComplaintsForm(
              Device(
                name: 'device',
                deviceTypeId: 3,
              ),
            ),
          ),
        );
        final productName = products.last.name.en;

        await tester.pump();
        await tester.enterText(find.byType(ProductSelectField), productName[0]);
        await tester.pumpAndSettle();
        await tester.tap(find.text(productName));
        await tester.pumpAndSettle();

        expect(find.text(productName), findsOneWidget);
      },
    );

    testWidgets(
      'Multiple problem types and type custom value',
      (WidgetTester tester) async {
        await binding.setSurfaceSize(Size(900, 1800));
        final problemsList = MonitoringService.problemsList;

        await tester.pumpWidget(
          LocaleWrapper(
            child: ComplaintsForm(
              Device(
                name: 'device',
                deviceTypeId: 3,
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.tap(find.text('Problem type'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(problemsList[0].name));
        await tester.pumpAndSettle();
        await tester.tap(find.text(problemsList[1].name));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(Key('custom_text_field')), 'custom');
        await tester.pumpAndSettle();
        await tester.tap(find.byType(RaisedButton));
        await tester.pumpAndSettle();

        expect(find.text(problemsList[0].name), findsOneWidget);
        expect(find.text(problemsList[1].name), findsOneWidget);
        expect(find.text('custom'), findsOneWidget);

        addTearDown(() => binding.setSurfaceSize(null));
      },
    );

    testWidgets(
      'Multiple correction actions or type custom value',
      (WidgetTester tester) async {
        await binding.setSurfaceSize(Size(900, 1800));
        final device = Device(name: 'device', deviceTypeId: 3);
        final correctiongActions = await CorrectingActionsService.instance.correctingActionsForDeviceType(device.deviceTypeId);

        await tester.pumpWidget(
          LocaleWrapper(
            child: ComplaintsForm(device),
          ),
        );

        await tester.pump();
        await tester.tap(find.text('What happened?'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(correctiongActions[0].slug));
        await tester.pumpAndSettle();
        await tester.tap(find.text(correctiongActions[1].name));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(Key('custom_text_field')), 'custom');
        await tester.pumpAndSettle();
        await tester.tap(find.byType(RaisedButton));
        await tester.pumpAndSettle();

        expect(find.text(correctiongActions[0].name), findsOneWidget);
        expect(find.text(correctiongActions[1].name), findsOneWidget);
        expect(find.text('custom'), findsOneWidget);

        addTearDown(() => binding.setSurfaceSize(null));
      },
    );

    testWidgets(
      'Multiple correction actions or type custom value',
      (WidgetTester tester) async {
        await binding.setSurfaceSize(Size(900, 1800));
        final device = Device(name: 'device', deviceTypeId: 3);
        final correctiongActions = await CorrectingActionsService.instance.correctingActionsForDeviceType(device.deviceTypeId);

        await tester.pumpWidget(
          LocaleWrapper(
            child: ComplaintsForm(device),
          ),
        );

        await tester.pump();
        await tester.tap(find.text('What happened?'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(correctiongActions[0].slug));
        await tester.pumpAndSettle();
        await tester.tap(find.text(correctiongActions[1].name));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(Key('custom_text_field')), 'custom');
        await tester.pumpAndSettle();
        await tester.tap(find.byType(RaisedButton));
        await tester.pumpAndSettle();

        expect(find.text(correctiongActions[0].name), findsOneWidget);
        expect(find.text(correctiongActions[1].name), findsOneWidget);
        expect(find.text('custom'), findsOneWidget);

        addTearDown(() => binding.setSurfaceSize(null));
      },
    );

    testWidgets(
      'Prevention actions or type custom value',
      (WidgetTester tester) async {
        await binding.setSurfaceSize(Size(900, 1800));
        final device = Device(name: 'device', deviceTypeId: 3);
        final preventionsList = MonitoringService.preventionsList;

        await tester.pumpWidget(
          LocaleWrapper(
            child: ComplaintsForm(device),
          ),
        );

        await tester.pump();
        await tester.tap(find.text('What should be changed?'));
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
  });

  testWidgets(
    'On Save button click all fields should be frozen (should be disabled)',
    (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(900, 1800));
      await tester.pumpWidget(
        LocaleWrapper(
          child: ComplaintsForm(
            Device(
              name: 'device',
              deviceTypeId: 3,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.enterText(find.byType(ProductSelectField), 'product');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Problem type'));
      await tester.pumpAndSettle();
      expect(find.byType(ProblemsListField), findsNothing);

      await tester.tap(find.text('What happened?'));
      await tester.pumpAndSettle();
      expect(find.byType(CorrectingActionsListField), findsNothing);

      await tester.tap(find.text('Add picture'));
      await tester.pumpAndSettle();
      expect(find.text('Camera'), findsNothing);
      expect(find.text('Gallery'), findsNothing);
      expect(find.text('Cancel'), findsNothing);

      await tester.tap(find.text('What should be changed?'));
      await tester.pumpAndSettle();
      expect(find.byType(PreventionsListField), findsNothing);

      addTearDown(() => binding.setSurfaceSize(null));
    },
  );

  testWidgets(
    'On Save button click the created message should appear',
    (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(900, 1800));
      await tester.pumpWidget(
        LocaleWrapper(
          child: ComplaintsForm(
            Device(
              name: 'device',
              deviceTypeId: 3,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.enterText(find.byType(ProductSelectField), 'product');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();

      expect(find.text('Created'), findsOneWidget);

      addTearDown(() => binding.setSurfaceSize(null));
    },
  );

  testWidgets(
    'On Save button click the "Create new" button should appear',
    (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(900, 1800));
      await tester.pumpWidget(
        LocaleWrapper(
          child: ComplaintsForm(
            Device(
              name: 'device',
              deviceTypeId: 3,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.enterText(find.byType(ProductSelectField), 'product');
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
          child: ComplaintsForm(
            Device(
              name: 'device',
              deviceTypeId: 3,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.enterText(find.byType(ProductSelectField), 'product');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create new'));
      await tester.pumpAndSettle();

      expect(find.text('product'), findsNothing);

      await tester.tap(find.text('Problem type'));
      await tester.pumpAndSettle();
      expect(find.byType(ProblemsListField), findsOneWidget);
      await tester.tap(find.byType(RaisedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('What happened?'));
      await tester.pumpAndSettle();
      expect(find.byType(CorrectingActionsListField), findsOneWidget);
      await tester.tap(find.byType(RaisedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add picture'));
      await tester.pumpAndSettle();
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('What should be changed?'));
      await tester.pumpAndSettle();
      expect(find.byType(PreventionsListField), findsOneWidget);

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
          child: ComplaintsForm(
            Device(
              name: 'device',
              deviceTypeId: 3,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byType(ProductSelectField), 'product');
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

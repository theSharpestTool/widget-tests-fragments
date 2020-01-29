import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/device.dart';
import 'package:fooddocs_flutter_app/models/product.dart';
import 'package:fooddocs_flutter_app/screens/auth/auth.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/monitoring.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/device_types/traceability.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/measurement_button.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/new_exp_date_or_batch_field.dart';
import 'package:fooddocs_flutter_app/widgets/amount_field.dart';
import 'package:fooddocs_flutter_app/widgets/ingredient_select_field.dart';
import 'package:fooddocs_flutter_app/widgets/product_select_field.dart';
import 'package:fooddocs_flutter_app/widgets/text_or_date_field.dart';
import 'package:fooddocs_flutter_app/widgets/unit_field.dart';

import '../../../../../test_helpers/mock_services/production_service_mock.dart';
import '../../../../../test_helpers/mock_services/unit_service_mock.dart';
import '../../../../../test_helpers/wrappers/locale_wrapper.dart';

void main() {
  List<Product> products;

  setUpAll(() {
    ProductionServiceMock.mock();
    products = ProductionServiceMock.products;
    UnitServiceMock.mock();
  });

  testWidgets(
    'Traceability Form displayed properly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TraceabilityForm(
            Device(
              name: 'device',
              deviceTypeId: 3,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ProductSelectField), findsOneWidget);
      expect(find.byType(IngredientSelectField), findsOneWidget);
      expect(find.byType(AmountField), findsOneWidget);
      expect(find.byType(UnitField), findsOneWidget);
      expect(find.byType(TextOrDateField), findsNWidgets(2));
      expect(find.byType(NewExpDateOrBatchField), findsOneWidget);
      expect(find.byType(MeasurementButton), findsOneWidget);
    },
  );

  testWidgets(
    'The form requires at least one field filled',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TraceabilityForm(
            Device(
              name: 'device',
              deviceTypeId: 5,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();

      expect(find.text('Created'), findsNothing);
    },
  );

  group('User should be able to select:', () {
    testWidgets('Product', (tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TraceabilityForm(
            Device(
              name: 'device',
              deviceTypeId: 5,
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
    });

    testWidgets('Ingredient related to the product', (tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TraceabilityForm(
            Device(
              name: 'device',
              deviceTypeId: 5,
            ),
          ),
        ),
      );
      final productName = products.last.name.en;
      final ingredientName = products.last.ingredients.last.name.en;

      await tester.pump();
      await tester.enterText(find.byType(ProductSelectField), productName[0]);
      await tester.pumpAndSettle();
      await tester.tap(find.text(productName));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(IngredientSelectField), ingredientName[0]);
      await tester.pumpAndSettle();
      await tester.tap(find.text(ingredientName));
      await tester.pumpAndSettle();

      expect(find.text(productName), findsOneWidget);
    });

    testWidgets('Custom ingredient', (tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TraceabilityForm(
            Device(
              name: 'device',
              deviceTypeId: 5,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.enterText(find.byType(IngredientSelectField), 'custom');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('custom'), findsOneWidget);
    });

    testWidgets('Measurement unit', (tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TraceabilityForm(
            Device(
              name: 'device',
              deviceTypeId: 5,
            ),
          ),
        ),
      );

      final unitName = UnitServiceMock.massUnits.first.name;

      await tester.pumpAndSettle();
      await tester.tap(find.byType(UnitField));
      await tester.pumpAndSettle();
      await tester.tap(find.text(unitName));
      await tester.pumpAndSettle();

      expect(find.text(unitName), findsOneWidget);
    });

    testWidgets('Ingredient best before or batch"', (tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TraceabilityForm(
            Device(
              name: 'device',
              deviceTypeId: 5,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('best_before_field')), 'date');
      await tester.pumpAndSettle();

      expect(find.text('date'), findsOneWidget);
    });

    testWidgets('New expiration date', (tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TraceabilityForm(
            Device(
              name: 'device',
              deviceTypeId: 5,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byType(ProductSelectField), 'custom');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(NewExpDateOrBatchField), 'date');
      await tester.pumpAndSettle();

      expect(find.text('date'), findsOneWidget);
    });
  });

  testWidgets(
      'On the "Save" button click all fields should be frozen (should be disabled)',
      (tester) async {
    await tester.pumpWidget(
      LocaleWrapper(
        child: TraceabilityForm(
          Device(
            name: 'device',
            deviceTypeId: 5,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(ProductSelectField), 'custom');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MeasurementButton));
    await tester.pumpAndSettle();

    final unitName = UnitServiceMock.massUnits.first.name;
    await tester.tap(find.byType(UnitField));
    await tester.pumpAndSettle();
    expect(find.text(unitName), findsNothing);
  });

  testWidgets('On the "Save" button click The created message should appear',
      (tester) async {
    await tester.pumpWidget(
      LocaleWrapper(
        child: TraceabilityForm(
          Device(
            name: 'device',
            deviceTypeId: 5,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(ProductSelectField), 'custom');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MeasurementButton));
    await tester.pumpAndSettle();

    expect(find.text('Created'), findsOneWidget);
  });

  testWidgets(
      'On the "Save" button click the "Create new" button should appear',
      (tester) async {
    await tester.pumpWidget(
      LocaleWrapper(
        child: TraceabilityForm(
          Device(
            name: 'device',
            deviceTypeId: 5,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(ProductSelectField), 'custom');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MeasurementButton));
    await tester.pumpAndSettle();

    expect(find.text('Create new'), findsOneWidget);
  });

  testWidgets(
      'On "Create new" button click fields all fields should be reset to default state',
      (tester) async {
    await tester.pumpWidget(
      LocaleWrapper(
        child: TraceabilityForm(
          Device(
            name: 'device',
            deviceTypeId: 5,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(ProductSelectField), 'custom');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MeasurementButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create new'));
    await tester.pumpAndSettle();

    final unitName = UnitServiceMock.massUnits.first.name;
    await tester.tap(find.byType(UnitField));
    await tester.pumpAndSettle();
    expect(find.text(unitName), findsOneWidget);
  });

  testWidgets(
    'On "Save" button click "Close" button should appear and it should redirect to previous page',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          previousPageRoute: AuthPage.routeName,
          child: TraceabilityForm(
            Device(
              name: 'device',
              deviceTypeId: 5,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byType(ProductSelectField), 'custom');
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

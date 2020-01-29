import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/common/key_constants.dart';
import 'package:fooddocs_flutter_app/models/device.dart';
import 'package:fooddocs_flutter_app/models/product.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/device_types/shelf_traceability.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/measurement_button.dart';
import 'package:fooddocs_flutter_app/services/storages.service.dart';
import 'package:fooddocs_flutter_app/widgets/custom_snack_bar.dart';
import 'package:fooddocs_flutter_app/widgets/product_select_field.dart';
import 'package:fooddocs_flutter_app/widgets/text_or_date_field.dart';
import 'package:fooddocs_flutter_app/widgets/unit_field.dart';

import '../../../../../test_helpers/mock_services/production_service_mock.dart';
import '../../../../../test_helpers/mock_services/unit_service_mock.dart';
import '../../../../../test_helpers/wrappers/locale_wrapper.dart';
import '../../../widgets/correcting_actions_dialog_test.dart';

void main() {
  List<Product> products;

  setUpAll(() {
    ProductionServiceMock.mock();
    products = ProductionServiceMock.products;
    UnitServiceMock.mock();
  });

  group("Shelf-life Traceability Tests", () {
    //Generate mock data.
    StoragesService.instance.assignTestStorages(getTestStorageList());
    var device = getDevices().firstWhere(
        (device) => device.deviceType == DeviceTypes.SHELF_TRACEABILITY);

    testWidgets("Shelf Form Exists", (WidgetTester tester) async {
      await openShelfTraceabilityForm(tester, device);
      expect(find.byType(ShelfTraceabilityForm), findsOneWidget);
    });

    testWidgets("Every field shoould be filled", (WidgetTester tester) async {
      await openShelfTraceabilityForm(tester, device);
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();
      expect(find.text('Created'), findsNothing);

      await tester.enterText(find.byType(ProductSelectField), 'test product');
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();
      expect(find.text('Created'), findsNothing);

      await tester.enterText(find.byKey(Key(amountFieldAtShelf)), '4');
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();
      expect(find.text('Created'), findsNothing);

      final randomUnitName = UnitServiceMock
          .massUnits[next(0, UnitServiceMock.massUnits.length)].name;
      await tester.pumpAndSettle();
      await tester.tap(find.byType(UnitField)); //Open units dropdown
      await tester.pumpAndSettle();
      await tester.tap(find.text(randomUnitName)); //Tap a random element
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();
      expect(find.text('Created'), findsNothing);

      await tester.enterText(
          find.byKey(Key(bestBeforeDateFieldAtShelf)), '16.12.2019');
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();
      expect(find.text('Created'), findsNothing);

      await tester.enterText(
          find.byKey(Key(newExpDateFieldAtShelf)), '12.12.2019');
      await tester.tap(find.byType(MeasurementButton));
      await tester.pumpAndSettle();
      expect(find.text('Created'), findsOneWidget);
    });

    testWidgets('User should be able to select product',
        (WidgetTester tester) async {
      int randomFromRange = next(0, products.length);
      String productName = products[randomFromRange].name.en;
      await openShelfTraceabilityForm(tester, device);
      await tester.pump();
      //Types in only the first 3 characters of the chosen product.
      await tester.enterText(
          find.byType(ProductSelectField), productName.substring(0, 3));
      await tester.pumpAndSettle();
      await tester.tap(find.text(productName));
      await tester.pumpAndSettle();

      expect(find.text(productName), findsOneWidget);
    });

    testWidgets('User should be able to type the amount',
        (WidgetTester tester) async {
      await openShelfTraceabilityForm(tester, device);
      await tester.enterText(find.byKey(Key(amountFieldAtShelf)), '4');
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('User should be able to select the unit from the list',
        (WidgetTester tester) async {
      await openShelfTraceabilityForm(tester, device);
      final randomUnitName = UnitServiceMock
          .massUnits[next(0, UnitServiceMock.massUnits.length)].name;

      await tester.pumpAndSettle();
      await tester.tap(find.byType(UnitField)); //Open units dropdown
      await tester.pumpAndSettle();
      await tester.tap(find.text(randomUnitName)); //Tap a random element
      await tester.pumpAndSettle();
      var titleField =
          tester.firstWidget(find.byKey(Key(unitFieldTitle))) as Text;
      expect(titleField.data, equals(randomUnitName));
    });

    testWidgets('User should be able to type in "best before or batch"',
        (WidgetTester tester) async {
      await openShelfTraceabilityForm(tester, device);
      await tester.enterText(
          find.byKey(Key(bestBeforeDateFieldAtShelf)), '16.12.2019');
      expect(find.text('16.12.2019'), findsOneWidget);
    });

    testWidgets(
        'User should be able to select a date for "best before or batch" from the calendar',
        (WidgetTester tester) async {
      await openShelfTraceabilityForm(tester, device);
      await tester.tap(find.byKey(Key(
          '${datePickerIcon}_${Key(bestBeforeDateFieldAtShelf).toString()}')));
      await tester.pump(Duration(seconds: 1));
      await tester.tap(find.text('12')); //Taps on 12th Date
      await tester.tap(find.text('OK'));
      await tester.pump(Duration(seconds: 1));
      //Finds substring 12 in TextField - independent of the year and month.
      expect(find.byWidgetPredicate((widget) {
        if (widget.key == Key(bestBeforeDateFieldAtShelf)) {
          final TextOrDateField dateWidget = widget;
          if (dateWidget.controller.text != null)
            return dateWidget.controller.text.contains('12');
        }
        return false;
      }), findsOneWidget);
    });

    testWidgets(
        'User should be able to type "new expiration date" when product is custom',
        (WidgetTester tester) async {
      await openShelfTraceabilityForm(tester, device);

      await tester.enterText(find.byType(ProductSelectField), 'Test Product');
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(Key(newExpDateFieldAtShelf)), '12.12.2019');
      expect(find.text('12.12.2019'), findsOneWidget);
    });

    testWidgets(
        'User should be able to select a date for "new expiration date" from the calendar ',
        (WidgetTester tester) async {
      Key innerTextOrDateKey =
          Key('${Key(newExpDateFieldAtShelf).toString()}_textOrDate');
      await openShelfTraceabilityForm(tester, device);
      await tester.pump();
      await tester.enterText(find.byType(ProductSelectField), 'Test Product');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(innerTextOrDateKey), '12.12.2019');
      await tester.tap(find
          .byKey(Key('${datePickerIcon}_${innerTextOrDateKey.toString()}')));
      await tester.pump(Duration(seconds: 1));
      await tester.tap(find.text('12')); //Taps on 12th Date
      await tester.tap(find.text('OK'));
      await tester.pump(Duration(seconds: 1)); //Wait for date picker to close
      //Finds substring 12 in TextField - independent of the year and month.
      expect(find.byWidgetPredicate((widget) {
        if (widget.key == innerTextOrDateKey) {
          final TextOrDateField dateWidget = widget;
          if (dateWidget.controller.text != null)
            return dateWidget.controller.text.contains('12');
        }
        return false;
      }), findsOneWidget);
    });
  });
}

Future openShelfTraceabilityForm(WidgetTester tester, Device device) async {
  await tester.pumpWidget(LocaleWrapper(child: ShelfTraceabilityForm(device)));
  await tester.pump();
}

int next(int min, int max) {
  final _random = new Random();
  return min + _random.nextInt(max - min);
}

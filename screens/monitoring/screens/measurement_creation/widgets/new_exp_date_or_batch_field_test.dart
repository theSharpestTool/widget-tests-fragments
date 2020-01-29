import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/product.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/new_exp_date_or_batch_field.dart';
import 'package:fooddocs_flutter_app/services/helper.service.dart';

import '../../../../../test_helpers/mock_data/product.dart';
import '../../../../../test_helpers/wrappers/locale_wrapper.dart';

void main() {
  group('New exp date or batch field calculation for "use by"', () {
    testWidgets('day period', (WidgetTester tester) async {
      DateTime time = DateTime.now();
      Product product = useByProductsList['day'];

      await pumpField(
        tester,
        time: time,
        product: product,
        onSelected: (String value) {},
      );

      await tester.pumpAndSettle();

      time = time.add(Duration(days: product.packaging.expiryDate));

      expect(
        find.text(formatDateToDDMMYYYY(time, 'dd.MM.y HH:mm')),
        findsOneWidget,
      );
    });

    testWidgets('hour period', (WidgetTester tester) async {
      DateTime time = DateTime.now();
      Product product = useByProductsList['hour'];

      await pumpField(
        tester,
        time: time,
        product: product,
        onSelected: (String value) {},
      );

      await tester.pumpAndSettle();

      time = time.add(Duration(hours: product.packaging.expiryDate));

      expect(
        find.text(formatDateToDDMMYYYY(time, 'dd.MM.y HH:mm')),
        findsOneWidget,
      );
    });

    testWidgets('month period', (WidgetTester tester) async {
      DateTime time = DateTime.now();
      Product product = useByProductsList['month'];

      await pumpField(
        tester,
        time: time,
        product: product,
        onSelected: (String value) {},
      );

      await tester.pumpAndSettle();

      time = DateTime(
        time.year,
        time.month + product.packaging.expiryDate,
        time.day,
        time.hour,
        time.minute,
      );

      expect(
        find.text(formatDateToDDMMYYYY(time, 'dd.MM.y HH:mm')),
        findsOneWidget,
      );
    });

    testWidgets('week period', (WidgetTester tester) async {
      DateTime time = DateTime.now();
      Product product = useByProductsList['week'];

      await pumpField(
        tester,
        time: time,
        product: product,
        onSelected: (String value) {},
      );

      await tester.pumpAndSettle();

      time = time.add(Duration(
        days: (DateTime.daysPerWeek * product.packaging.expiryDate),
      ));

      expect(
        find.text(formatDateToDDMMYYYY(time, 'dd.MM.y HH:mm')),
        findsOneWidget,
      );
    });

    testWidgets('year period', (WidgetTester tester) async {
      DateTime time = DateTime.now();
      Product product = useByProductsList['year'];

      await pumpField(
        tester,
        time: time,
        product: product,
        onSelected: (String value) {},
      );

      await tester.pumpAndSettle();

      time = DateTime(
        time.year + product.packaging.expiryDate,
        time.month,
        time.day,
        time.hour,
        time.minute,
      );

      expect(
        find.text(formatDateToDDMMYYYY(time, 'dd.MM.y HH:mm')),
        findsOneWidget,
      );
    });
  });

  group('New exp date or batch field calculation for "best before"', () {
    testWidgets('day period', (WidgetTester tester) async {
      DateTime time = DateTime.now();
      Product product = bestBeforeProductsList['day'];

      await pumpField(
        tester,
        time: time,
        product: product,
        onSelected: (String value) {},
      );

      await tester.pumpAndSettle();

      time = time.add(Duration(days: product.packaging.bestBefore));

      expect(
        find.text(formatDateToDDMMYYYY(time, 'dd.MM.y HH:mm')),
        findsOneWidget,
      );
    });

    testWidgets('hour period', (WidgetTester tester) async {
      DateTime time = DateTime.now();
      Product product = bestBeforeProductsList['hour'];

      await pumpField(
        tester,
        time: time,
        product: product,
        onSelected: (String value) {},
      );

      await tester.pumpAndSettle();

      time = time.add(Duration(hours: product.packaging.bestBefore));

      expect(
        find.text(formatDateToDDMMYYYY(time, 'dd.MM.y HH:mm')),
        findsOneWidget,
      );
    });

    testWidgets('month period', (WidgetTester tester) async {
      DateTime time = DateTime.now();
      Product product = bestBeforeProductsList['month'];

      await pumpField(
        tester,
        time: time,
        product: product,
        onSelected: (String value) {},
      );

      await tester.pumpAndSettle();

      time = DateTime(
        time.year,
        time.month + product.packaging.bestBefore,
        time.day,
        time.hour,
        time.minute,
      );

      expect(
        find.text(formatDateToDDMMYYYY(time, 'dd.MM.y HH:mm')),
        findsOneWidget,
      );
    });

    testWidgets('week period', (WidgetTester tester) async {
      DateTime time = DateTime.now();
      Product product = bestBeforeProductsList['week'];

      await pumpField(
        tester,
        time: time,
        product: product,
        onSelected: (String value) {},
      );

      await tester.pumpAndSettle();

      time = time.add(Duration(
        days: (DateTime.daysPerWeek * product.packaging.bestBefore),
      ));

      expect(
        find.text(formatDateToDDMMYYYY(time, 'dd.MM.y HH:mm')),
        findsOneWidget,
      );
    });

    testWidgets('year period', (WidgetTester tester) async {
      DateTime time = DateTime.now();
      Product product = bestBeforeProductsList['year'];

      await pumpField(
        tester,
        time: time,
        product: product,
        onSelected: (String value) {},
      );

      await tester.pumpAndSettle();

      time = DateTime(
        time.year + product.packaging.bestBefore,
        time.month,
        time.day,
        time.hour,
        time.minute,
      );

      expect(
        find.text(formatDateToDDMMYYYY(time, 'dd.MM.y HH:mm')),
        findsOneWidget,
      );
    });
  });
}

Future pumpField(
  WidgetTester tester, {
  DateTime time,
  Product product,
  Function(String) onSelected,
}) async {
  await tester.pumpWidget(LocaleWrapper(
      child: NewExpDateOrBatchField(
    time: time,
    enabled: true,
    onSelected: onSelected,
    controller: TextEditingController(
        text: formatDateToDDMMYYYY(
            getNewExpirationDate(product, time), 'dd.MM.y HH:mm')),
  )));
}

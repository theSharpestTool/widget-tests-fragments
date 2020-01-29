import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/common/common.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/checkbox_selector_dialog.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/widgets/problems_list_field.dart';

import '../../../../../test_helpers/wrappers/locale_wrapper.dart';

void main() {
  String testTitle;
  List<String> chipList;
  List<Problem> problemList;
  setUpAll(() {
    testTitle = "Test Title";
    chipList = ["Action 1", "Action 2", "Action 3"];
    problemList = [
      Problem(id: 1, name: 'Problem 1'),
      Problem(id: 2, name: 'Problem 2'),
      Problem(id: 3, name: 'Problem 3'),
      Problem(id: 4, name: 'Problem 4'),
    ];
  });

  group("SelectorDialog Widget Tests", () {
    testWidgets("Compare inserted title with displayed",
        (WidgetTester tester) async {
      await pumpSelectorDialogWidget(testTitle, chipList, tester);

      await tester.pumpAndSettle();

      expect(find.byType(SelectorDialog), findsOneWidget);
    });

    testWidgets("User should be able to see all values from chipsList",
        (WidgetTester tester) async {
      await pumpSelectorDialogWidget(testTitle, chipList, tester);

      await tester.pumpAndSettle();

      chipList.forEach((chip) {
        expect(find.text(chip), findsOneWidget);
      });
    });

    testWidgets('Dialog from property `dialogWidget` should be shown on click',
        (WidgetTester tester) async {
      await pumpSelectorDialogWidget(testTitle, chipList, tester,
          problemList: problemList);

      await tester.pumpAndSettle();
      await tester.tap(find.byType(SelectorDialog));
      await tester.pumpAndSettle();

      expect(find.byType(ProblemsListField), findsOneWidget);
    });

    testWidgets('Check Enabled / Disabled States on click',
        (WidgetTester tester) async {
      await pumpSelectorDialogWidget(testTitle, chipList, tester,
          problemList: problemList, enabled: false);

      await tester.pumpAndSettle();
      await tester.tap(find.byType(SelectorDialog));
      await tester.pumpAndSettle();

      expect(find.byType(ProblemsListField), findsNothing);

      await pumpSelectorDialogWidget(testTitle, chipList, tester,
          problemList: problemList, enabled: true);

      await tester.pumpAndSettle();
      await tester.tap(find.byType(SelectorDialog));
      await tester.pumpAndSettle();

      expect(find.byType(ProblemsListField), findsOneWidget);
    });

    testWidgets('Check Vertical and Horizontal Layout',
        (WidgetTester tester) async {
      await pumpSelectorDialogWidget(testTitle, chipList, tester,
          horizontal: false);

      await tester.pumpAndSettle();

      //Finds 1 Portrait Column and 0 Horizontal Row
      expect(find.byKey(Key('Vertical_Column')), findsOneWidget);
      expect(find.byKey(Key('Horizontal_Row')), findsNothing);

      await pumpSelectorDialogWidget(testTitle, chipList, tester,
          horizontal: true);

      await tester.pumpAndSettle();

      //Finds 0 Portrait Column and 1 Horizontal Row
      expect(find.byKey(Key('Vertical_Column')), findsNothing);
      expect(find.byKey(Key('Horizontal_Row')), findsOneWidget);
    });
  });
}

Future pumpSelectorDialogWidget(
    String testTitle, List<String> chipList, WidgetTester tester,
    {List<Problem> problemList,
    bool enabled = true,
    bool horizontal = false}) async {
  await tester.pumpWidget(LocaleWrapper(
    child: SelectorDialog(
      dialogWidget: ProblemsListField(values: problemList),
      title: testTitle,
      chipsList: chipList,
      enabled: enabled,
      horizontal: horizontal,
    ),
  ));
}

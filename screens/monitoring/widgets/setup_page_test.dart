


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/screens/setup_screen.dart';
import 'package:fooddocs_flutter_app/services/auth.service.dart';
import 'package:fooddocs_flutter_app/services/company.service.dart';
import 'package:fooddocs_flutter_app/services/place.service.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helpers/wrappers/locale_wrapper.dart';
import '../../main_screen_test.dart';

class FutureCallbackMock extends Mock implements Function {
  Future<void> call();
}

main(){

  setUp((){
    AuthService.instance = AuthServiceMock();
    CompanyService.instance = CompanyServiceMock();
    PlaceService.instance = PlaceServiceMock();

    when(CompanyService.instance.refresh()).thenAnswer((_) async => null);
    when(CompanyService.instance.hasAtLeastOneCompany).thenReturn(false);
    when(PlaceService.instance.hasAtLeastOnePlace).thenReturn(false);
  });

  group("Setup View tests", (){
    testWidgets("Setup view showed correctly", (tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: SetupScreen(
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Refresh'), findsOneWidget);
      expect(
          find.text(
              'You can use all program features when you add food handling place'),
          findsOneWidget);
      expect(find.text('Add food handling place'), findsOneWidget);
      expect(find.text('log_out'), findsOneWidget);

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      when(AuthService.instance.logOut()).thenAnswer((_) async => Future.value(null));

      await tester.tap(find.text("log_out"));

      verify(AuthService.instance.logOut());

    });

    testWidgets("Setup view: can log out", (tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: SetupScreen(),
        ),
      );

      await tester.pump();

      when(AuthService.instance.logOut()).thenAnswer((_) async => Future.value(null));

      await tester.tap(find.text("log_out"));

      verify(AuthService.instance.logOut());

    });

    testWidgets("Setup view: can refresh", (tester) async {

      await tester.pumpWidget(
        LocaleWrapper(
          child: SetupScreen(),
        ),
      );

      await tester.pump();

      final state = tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator));

      state.show();

      await tester.pumpAndSettle();

      verify(CompanyService.instance.refresh());


    });
  });
}
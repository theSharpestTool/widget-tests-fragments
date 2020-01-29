import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/device.dart';
import 'package:fooddocs_flutter_app/models/version.dart';
import 'package:fooddocs_flutter_app/screens/auth/auth.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/monitoring.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/devices_list.dart';
import 'package:fooddocs_flutter_app/services/api.service.dart';
import 'package:fooddocs_flutter_app/services/auth.service.dart';
import 'package:fooddocs_flutter_app/services/company.service.dart';
import 'package:fooddocs_flutter_app/services/monitoring.service.dart';
import 'package:fooddocs_flutter_app/services/version.service.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helpers/mock_data/auth.dart';
import '../../../test_helpers/mock_data/company.dart';
import '../../../test_helpers/mock_data/devices.dart';
import '../../../test_helpers/mock_data/places.dart';
import '../../../test_helpers/mock_data/storages.dart';
import '../../../test_helpers/mock_services/correcting_actions_service_mock.dart';
import '../../../test_helpers/mock_services/monitoring_service_mock.dart';
import '../../../test_helpers/mock_services/unit_service_mock.dart';
import '../../../test_helpers/wrappers/locale_wrapper.dart';

import 'package:http/http.dart' as http;

class MockClient extends Mock implements ApiClient {}

class MockStorage extends Mock implements FlutterSecureStorage {}

class VersionServiceMock extends Mock implements VersionService {}

void main() {
  final devices = MonitoringServiceMock.devices;
  final client = MockClient();
  final storage = MockStorage();

  final profileResponse = http.Response(jsonEncode(profileData), 200);
  final companiesResponse = http.Response(jsonEncode(companiesData), 200);
  final placeResponse = http.Response(jsonEncode(selectedPlaceData), 200);
  final storagesResponse = http.Response(jsonEncode(storagesData), 200);
  final deviceTypesResponse = http.Response(jsonEncode(deviceTypesData), 200);
  final devicesResponse = http.Response(jsonEncode(devicesData), 200);

  final placeId = companiesData.first['places'].first['id'];

  setUpAll(() {

    MonitoringServiceMock.mock();
    CorrectingActionsServiceMock.mock();
    UnitServiceMock.mock();

    VersionService.instance = VersionServiceMock();

    when(VersionService.instance.getVersionSpec()).thenAnswer((_) => Future.value(VersionSpec.unknown));
    when(VersionService.instance.getAppVersion()).thenAnswer((_) => Future.value(Version.unknown));
  });

  testWidgets(
    'No device in arguments should redirect the user to the monitoring page and notify about the error',
    (WidgetTester tester) async {
      MonitoringServiceMock.mock();
      CorrectingActionsServiceMock.mock();
      UnitServiceMock.mock();

      await tester.pumpWidget(
        LocaleWrapper(
          child: DevicesListPage(),
        ),
      );
      await tester.pumpAndSettle();

    },
  );

  testWidgets(
    'The back icon should navigate the user back in history ',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          previousPageRoute: AuthPage.routeName,
          child: DevicesListPage(
            devTypeArguments: DeviceTypeArguments(
              DeviceTypeWithDevices(1, 'slug', devices),
              () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('slug'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_right),
          findsNWidgets(devices.length));

      await tester.tap(find.byIcon(Icons.keyboard_arrow_left));
      await tester.pumpAndSettle();

      expect(find.byType(AuthPage), findsOneWidget);
    },
  );

  testWidgets(
    'User can refresh devices',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: DevicesListPage(
            devTypeArguments: DeviceTypeArguments(
              DeviceTypeWithDevices(13, 'slug', devices),
              () {},
            ),
          ),
        ),
      );

      final topDevice = 'Traceability';
      await tester.pumpAndSettle();

      MonitoringServiceMock.mockUpdate();

      await tester.drag(find.text(topDevice), Offset(0, 500));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_right),
          findsNWidgets(MonitoringServiceMock.updatedDevices.length));

      MonitoringServiceMock.mock();
    },
  );

  testWidgets(
    'User can tap on each device',
    (WidgetTester tester) async {
      BuildContext widgetContext;

      await tester.pumpWidget(
        LocaleWrapper(
          child: Builder(builder: (context) {
            widgetContext = context;
            return DevicesListPage(
              devTypeArguments: DeviceTypeArguments(
                DeviceTypeWithDevices(
                    13, 'slug', MonitoringServiceMock.devices),
                () {},
              ),
            );
          }),
        ),
      );

      await tester.pumpAndSettle();

      for (final device in devices) {
        final deviceName = device.getName(widgetContext);
        expect(find.text(deviceName), findsOneWidget);
        await tester.tap(find.text(deviceName));
        await tester.pumpAndSettle();
        expect(find.text(deviceName), findsOneWidget);
        await tester.tap(find.byIcon(Icons.keyboard_arrow_left));
        await tester.pumpAndSettle();
      }
    },
  );
}

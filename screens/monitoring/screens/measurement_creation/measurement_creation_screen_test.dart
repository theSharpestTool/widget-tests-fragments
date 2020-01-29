import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/device.dart';
import 'package:fooddocs_flutter_app/models/version.dart';
import 'package:fooddocs_flutter_app/screens/auth/auth.dart';
import 'package:fooddocs_flutter_app/screens/main_screen.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/device_types/complaints.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/device_types/delivery_control.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/device_types/pest_control.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/device_types/shelf_traceability.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/device_types/tasks.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/device_types/traceability.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/measurement_creation.dart';
import 'package:fooddocs_flutter_app/services/api.service.dart';
import 'package:fooddocs_flutter_app/services/auth.service.dart';
import 'package:fooddocs_flutter_app/services/company.service.dart';
import 'package:fooddocs_flutter_app/services/monitoring.service.dart';
import 'package:fooddocs_flutter_app/services/version.service.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_helpers/mock_data/auth.dart';
import '../../../../test_helpers/mock_data/company.dart';
import '../../../../test_helpers/mock_data/devices.dart';
import '../../../../test_helpers/mock_data/places.dart';
import '../../../../test_helpers/mock_data/storages.dart';
import '../../../../test_helpers/mock_services/correcting_actions_service_mock.dart';
import '../../../../test_helpers/mock_services/monitoring_service_mock.dart';
import '../../../../test_helpers/mock_services/unit_service_mock.dart';
import '../../../../test_helpers/wrappers/locale_wrapper.dart';

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
  setUp(() {
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
          previousPageRoute: MainScreen.routeName,
          child: MeasurementCreation(),
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
          child: MeasurementCreation(
            device: Device(
              deviceTypeId: 4,
              name: 'device',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left));
      await tester.pumpAndSettle();

      expect(find.byType(AuthPage), findsOneWidget);
    },
  );

  group('Check every device type', () {
    testWidgets(
      'Complaints',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: MeasurementCreation(
              device: Device(
                name: 'device',
                deviceTypeId: 3,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('complaints'), findsOneWidget);
        expect(find.byType(ComplaintsForm), findsOneWidget);
      },
    );

    testWidgets(
      'Delivery control',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: MeasurementCreation(
              device: Device(
                name: 'device',
                deviceTypeId: 4,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('company_supplier'), findsOneWidget);
        expect(find.byType(DeliveryControlForm), findsOneWidget);
      },
    );

    testWidgets(
      'Traceability',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: MeasurementCreation(
              device: Device(
                name: 'device',
                deviceTypeId: 5,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Traceability'), findsOneWidget);
        expect(find.byType(TraceabilityForm), findsOneWidget);
      },
    );

    testWidgets(
      'Shelf-life traceability',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: MeasurementCreation(
              device: Device(
                name: 'device',
                deviceTypeId: 6,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Shelf-life traceability'), findsOneWidget);
        expect(find.byType(ShelfTraceabilityForm), findsOneWidget);
      },
    );

    testWidgets(
      'Pest control',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: MeasurementCreation(
              device: Device(
                name: 'device',
                deviceTypeId: 8,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('device'), findsOneWidget);
        expect(find.byType(PestControlForm), findsOneWidget);
      },
    );

    testWidgets(
      'Cleaning and Disinfection tasks',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: MeasurementCreation(
              device: Device(
                name: 'device',
                deviceTypeId: 9,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('device'), findsOneWidget);
        expect(find.byType(TasksForm), findsOneWidget);
      },
    );

    testWidgets(
      'Analyses',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: MeasurementCreation(
              device: Device(
                name: 'device',
                deviceTypeId: 10,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('device'), findsOneWidget);
        expect(find.byType(PestControlForm), findsOneWidget);
      },
    );

    testWidgets(
      'Calibration',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: MeasurementCreation(
              device: Device(
                name: 'device',
                deviceTypeId: 11,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('device'), findsOneWidget);
        expect(find.byType(PestControlForm), findsOneWidget);
      },
    );

    testWidgets(
      'Maintenance',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: MeasurementCreation(
              device: Device(
                name: 'device',
                deviceTypeId: 12,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('device'), findsOneWidget);
        expect(find.byType(PestControlForm), findsOneWidget);
      },
    );

    testWidgets(
      'Tasks',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: MeasurementCreation(
              device: Device(
                name: 'device',
                deviceTypeId: 13,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('device'), findsOneWidget);
        expect(find.byType(TasksForm), findsOneWidget);
      },
    );

    testWidgets(
      'Supervisory tasks',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: MeasurementCreation(
              device: Device(
                name: 'device',
                deviceTypeId: 14,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Supervisory tasks'), findsOneWidget);
        expect(find.byType(TasksForm), findsOneWidget);
      },
    );
  });
}

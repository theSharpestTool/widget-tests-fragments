import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/device.dart';
import 'package:fooddocs_flutter_app/models/storage.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/correcting_actions_dialog.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/device_rows/cold_storage.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/state_marker.dart';
import 'package:fooddocs_flutter_app/services/api.service.dart';
import 'package:fooddocs_flutter_app/services/correcting-actions.service.dart';
import 'package:fooddocs_flutter_app/services/monitoring.service.dart';
import 'package:fooddocs_flutter_app/services/storages.service.dart';
import 'package:fooddocs_flutter_app/widgets/temperature_field.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../../../../test_helpers/mock_data/auth.dart';
import '../../../../test_helpers/mock_data/correcting_action.dart';
import '../../../../test_helpers/mock_data/measurement.dart';
import '../../../../test_helpers/mock_data/storages.dart';
import '../../../../test_helpers/wrappers/locale_wrapper.dart';

class MockClient extends Mock implements ApiClient {}

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  final client = MockClient();



  final devices = <Device>[
    Device(
      id: 1,
      storageId: 3,
      deviceTypeId: 1,
      name: 'device 1',
      isScheduleDone: false,
    ),
    Device(
      id: 2,
      deviceTypeId: 1,
      name: 'device 2',
      isScheduleDone: false,
    ),
    Device(
      id: 3,
      deviceTypeId: 1,
      name: 'device 3',
      isScheduleDone: true,
    ),
  ];

  final devicesWithType = DeviceTypeWithDevices(1, 'slug', devices);
  final singleDeviceWithType =
      DeviceTypeWithDevices(1, 'slug', [devices.first]);
  final devicesAmount = devices.length;
  final measurementValue = '0';
  final wrongMeasurementValue = '20';

  setUpAll(() async {
    final profileResponse = http.Response(jsonEncode(profileData), 200);
    final measurementResponse = http.Response(jsonEncode(measurementData), 200);
    final correctingActionsResponse =
        http.Response(jsonEncode(correctingActionsData), 200);
    final storagesResponse = http.Response(jsonEncode(storagesData), 200);

    when(client.get(any)).thenAnswer((_) async => profileResponse);
    when(client.post(any, body: anyNamed('body')))
        .thenAnswer((_) async => measurementResponse);
    when(client.get('/api/classifiers/correcting-actions'))
        .thenAnswer((_) async => correctingActionsResponse);
    when(client.get('/api/classifiers/storages'))
        .thenAnswer((_) async => storagesResponse);

    CorrectingActionsService.instance = CorrectingActionsService(client);
    StoragesService.instance = StoragesService(client);
    MonitoringService.instance = MonitoringService(client);

    await CorrectingActionsService.instance.getAll();
  });

  testWidgets(
    'Cold storage row displayed correctly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: ColdStorageRow(devicesWithType),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StateMarker), findsNWidgets(devicesAmount));
      expect(find.byType(TemperatureField), findsNWidgets(devicesAmount));
      expect(find.byType(Divider), findsNWidgets(devicesAmount));
      expect(find.text('Add temperature'), findsNothing);

      for (final device in devices) {
        expect(find.text(device.name), findsOneWidget);

        final marker = tester.firstWidget(
            find.byKey(Key('device_state_marker_${device.id}'))) as StateMarker;
        expect(marker.stateMarker, device.isScheduleDone);
      }
    },
  );

  testWidgets(
    'Cold storage row displayed correctly on tablet',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: ColdStorageRow(
            devicesWithType,
            isTablet: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StateMarker), findsNWidgets(devicesAmount));
      expect(find.byType(TemperatureField), findsNWidgets(devicesAmount));
      expect(find.byType(Divider), findsNWidgets(devicesAmount));
      expect(find.text('Add temperature'), findsNWidgets(devicesAmount));

      for (final device in devices) {
        expect(find.text(device.name), findsOneWidget);

        final marker = tester.firstWidget(
            find.byKey(Key('device_state_marker_${device.id}'))) as StateMarker;
        expect(marker.stateMarker, device.isScheduleDone);
      }
    },
  );

  testWidgets(
    'User can create measurement',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: ColdStorageRow(
            singleDeviceWithType,
            onAllDevicesDone: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      final unDoneMarker =
          tester.firstWidget(find.byType(StateMarker)) as StateMarker;
      expect(unDoneMarker.stateMarker, isFalse);

      await tester.enterText(find.byType(TemperatureField), measurementValue);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.byType(TemperatureField), findsNothing);
      expect(find.text('New item'), findsOneWidget);
      expect(find.text(measurementValue), findsOneWidget);

      final doneMarker =
          tester.firstWidget(find.byType(StateMarker)) as StateMarker;
      expect(doneMarker.stateMarker, isTrue);

      devices.first.isAwaitingMeasurementInput = true;
      devices.first.measurements.removeLast();
    },
  );

  testWidgets(
    'User can create and update measurement',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: ColdStorageRow(
            singleDeviceWithType,
            onAllDevicesDone: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TemperatureField), measurementValue);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.text('New item'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TemperatureField), measurementValue);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.byType(TemperatureField), findsNothing);
      expect(find.text('New item'), findsOneWidget);

      final doneMarker =
          tester.firstWidget(find.byType(StateMarker)) as StateMarker;
      expect(doneMarker.stateMarker, isTrue);

      devices.first.isAwaitingMeasurementInput = true;
      devices.first.measurements.removeLast();
    },
  );

  testWidgets(
    'User will see dialog if measurement is out of limits when creating and updating',
    (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(900, 1800));
      await tester.pumpWidget(
        LocaleWrapper(
          child: ColdStorageRow(
            singleDeviceWithType,
            onAllDevicesDone: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(TemperatureField), wrongMeasurementValue);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.byType(CorrectingActionsDialog), findsOneWidget);

      await tester.tap(find.text('done'));
      await tester.pumpAndSettle();

      expect(find.byType(TemperatureField), findsNothing);
      expect(find.text('New item'), findsOneWidget);
      expect(find.text(wrongMeasurementValue), findsOneWidget);

      final doneMarker =
          tester.firstWidget(find.byType(StateMarker)) as StateMarker;
      expect(doneMarker.stateMarker, isTrue);

      await tester.tap(find.text('New item'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TemperatureField), wrongMeasurementValue);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.byType(CorrectingActionsDialog), findsOneWidget);

      await tester.tap(find.text('done'));
      await tester.pumpAndSettle();

      expect(find.byType(TemperatureField), findsNothing);
      expect(find.text('New item'), findsOneWidget);
      expect(find.text(wrongMeasurementValue), findsOneWidget);

      addTearDown(() => binding.setSurfaceSize(null));
    },
  );
}

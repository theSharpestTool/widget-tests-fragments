
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/device.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/monitoring.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/device_types_list.dart';
import 'package:fooddocs_flutter_app/services/monitoring.service.dart';
import 'package:fooddocs_flutter_app/services/storages.service.dart';
import 'package:fooddocs_flutter_app/services/version.service.dart';
import 'package:fooddocs_flutter_app/widgets/fd_error.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../../test_helpers/wrappers/locale_wrapper.dart';
import 'widgets/device_rows/hot_holding_test.dart';

class MockClient extends Mock implements http.Client {}

class MockStorage extends Mock implements FlutterSecureStorage {}

class VersionServiceMock extends Mock implements VersionService {}

void main() {

  final device1 = Device(
    id: 1,
    storageId: 1,
    isScheduleDone: false,
    name: 'device with type 1',
    deviceTypeId: 1,
  );

  final device2 = Device(
    id: 2,
    isScheduleDone: false,
    name: 'device with type 1',
    deviceTypeId: 1,
  );

  final device3 = Device(
    id: 3,
    isScheduleDone: true,
    name: 'device with type 2',
    deviceTypeId: 2,
  );

  final List<DeviceType> deviceTypes = <DeviceType>[
    DeviceType(id: 1, slug: "type 1"),
    DeviceType(id: 2, slug: "type 2"),
  ];

  final List<Device> devices = <Device>[
    device1,
    device2,
    device3,
  ];

  final missingDeviceTypesWithDevice = <DeviceTypeWithDevices>[
    DeviceTypeWithDevices(1, 'type 1', [
      device1,
      device2,
    ]),
  ];

  final deviceTypesWithDevices = <DeviceTypeWithDevices>[
    DeviceTypeWithDevices(1, 'type 1', [
      device1,
      device2,
    ]),
    DeviceTypeWithDevices(2, 'type 2', [
      device3,
    ]),
  ];

  setUp(() {
    MonitoringService.instance = MockedMonitoringService();

    when(MonitoringService.instance.getMissingDeviceTypesWithDevices(any))
        .thenReturn(missingDeviceTypesWithDevice);
    when(MonitoringService.instance.getDeviceTypesWithDevices(any))
        .thenReturn(deviceTypesWithDevices);

    when(MonitoringService.instance.getDeviceTypes()).thenAnswer((_) async => deviceTypes);
    when(MonitoringService.instance.getDevices()).thenAnswer((_) async => devices);


  });

  testWidgets(
    'Monitoring: ToDo page displayed correctly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TodayActivityScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DeviceTypesList), findsOneWidget);

      expect(
          find.text('Please complete following activities:'), findsOneWidget);

      expect(find.byType(ListTile), findsNWidgets(1));
    },
  );

  testWidgets(
    'Monitoring: AllActivities shows error',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: AllActivityView(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DeviceTypesList), findsOneWidget);

      expect(find.byType(ListTile), findsNWidgets(2));

      when(MonitoringService.instance.getDevices()).thenThrow(Exception("ERROR"));

      final refresh = tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator));

      refresh.show();

      await tester.pumpAndSettle();

      expect(find.byType(FDError), findsOneWidget);
    },
  );

  testWidgets(
    'Monitoring: ToDo shows error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: TodayActivityScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DeviceTypesList), findsOneWidget);

      expect(find.byType(ListTile), findsNWidgets(1));

      when(MonitoringService.instance.getDevices()).thenThrow(Exception("ERROR"));

      final refresh = tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator));

      refresh.show();

      await tester.pumpAndSettle();

      expect(find.byType(FDError), findsOneWidget);
    },
  );

  testWidgets(
    'Monitoring: AllActivities page displayed correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: AllActivityView(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DeviceTypesList), findsOneWidget);

      expect(find.byType(ListTile), findsNWidgets(2));
    },
  );
  
  testWidgets("Monitoring: Today activities shows done when all activities are finished", (tester) async {
    when(MonitoringService.instance.getMissingDeviceTypesWithDevices(any)).thenReturn(<DeviceTypeWithDevices>[]);
    await tester.pumpWidget(
      LocaleWrapper(
        child: TodayActivityScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("You are all done for today"), findsOneWidget);
  });

  testWidgets(
    'Monitoring, ToDo tab: All done + reload page',
    (WidgetTester tester) async {

      when(MonitoringService.instance.getMissingDeviceTypesWithDevices(any)).thenReturn(<DeviceTypeWithDevices>[]);

      await tester.pumpWidget(
        LocaleWrapper(
          child: TodayActivityScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("You are all done for today"), findsOneWidget);

      when(MonitoringService.instance.getMissingDeviceTypesWithDevices(any)).thenReturn(missingDeviceTypesWithDevice);

      final refreshIndicatorState = tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator));

      refreshIndicatorState.show();

      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(1));

    },
  );

  testWidgets(
    'Monitoring, AllActivity tab: empty page + reload page',
        (WidgetTester tester) async {

      when(MonitoringService.instance.devices).thenReturn(<Device>[]);

      await tester.pumpWidget(
        LocaleWrapper(
          child: AllActivityView(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MonitoringEmptyView), findsOneWidget);
      expect(find.text('No Devices to show'), findsOneWidget);
      expect(find.text('Setup your activities in'), findsOneWidget);
      expect(find.text('here'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      expect(find.byType(DeviceTypesList), findsNothing);

      when(MonitoringService.instance.devices).thenReturn(devices);

      await tester.tap(find.text("Refresh"));

      expect(tester.hasRunningAnimations, true);

      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(2));

    },
  );

}

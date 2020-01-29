import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/device.dart';
import 'package:fooddocs_flutter_app/models/measurement.dart';
import 'package:fooddocs_flutter_app/models/product.dart';
import 'package:fooddocs_flutter_app/models/storage.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/correcting_actions_dialog.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/device_rows/hot_holding.dart';
import 'package:fooddocs_flutter_app/services/correcting-actions.service.dart';
import 'package:fooddocs_flutter_app/services/monitoring.service.dart';
import 'package:fooddocs_flutter_app/services/production.service.dart';
import 'package:fooddocs_flutter_app/services/storages.service.dart';
import 'package:fooddocs_flutter_app/services/websocket.service.dart';
import 'package:fooddocs_flutter_app/widgets/product_select_field.dart';
import 'package:fooddocs_flutter_app/widgets/temperature_field.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_helpers/mock_services/correcting_actions_service_mock.dart';
import '../../../../test_helpers/mock_services/websocket_service_mock.dart';
import '../../../../test_helpers/wrappers/locale_wrapper.dart';

class MockedMonitoringService extends Mock implements MonitoringService {}

class MockedCorrectingActionsService extends Mock
    implements CorrectingActionsService {}

class MockProductionService extends Mock implements ProductionService {}

class MockStoragesService extends Mock implements StoragesService{}

main() {
  Device grill;
  Device oven;
  List<Device> allDevices;
  StreamController<WebSocketEvent> webSocketEvents;
  DeviceTypeWithDevices deviceTypeWithDevices;

  setUp(() {
    webSocketEvents = StreamController<WebSocketEvent>.broadcast();

    WebSocketService.instance = MockedWebSocketService(
        channel: MockedWebSocketChannel(webSocketEvents.stream));
    MonitoringService.instance = MockedMonitoringService();
    CorrectingActionsService.instance = MockedCorrectingActionsService();
    ProductionService.instance = MockProductionService();


    final limits = Limit.fromJson({"lower_limit": "75", "upper_limit": "100"});

    grill = Device(
      id: 1,
      name: "Grill",
      limits: limits,
      isDone: false,
      isScheduleDone: false,
      deviceTypeId: 2,
    );

    oven = Device(
        id: 1,
        limits: limits,
        name: "Oven",
        isScheduleDone: true,
        isDone: true,
        deviceTypeId: 2);

    allDevices = [grill, oven];

    deviceTypeWithDevices = DeviceTypeWithDevices(1, "hot_holding", allDevices);

    when(MonitoringService.instance.isTypeWithSingleDevice(any))
        .thenReturn(false);

    when(ProductionService.instance.getProductsByQuery(any, any, any))
        .thenAnswer((_) => Future.value(<Product>[]));

    when(MonitoringService.instance.createMeasurement(any, any))
        .thenAnswer((_) => Future.value(CreateMeasurementResponse([null], grill)));

    when(CorrectingActionsService.instance.getAll())
        .thenAnswer((_) async => CorrectingActionsServiceMock.correctingActions);
  });

  tearDown(() {
    webSocketEvents.close();
  });

  group("Hot holding tests", () {
    testWidgets("Device rows displayed and only one is kept open at the time",
        (tester) async {
      await tester.pumpWidget(LocaleWrapper(
        child: HotHolding(deviceTypeWithDevices, () {}),
      ));

      await tester.pump();
      await tester.tap(find.text("Oven"));
      await tester.pumpAndSettle();

      expect(find.byType(DeviceRowWidget), findsOneWidget);

      await tester.pump();
      await tester.tap(find.text("Grill"));
      await tester.pumpAndSettle();

      expect(find.byType(DeviceRowWidget), findsOneWidget);

      await tester.pump();
      await tester.tap(find.text("Grill"));
      await tester.pumpAndSettle();

      expect(find.byType(DeviceRowWidget), findsNothing);
    });

    testWidgets("Insert and delete rows test", (tester) async {
      await tester.pumpWidget(LocaleWrapper(
        child: HotHolding(deviceTypeWithDevices, () {}),
      ));

      await tester.pump();
      await tester.tap(find.text("Oven"));
      await tester.pumpAndSettle();

      expect(find.byType(TextFieldsRow), findsOneWidget);

      await tester.enterText(find.byType(TemperatureField), "80.0");

      await tester.tap(find.text("Add another"));

      await tester.pumpAndSettle();

      expect(find.byType(TextFieldsRow), findsNWidgets(2));

      await tester.tap(find.descendant(
          of: find.ancestor(
              of: find.text("80.0"), matching: find.byType(TextFieldsRow)),
          matching: find.byIcon(
            Icons.cancel,
          )));

      await tester.pumpAndSettle();

      expect(find.byType(TextFieldsRow), findsOneWidget);

      expect(find.byIcon(Icons.cancel), findsNothing);
    });

    testWidgets("Entering too low temperature shows dialog", (tester) async {
      await tester.pumpWidget(
        LocaleWrapper(child: HotHolding(deviceTypeWithDevices, () {})),
      );

      when(MonitoringService.instance.createMeasurement(any, any))
          .thenAnswer((invocation) async {
        final num deviceID = invocation.positionalArguments[0];
        final MeasurementCreationData creationData =
            invocation.positionalArguments[1];
        return CreateMeasurementResponse([creationData], grill);
      });

      await tester.pump();
      await tester.tap(find.text("Grill"));
      await tester.pumpAndSettle();

      expect(find.byType(TextFieldsRow), findsOneWidget);

      await tester.enterText(find.byType(ProductSelectField), "Chicken");

      await tester.enterText(find.byType(TemperatureField), "40.0");

      await tester.pumpAndSettle();

      await tester.tap(find.byType(ProductSelectField));

      await tester.pumpAndSettle();

      expect(find.byType(CorrectingActionsDialog), findsOneWidget);

      await tester.tap(find.text("done"));

      await tester.pumpAndSettle();

      expect(find.byType(CorrectingActionsDialog), findsNothing);

      await tester.pumpAndSettle();
    });

    testWidgets("Measurement from socket", (tester) async {
      await tester.pumpWidget(LocaleWrapper(
        child: HotHolding(deviceTypeWithDevices, () {}),
      ));

      await tester.pump();
      await tester.tap(find.text("Grill"));
      await tester.pumpAndSettle();

      expect(find.byType(TextFieldsRow), findsOneWidget);

      webSocketEvents.add(MockedWebSocketEvent(
          data: json.encode(
              {"data": InteractiveMeasurement(status: "STARTED").toJson()})));

      await tester.pump(Duration(milliseconds: 250));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      webSocketEvents.add(MockedWebSocketEvent(
          data: json.encode({
        "data": InteractiveMeasurement(
                status: "MEASURED",
                measurement: 78.4,
                timestamp: DateTime.now().toIso8601String())
            .toJson()
      })));

      await tester.pump(Duration(milliseconds: 250));

      expect(find.byType(CircularProgressIndicator), findsNothing);

      expect(find.text("78.4"), findsOneWidget);

      //await tester.tap(find.text("Add another"));

      webSocketEvents.add(MockedWebSocketEvent(
          data: json.encode({
        "data": InteractiveMeasurement(
                status: "MEASURED",
                measurement: 79.4,
                timestamp: DateTime.now().toIso8601String())
            .toJson()
      })));

      await tester.pumpAndSettle();

      expect(find.text("78.4"), findsOneWidget);
      expect(find.text("79.4"), findsOneWidget);
    });

    testWidgets("After creating measurement client stays on the same sheet",
        (tester) async {
      await tester.pumpWidget(LocaleWrapper(
        child: HotHolding(deviceTypeWithDevices, () {}),
      ));

      await tester.pump();
      await tester.tap(find.text("Grill"));
      await tester.pumpAndSettle();

      expect(find.byType(TextFieldsRow), findsOneWidget);

      await tester.enterText(find.byType(ProductSelectField), "Chicken");
      await tester.enterText(find.byType(TemperatureField), "80.0");
      await tester.pumpAndSettle();

      await tester.tap(find.text('save_data'));

      // for (final device in allDevices)
      //   expect(find.text(device.name), findsOneWidget);
    });
  });
}

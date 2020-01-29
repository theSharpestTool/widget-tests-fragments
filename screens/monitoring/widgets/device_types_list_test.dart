import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/device.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/FDExpansionTile.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/device_rows/cold_storage.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/device_rows/devices_list_redirect_tile.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/device_rows/hot_holding.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/device_rows/measurement_creation_link_tile.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/device_types_list.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/state_marker.dart';
import '../../../test_helpers/wrappers/locale_wrapper.dart';

void main() {
  testWidgets(
    'Device types list can be empty',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: DeviceTypesList([]),
        ),
      );
      await tester.pump();

      expect(find.byType(Text), findsNothing);
      expect(find.byType(DeviceTypesList), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    },
  );

  testWidgets(
    'Device types list can be null',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: DeviceTypesList(null),
        ),
      );
      await tester.pump();

      expect(find.byType(Text), findsNothing);
      expect(find.byType(DeviceTypesList), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    },
  );

  testWidgets(
    'Device types list can contain devices',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleWrapper(
          child: DeviceTypesList(
            [
              DeviceTypeWithDevices(
                1,
                'device 1',
                [],
              ),
              DeviceTypeWithDevices(
                2,
                'device 2',
                [],
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Text), findsNWidgets(2));
      expect(find.byType(StateMarker), findsNWidgets(2));
      expect(find.byType(DeviceTypesList), findsOneWidget);
    },
  );

  group('Each device type should create row related to the device', () {
    testWidgets(
      'Cold storage',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  1,
                  'Cold Storage',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();
        await tester.tap(find.text('Cold Storage'));
        await tester.pump();

        expect(find.byType(FDExpansionTile), findsOneWidget);
        expect(find.byType(ColdStorageRow), findsOneWidget);
        expect(find.byType(DeviceTypesList), findsOneWidget);
        expect(find.text('Cold Storage'), findsOneWidget);
      },
    );

    testWidgets(
      'Hot holding',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  2,
                  'Hot holding',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();
        await tester.tap(find.text('Hot holding'));
        await tester.pump();

        expect(find.byType(FDExpansionTile), findsOneWidget);
        expect(find.byType(HotHolding), findsOneWidget);
        expect(find.byType(DeviceTypesList), findsOneWidget);
        expect(find.text('Hot holding'), findsOneWidget);
      },
    );

    testWidgets(
      'Complaints',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  3,
                  'Complaints',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(MeasurementCreationLinkTile), findsOneWidget);
        expect(find.byType(DeviceTypesList), findsOneWidget);
        expect(find.text('Complaints'), findsOneWidget);
      },
    );

    testWidgets(
      'Company supplier (Delivery control)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  4,
                  'Company supplier (Delivery control)',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(MeasurementCreationLinkTile), findsOneWidget);
        expect(find.byType(DeviceTypesList), findsOneWidget);
        expect(
            find.text('Company supplier (Delivery control)'), findsOneWidget);
      },
    );

    testWidgets(
      'Traceability',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  5,
                  'Traceability',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(MeasurementCreationLinkTile), findsOneWidget);
        expect(find.byType(DeviceTypesList), findsOneWidget);
        expect(find.text('Traceability'), findsOneWidget);
      },
    );

    testWidgets(
      'Shelf traceability',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  6,
                  'Shelf traceability',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(MeasurementCreationLinkTile), findsOneWidget);
        expect(find.byType(DeviceTypesList), findsOneWidget);
        expect(find.text('Shelf traceability'), findsOneWidget);
      },
    );

    testWidgets(
      'Other -> Should not be rendered',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  7,
                  'Other',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(MeasurementCreationLinkTile), findsOneWidget);
        expect(find.byType(DeviceTypesList), findsOneWidget);
        expect(find.text('Other'), findsOneWidget);
      },
    );

    testWidgets(
      'Pest control',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  8,
                  'Pest control',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(DevicesListRedirectTile), findsOneWidget);
        expect(find.byType(DeviceTypesList), findsOneWidget);
        expect(find.text('Pest control'), findsOneWidget);
      },
    );

    testWidgets(
      'Cleaning and disinfection',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  9,
                  'Cleaning and disinfection',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(DevicesListRedirectTile), findsOneWidget);
        expect(find.byType(DeviceTypesList), findsOneWidget);
        expect(find.text('Cleaning and disinfection'), findsOneWidget);
      },
    );

    testWidgets(
      'Analyses',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  10,
                  'Analyses',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(DevicesListRedirectTile), findsOneWidget);
        expect(find.byType(DeviceTypesList), findsOneWidget);
        expect(find.text('Analyses'), findsOneWidget);
      },
    );

    testWidgets(
      'Calibration',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  11,
                  'Calibration',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(DevicesListRedirectTile), findsOneWidget);
        expect(find.byType(DeviceTypesList), findsOneWidget);
        expect(find.text('Calibration'), findsOneWidget);
      },
    );

    testWidgets(
      'Maintenance',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  12,
                  'Maintenance',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(DevicesListRedirectTile), findsOneWidget);
        expect(find.byType(DeviceTypesList), findsOneWidget);
        expect(find.text('Maintenance'), findsOneWidget);
      },
    );

    testWidgets(
      'Tasks',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  13,
                  'Tasks',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(DevicesListRedirectTile), findsOneWidget);
        expect(find.byType(DeviceTypesList), findsOneWidget);
        expect(find.text('Tasks'), findsOneWidget);
      },
    );

    testWidgets(
      'Supervisory',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  14,
                  'Supervisory',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(DevicesListRedirectTile), findsOneWidget);
        expect(find.byType(DeviceTypesList), findsOneWidget);
        expect(find.text('Supervisory'), findsOneWidget);
      },
    );

    testWidgets(
      'Some other device type shold throw an error',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LocaleWrapper(
            child: DeviceTypesList(
              [
                DeviceTypeWithDevices(
                  15,
                  '',
                  [],
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(tester.takeException(), isException);
      },
    );
  });
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/device.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/screens/measurement_creation/device_types/custom_folder.dart';
import 'package:fooddocs_flutter_app/widgets/file_picker.dart';
import '../../../../../test_helpers/wrappers/locale_wrapper.dart';

void main() {
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/image_picker');

  List<String> log = [];

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall.method);

      switch (methodCall.method) {
        case 'pickImage':
          File file = new File('test_resources/food_picture.jpg');

          return file.path;
        default:
          return null;
      }
    });
  });

  testWidgets('User can\'t change name without selected file',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      LocaleWrapper(
        child: CustomFolderForm(
          Device(
            name: 'custom device name',
            deviceTypeId: 7,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(TextFormField), findsOneWidget);
    expect(tester.widget<TextFormField>(find.byType(TextFormField)).enabled,
        isFalse);
  });

  testWidgets('User should be able to add image or file',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      LocaleWrapper(
        child: CustomFolderForm(
          Device(
            name: 'custom device name',
            deviceTypeId: 7,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(FileOrImagePicker), findsOneWidget);

    await tester.tap(find.text('Add picture'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    expect(log.contains('pickImage'), isTrue);
//    expectLater(find.byType(Image), findsOneWidget);

//    expect(tester.widget<TextFormField>(find.byType(TextFormField)).enabled,
//        isTrue);
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}

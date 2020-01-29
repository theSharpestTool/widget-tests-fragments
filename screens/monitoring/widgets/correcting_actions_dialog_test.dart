import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/models/correcting_action.dart';
import 'package:fooddocs_flutter_app/models/device.dart';
import 'package:fooddocs_flutter_app/models/storage.dart';
import 'package:fooddocs_flutter_app/screens/monitoring/widgets/correcting_actions_dialog.dart';
import 'package:fooddocs_flutter_app/services/correcting-actions.service.dart';
import 'package:fooddocs_flutter_app/services/storages.service.dart';

import '../../../test_helpers/wrappers/locale_wrapper.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  ///For Cold Storage Device
  testWidgets("Cold Storage Correcting Actions Dialog",
      (WidgetTester tester) async {
    await binding.setSurfaceSize(Size(900, 1800));
    StoragesService.instance.assignTestStorages(getTestStorageList());
    CorrectingActionsService.instance
        .assignTestActions(getCorrectingActionList());

    var device = getDevices()
        .firstWhere((device) => device.deviceType == DeviceTypes.COLD_STORAGE);
    await beginCorrActionsDialogTests(tester, device);
    addTearDown(() => binding.setSurfaceSize(null));
  });

  ///For Food Core Temperatures (Hot Holding Devices)
  testWidgets("Food Core Correcting Actions Dialog",
      (WidgetTester tester) async {
    await binding.setSurfaceSize(Size(900, 1800));
    StoragesService.instance.assignTestStorages(getTestStorageList());
    CorrectingActionsService.instance
        .assignTestActions(getCorrectingActionList());

    var device = getDevices()
        .firstWhere((device) => device.deviceType == DeviceTypes.HOT_HOLDING);
    await beginCorrActionsDialogTests(tester, device);
    addTearDown(() => binding.setSurfaceSize(null));
  });
}

Future beginCorrActionsDialogTests(WidgetTester tester, Device device) async {
  List<CorrectingAction> selectedCorrectingActions;
  await tester.pumpWidget(LocaleWrapper(
    child: CorrectingActionsDialog(device,
        onSubmit: (List<CorrectingAction> correctingActions) {
      //Assigns value after the Done button has been clicked.
      selectedCorrectingActions = correctingActions;
    }),
  ));
  await tester.pumpAndSettle();
  //Test for AlertDialog presence
  expect(find.byType(AlertDialog), findsOneWidget);
  //Test for matching the Title
  expect(
      find.text(
          "The value you entered is different from the set norm Can you tell us what may happened"),
      findsOneWidget);

  final storage = await StoragesService.instance.getById(device.storageId);

  //Test for matching device limits. For cold storage, the upper and lower limits
  //are a string with storage.
  expect(
      find.text(storage.name), findsOneWidget); //Upper and lower limit
  if (storage.name != null || storage.name.isNotEmpty) {
    //Check for Lower Limit.
    int lowerLimitFound =
        storage.name.indexOf(storage.lowerLimit.toString());
    expect(lowerLimitFound, isNot("-1"));
    //Check for Upper Limit only if COLD STORAGE device type.
    if (device.deviceType == DeviceTypes.COLD_STORAGE) {
      int upperLimitFound =
          storage.name.indexOf(storage.upperLimit.toString());
      expect(upperLimitFound, isNot("-1"));
    }
  }

  final actions = await CorrectingActionsService.instance.correctingActionsForDeviceType(device.deviceTypeId);

  //Test for Tapping multiple checklist items.
  await Future.forEach(actions, (correctionAction) async {
    await tester
        .tap(find.byKey(Key('correcting_actions_${correctionAction.id}')));
  });

  //user can input custom value
  await tester.enterText(
      find.byKey(Key('custom_text_field')), 'custom value 1');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  expect(find.text('custom value 1'), findsOneWidget);
  await tester.enterText(
      find.byKey(Key('custom_text_field')), 'custom value 1');

  //Tap "Done" button and test whether it receives all corrective actions.
  await tester.tap(find.byType(RaisedButton));
  expect(selectedCorrectingActions.length,
      equals(actions.length + 2));
}

List<Device> getDevices() {
  //NOTE: Update all strings with actual responses if Tests are failing.
  String devicesResponse =
      '[{\"id\":371,\"name\":\"Default\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_a_week\"},\"storage_id\":3,\"device_type_id\":3,\"order\":62,\"updated_at\":\"2019-11-13 16:27:31\",\"on_paper\":false,\"device_settings\":null,\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":true,\"files\":[]},{\"id\":372,\"name\":\"Default\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_a_week\"},\"storage_id\":3,\"device_type_id\":3,\"order\":63,\"updated_at\":\"2019-04-15 20:58:37\",\"on_paper\":true,\"device_settings\":null,\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":true,\"files\":[]},{\"id\":373,\"name\":\"Default\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_a_week\"},\"storage_id\":3,\"device_type_id\":3,\"order\":64,\"updated_at\":\"2019-04-15 20:58:40\",\"on_paper\":true,\"device_settings\":null,\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":true,\"files\":[]},{\"id\":375,\"name\":\"Liha m\u00f5\u00f5tmine\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"twice_a_day\"},\"storage_id\":7,\"device_type_id\":2,\"order\":66,\"updated_at\":\"2019-11-28 06:50:30\",\"on_paper\":false,\"device_settings\":null,\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":false,\"is_schedule_done\":true,\"files\":[]},{\"id\":376,\"name\":\"Default\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_a_week\"},\"storage_id\":4,\"device_type_id\":4,\"order\":67,\"updated_at\":\"2019-04-15 21:00:33\",\"on_paper\":false,\"device_settings\":null,\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":true,\"files\":[]},{\"id\":6054,\"name\":\"Fridge 2\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_a_day\"},\"storage_id\":4,\"device_type_id\":1,\"order\":2506,\"updated_at\":\"2019-11-26 16:24:44\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"lower_limit\":null,\"upper_limit\":null,\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":false,\"is_schedule_done\":false,\"files\":[]},{\"id\":6404,\"name\":\"Fridge 1\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"twice_a_day\"},\"storage_id\":4,\"device_type_id\":1,\"order\":2541,\"updated_at\":\"2019-11-26 13:29:32\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"lower_limit\":null,\"upper_limit\":null,\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":false,\"is_schedule_done\":false,\"files\":[]},{\"id\":6454,\"name\":\"Fridge 3\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"twice_a_day\"},\"storage_id\":5,\"device_type_id\":1,\"order\":2543,\"updated_at\":\"2019-11-26 13:29:39\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"lower_limit\":null,\"upper_limit\":null,\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":false,\"is_schedule_done\":false,\"files\":[]},{\"id\":6455,\"name\":\"Fridge 4\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"twice_a_day\"},\"storage_id\":5,\"device_type_id\":1,\"order\":2544,\"updated_at\":\"2019-11-26 13:29:48\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"lower_limit\":null,\"upper_limit\":null,\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":false,\"is_schedule_done\":false,\"files\":[]},{\"id\":7339,\"name\":\"Default\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_a_week\"},\"storage_id\":6,\"device_type_id\":6,\"order\":2592,\"updated_at\":\"2019-11-28 07:19:59\",\"on_paper\":false,\"device_settings\":{\"lower_limit\":null,\"upper_limit\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":true,\"files\":[]},{\"id\":7384,\"name\":\"Default\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_a_week\"},\"storage_id\":5,\"device_type_id\":5,\"order\":2595,\"updated_at\":\"2019-11-28 07:20:43\",\"on_paper\":false,\"device_settings\":{\"lower_limit\":null,\"upper_limit\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":true,\"files\":[]},{\"id\":7928,\"name\":\"Fridge 5\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_a_day\"},\"storage_id\":4,\"device_type_id\":1,\"order\":2660,\"updated_at\":\"2019-11-26 13:29:52\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"lower_limit\":null,\"upper_limit\":null,\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":false,\"is_schedule_done\":false,\"files\":[]},{\"id\":7931,\"name\":\"One\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_in_2_months\"},\"storage_id\":null,\"device_type_id\":8,\"order\":2663,\"updated_at\":\"2019-11-26 12:49:29\",\"on_paper\":null,\"device_settings\":{\"entry_type\":\"digital\",\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":true,\"files\":[]},{\"id\":8111,\"name\":\"Fridge 6\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"twice_a_day\"},\"storage_id\":5,\"device_type_id\":1,\"order\":2682,\"updated_at\":\"2019-11-26 13:29:58\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"lower_limit\":null,\"upper_limit\":null,\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":false,\"is_schedule_done\":false,\"files\":[]},{\"id\":8148,\"name\":\"F7\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_a_week\"},\"storage_id\":5,\"device_type_id\":1,\"order\":2697,\"updated_at\":\"2019-11-26 13:30:02\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"lower_limit\":null,\"upper_limit\":null,\"custom_frequency\":[{\"to\":\"23:59\",\"day\":\"Sunday\",\"from\":\"00:00\"}],\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":true,\"files\":[]},{\"id\":8585,\"name\":\"Two\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_in_month\"},\"storage_id\":null,\"device_type_id\":8,\"order\":2713,\"updated_at\":\"2019-11-28 07:38:22\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":true,\"files\":[]},{\"id\":9067,\"name\":\"Cleaning\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"twice_a_day\"},\"storage_id\":null,\"device_type_id\":9,\"order\":2741,\"updated_at\":\"2019-11-26 13:10:29\",\"on_paper\":null,\"device_settings\":{\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":false,\"files\":[]},{\"id\":9068,\"name\":\"Taking trash out\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_a_day\"},\"storage_id\":null,\"device_type_id\":9,\"order\":2742,\"updated_at\":\"2019-11-28 07:28:45\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":false,\"is_schedule_done\":true,\"files\":[]},{\"id\":9069,\"name\":\"Mopping\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"twice_a_day\"},\"storage_id\":null,\"device_type_id\":9,\"order\":2743,\"updated_at\":\"2019-11-26 13:22:23\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":false,\"files\":[]},{\"id\":9070,\"name\":\"THis is an exceptionally long long long long long long long long long longlong long long longlong long long longlong long long longlong long long long tasks.\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_a_day\"},\"storage_id\":null,\"device_type_id\":9,\"order\":2744,\"updated_at\":\"2019-11-26 14:24:30\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":false,\"files\":[]},{\"id\":9117,\"name\":\"Five\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_in_month\"},\"storage_id\":null,\"device_type_id\":8,\"order\":2752,\"updated_at\":\"2019-11-28 08:26:50\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":true,\"files\":[]},{\"id\":9210,\"name\":\"Test 1\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_a_day\"},\"storage_id\":8,\"device_type_id\":2,\"order\":2761,\"updated_at\":\"2019-11-27 13:23:35\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"lower_limit\":null,\"upper_limit\":null,\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":false,\"files\":[]},{\"id\":9211,\"name\":\"Test 2\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_a_day\"},\"storage_id\":8,\"device_type_id\":2,\"order\":2762,\"updated_at\":\"2019-11-27 13:23:52\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"lower_limit\":null,\"upper_limit\":null,\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":false,\"files\":[]},{\"id\":9212,\"name\":\"Test 3\",\"measurement_schedule\":{\"type\":\"fixed\",\"schedule\":\"once_a_day\"},\"storage_id\":8,\"device_type_id\":2,\"order\":2763,\"updated_at\":\"2019-11-27 13:37:18\",\"on_paper\":false,\"device_settings\":{\"entry_type\":\"digital\",\"lower_limit\":null,\"upper_limit\":null,\"custom_frequency\":null,\"additional_information\":null},\"sensor_id\":null,\"provider_email\":null,\"provider_email_sent_at\":null,\"is_done\":true,\"is_schedule_done\":false,\"files\":[]}]';
  var devices = (json.decode(devicesResponse) as List)
      .map((item) => Device.fromJson(item))
      .toList();
  return devices;
}

List<CorrectingAction> getCorrectingActionList() {
  //NOTE: Update all strings with actual responses if Tests are failing.
  String correctionActionResponse =
      '[{"id":1,"device_type_id":1,"slug":"Door was open, closed it, re-check after 1 hour"},{"id":4,"device_type_id":2,"slug":"Food was re-heated up to +75C during 2 minutes"},{"id":5,"device_type_id":2,"slug":"Food was thrown away"},{"id":6,"device_type_id":3,"slug":"Food removed from the sale and marked as hazardous food"},{"id":7,"device_type_id":3,"slug":"Local VTA was informed"},{"id":8,"device_type_id":3,"slug":"Microbiological tests were made"},{"id":9,"device_type_id":3,"slug":"Consumers were notified via media"},{"id":10,"device_type_id":2,"slug":"Re-processed food"},{"id":11,"device_type_id":2,"slug":"Chilled food down and sold in the showcase"},{"id":17,"device_type_id":4,"slug":"Supplier was notified"},{"id":18,"device_type_id":4,"slug":"Food was rejected"},{"id":21,"device_type_id":3,"slug":"Receipt was modified"},{"id":22,"device_type_id":3,"slug":"Informed supplier"},{"id":23,"device_type_id":3,"slug":"Checked all batch"},{"id":24,"device_type_id":1,"slug":"Equipment is broken"},{"id":25,"device_type_id":1,"slug":"Called to maintenance"},{"id":26,"device_type_id":1,"slug":"Food was re-stored"},{"id":27,"device_type_id":1,"slug":"Food was thrown away"},{"id":28,"device_type_id":1,"slug":"Equipment turned off"},{"id":30,"device_type_id":4,"slug":"Manager was notified"},{"id":31,"device_type_id":4,"slug":"Returned goods"},{"id":32,"device_type_id":4,"slug":"Receipt was modified"},{"id":33,"device_type_id":4,"slug":"Food was reprocessed"},{"id":34,"device_type_id":4,"slug":"Employees were trained"},{"id":35,"device_type_id":4,"slug":"Guidance was modified"}]';
  var actions = (json.decode(correctionActionResponse) as List)
      .map((item) => CorrectingAction.fromJson(item))
      .toList();
  return actions;
}

List<Storage> getTestStorageList() {
  //NOTE: Update all strings with actual responses if Tests are failing.
  String storageResponse =
      '[{\"id\":1,\"name\":\"not more than -18\u00b0C\",\"created_at\":\"2018-09-25 17:20:00\",\"updated_at\":\"2019-01-15 17:39:32\",\"lower_limit\":null,\"upper_limit\":-18,\"device_type_id\":1},{\"id\":2,\"name\":\"0 to +2\u00b0C\",\"created_at\":\"2018-09-25 17:20:00\",\"updated_at\":\"2019-01-15 17:39:32\",\"lower_limit\":0,\"upper_limit\":2,\"device_type_id\":null},{\"id\":3,\"name\":\"0 to +4\u00b0C\",\"created_at\":\"2018-09-25 17:20:00\",\"updated_at\":\"2019-01-15 17:39:32\",\"lower_limit\":0,\"upper_limit\":4,\"device_type_id\":null},{\"id\":4,\"name\":\"+2 to +6\u00b0C\",\"created_at\":\"2018-09-25 17:20:00\",\"updated_at\":\"2019-01-15 17:39:32\",\"lower_limit\":2,\"upper_limit\":6,\"device_type_id\":1},{\"id\":5,\"name\":\"+2 to +8\u00b0C\",\"created_at\":\"2018-09-25 17:20:00\",\"updated_at\":\"2019-01-15 17:39:32\",\"lower_limit\":2,\"upper_limit\":8,\"device_type_id\":1},{\"id\":6,\"name\":\"room temperature\",\"created_at\":\"2018-09-25 17:20:00\",\"updated_at\":\"2019-01-15 17:39:32\",\"lower_limit\":20,\"upper_limit\":25,\"device_type_id\":null},{\"id\":7,\"name\":\"above +63\u00b0C\",\"created_at\":\"2018-09-25 17:20:00\",\"updated_at\":\"2019-01-15 17:39:32\",\"lower_limit\":63,\"upper_limit\":null,\"device_type_id\":2},{\"id\":8,\"name\":\"above +75\u00b0C\",\"created_at\":\"2018-11-30 00:00:00\",\"updated_at\":\"2019-01-15 17:39:32\",\"lower_limit\":75,\"upper_limit\":null,\"device_type_id\":2},{\"id\":12,\"name\":\"10\u00b0C to 18\u00b0C\",\"created_at\":null,\"updated_at\":null,\"lower_limit\":10,\"upper_limit\":18,\"device_type_id\":null}]';
  List<Storage> storages = (json.decode(storageResponse) as List)
      .map((item) => Storage.fromJson(item))
      .toList();
  return storages;
}

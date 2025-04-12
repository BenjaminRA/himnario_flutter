import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  String path = Platform.environment['SCREENSHOT_PATH']!;
  String platform = Platform.environment['PLATFORM'] ?? '';
  assert(platform == 'android' || platform == 'ios');
  bool isAndroid = platform.toLowerCase().trim() == 'android';

  String device = Platform.environment['DEVICE_NAME'] ?? '';
  assert(isAndroid || device != '');

  // Deleting current screenshots
  try {
    for (final dir in Directory(path).listSync()) {
      if (isAndroid) {
        await dir.delete();
      }
    }
  } catch (e) {}

  try {
    if (isAndroid) {
      await Process.run(
        'adb',
        [
          'shell',
          'pm',
          'grant',
          'com.printto.printtoapp',
          'android.permission.WRITE_EXTERNAL_STORAGE',
          'android.permission.READ_EXTERNAL_STORAGE',
        ],
      );
    }

    await integrationDriver(
        // onScreenshot: (String screenshotName, List<int> screenshotBytes) async {
        //   // if devices is not empty, add the underscore
        //   device = device == '' || device.endsWith('_') ? device : '${device.toUpperCase()}_';

        //   final File image = await File(
        //     path + '/$device$screenshotName.png',
        //   ).create(recursive: true);
        //   if (image.existsSync()) {
        //     image.deleteSync();
        //   }
        //   image.writeAsBytesSync(screenshotBytes);
        //   return true;
        // },
        );
  } catch (e) {
    print('Error occurred: $e');
  }
}

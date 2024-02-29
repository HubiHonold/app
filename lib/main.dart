import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humhub/opener_app.dart';
import 'package:humhub/util/log.dart';
import 'package:humhub/util/universal_opener_controller.dart';
import 'package:loggy/loggy.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'flavored_app.dart';
import 'models/hum_hub.dart';

main() async {
  Loggy.initLoggy(
    logPrinter: const GlobalLog(),
  );

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) async {
      logDebug("Package Name: ${packageInfo.packageName}");
      switch (packageInfo.packageName) {
        case "com.humhub.app":
          logDebug("Package Name: ${packageInfo.packageName}");
          runApp(const ProviderScope(child: OpenerApp()));
          break;
        default:
          UniversalOpenerController opener = UniversalOpenerController(url: 'https://sometestproject12345.humhub.com/manifest.json');
          HumHub? instance = await opener.initHumHub();
          logDebug("Package Name: ${packageInfo.packageName}");
          runApp(ProviderScope(child: FlavoredApp(instance: instance!)));
          break;
      }
    });
  });
}

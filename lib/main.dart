import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humhub/opener_app.dart';
import 'package:humhub/util/log.dart';
import 'package:loggy/loggy.dart';
import 'package:package_info_plus/package_info_plus.dart';

main() async {
  Loggy.initLoggy(
    logPrinter: const GlobalLog(),
  );

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      logDebug("Package Name: ${packageInfo.packageName}");
      switch (packageInfo.packageName) {
        case "com.humhub.app":
          logDebug("Package Name: ${packageInfo.packageName}");
          runApp(const ProviderScope(child: OpenerApp()));
          break;
        default:
          logDebug("Package Name: ${packageInfo.packageName}");
          runApp(const ProviderScope(child: OpenerApp()));
      }
    });
  });
}

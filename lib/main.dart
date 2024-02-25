import 'package:flavor_getter/flavor_getter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humhub/opener_app.dart';
import 'package:humhub/util/log.dart';
import 'package:loggy/loggy.dart';

main() async {
  Loggy.initLoggy(
    logPrinter: const GlobalLog(),
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    FlavorGetter().getFlavor().then((value) {
      runApp(const ProviderScope(child: MyApp()));
    });
  });
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: FlavorGetter().getFlavor(),
      builder: (context, snap) {
        logDebug('Flavor: ${snap.data}');
        if (snap.connectionState == ConnectionState.done) {
          return snap.hasData && snap.data != null ? Container() : const OpenerApp();
        }
        return const SizedBox.shrink();
      },
    );
  }
}

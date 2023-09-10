import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humhub/models/event.dart';
import 'package:humhub/util/notifications/channel.dart';
import 'package:humhub/util/notifications/plugin.dart';
import 'package:humhub/util/notifications/service.dart';
import 'package:humhub/util/push/register_token_plugin.dart';
import 'package:humhub/util/providers.dart';
import 'package:loggy/loggy.dart';

class PushPlugin extends ConsumerStatefulWidget {
  final Widget child;

  const PushPlugin({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  PushPluginState createState() => PushPluginState();
}

class PushPluginState extends ConsumerState<PushPlugin> {
  Future<void> _init() async {
    logDebug("Init PushPlugin");
    final token = await FirebaseMessaging.instance.getToken();
    logDebug('PushPluginState getInitialMessage ${await FirebaseMessaging.instance.getInitialMessage()}');
    if (token != null) logDebug('PushPlugin with token: $token');
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logDebug("OnMessage PushPlugin");
      _handleNotification(
        message,
        NotificationPlugin.of(ref),
      );
      _handleData(message, context, ref);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logDebug("onMessageOpenedApp PushPlugin");
      _handleNotification(
        message,
        NotificationPlugin.of(ref),
      );
      _handleData(message, context, ref);
    });

    //When the app is terminated, i.e., app is neither in foreground or background.
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      logDebug("getInitialMessage PushPlugin: $message");
      if (message != null) {
        _handleNotification(
          message,
          NotificationPlugin.of(ref),
        );
        _handleData(message, context, ref);
      }
    });

    ref.read(firebaseInitialized.notifier).state = const AsyncValue.data(true);

    /// We do this to create provider and read Firebase token
    ref.read(pushTokenProvider);
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RegisterToken(
      child: widget.child,
    );
  }
}

/// Read payload of message and figure out what you wish to do
/// Right now we display notification but we could do anything
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  logDebug("_onBackgroundMessage PushPlugin");
  final service = await NotificationService.create();

  await _handleNotification(message, service);
}

Future<void> _handleNotification(RemoteMessage message, NotificationService notificationService) async {
  FirebaseMessaging.instance.getInitialMessage();
  final data = PushEvent(message).parsedData;
  if (message.notification == null) return;
  final title = message.notification?.title;
  final body = message.notification?.body;
  if (title == null || body == null) return;

  NotificationChannel channel;

  if (NotificationChannel.canAcceptTap(data.channel)) {
    channel = NotificationChannel.fromId(data.channel);
  } else {
    channel = GeneralNotificationChannel();
  }
  int count = 0;
  try {
    count = int.parse(data.notificationCount!);
  } catch (e) {
    logError(e);
  }
  // Set icon badge count if notificationCount exist in push.
  if (data.notificationCount != null) FlutterAppBadger.updateBadgeCount(count);

  logDebug("notificationService.showNotification name: PushPlugin");
  await notificationService.showNotification(
    channel,
    title,
    body,
    payload: data.channelPayload,
    redirectUrl: data.redirectUrl,
  );
}

Future<void> _handleData(RemoteMessage message, BuildContext context, WidgetRef ref) async {
  // Here we handle the data that we get form an push notification.
}

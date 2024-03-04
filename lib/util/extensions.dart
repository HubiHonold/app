import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humhub/models/manifest.dart';
import 'package:humhub/pages/opener.dart';
import 'package:humhub/util/const.dart';
import 'package:humhub/util/providers.dart';
import 'package:loggy/loggy.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore_for_file: use_build_context_synchronously
extension MyCookies on WebViewCookieManager {
  Future<void> setMyCookies(Manifest manifest) async {
    await setCookie(
      WebViewCookie(
        name: 'is_mobile_app',
        value: 'true',
        domain: manifest.baseUrl,
      ),
    );
  }
}

extension MyWebViewController on InAppWebViewController {
  Future<bool> exitApp(BuildContext context, ref) async {
    bool canGoBack = await this.canGoBack();
    if (canGoBack) {
      goBack();
      return Future.value(false);
    } else {
      final exitConfirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to exit an App'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                closeOrOpenDialog(context, ref);
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      return exitConfirmed ?? false;
    }
  }

  closeOrOpenDialog(BuildContext context, WidgetRef ref) {
    var isHide = ref.read(humHubProvider).isHideDialog;
    isHide
        ? SystemNavigator.pop()
        : Navigator.of(context).pushNamedAndRemoveUntil(Opener.path, (Route<dynamic> route) => false);
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor";
      }
      return int.parse(hexColor, radix: 16);
    } catch (e) {
      logError("Color from manifest is not valid use primary color");
      return primaryColor.value;
    }
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

extension AsyncValueX<T> on AsyncValue<T> {
  bool get isLoading => asData == null;

  bool get isLoaded => asData != null;

  bool get isError => this is AsyncError;

  AsyncError get asError => this as AsyncError;

  T? get valueOrNull => asData?.value;
}

extension FutureAsyncValueX<T> on Future<AsyncValue<T>> {
  Future<T?> get valueOrNull => then(
        (asyncValue) => asyncValue.asData?.value,
      );
}

extension PrettyUri on Uri {
  bool isUriPretty() {
    RegExp regex = RegExp(r'index\.php.*[?&]r=');
    String path = Uri.decodeComponent(toString());
    return !regex.hasMatch(path);
  }
}

extension URLRequestExtension on URLRequest {
  URLRequest copyWith({
    Uri? url,
    String? method,
    Uint8List? body,
    Map<String, String>? headers,
    bool? iosAllowsCellularAccess,
    bool? iosAllowsConstrainedNetworkAccess,
    bool? iosAllowsExpensiveNetworkAccess,
    IOSURLRequestCachePolicy? iosCachePolicy,
    bool? iosHttpShouldHandleCookies,
    bool? iosHttpShouldUsePipelining,
    IOSURLRequestNetworkServiceType? iosNetworkServiceType,
    double? iosTimeoutInterval,
    Uri? iosMainDocumentURL,
  }) {
    return URLRequest(
      url: url ?? this.url,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      iosAllowsCellularAccess: iosAllowsCellularAccess ?? this.iosAllowsCellularAccess,
      iosAllowsConstrainedNetworkAccess: iosAllowsConstrainedNetworkAccess ?? this.iosAllowsConstrainedNetworkAccess,
      iosAllowsExpensiveNetworkAccess: iosAllowsExpensiveNetworkAccess ?? this.iosAllowsExpensiveNetworkAccess,
      iosCachePolicy: iosCachePolicy ?? this.iosCachePolicy,
      iosHttpShouldHandleCookies: iosHttpShouldHandleCookies ?? this.iosHttpShouldHandleCookies,
      iosHttpShouldUsePipelining: iosHttpShouldUsePipelining ?? this.iosHttpShouldUsePipelining,
      iosNetworkServiceType: iosNetworkServiceType ?? this.iosNetworkServiceType,
      iosTimeoutInterval: iosTimeoutInterval ?? this.iosTimeoutInterval,
      iosMainDocumentURL: iosMainDocumentURL ?? this.iosMainDocumentURL,
    );
  }
}

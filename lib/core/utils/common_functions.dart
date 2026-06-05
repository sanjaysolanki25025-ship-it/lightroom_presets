import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonFunction {
  static Future<void> launchUrlLink(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  static Future<void> openLightroomApp() async {
    await LaunchApp.openApp(androidPackageName: "com.adobe.lrmobile", openStore: true);
  }
}

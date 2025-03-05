
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WebUtil{

  static bool isMobileiBrowser() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('mobile') || userAgent.contains('android') || userAgent.contains('iphone') || userAgent.contains('ipad');
  }

  static copytext(BuildContext context, String str) async {
    Clipboard.setData(ClipboardData(text: str));
    showSnackbar(context,str);
  }

  static void showSnackbar(BuildContext context,String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


}
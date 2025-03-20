import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Util/JsonUtil.dart';

class WebUtil {
  static String city="";


  static bool isMobileiBrowser() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('mobile') ||
        userAgent.contains('android') ||
        userAgent.contains('iphone') ||
        userAgent.contains('ipad');
  }

  static copytext(BuildContext context, String str) async {
    Clipboard.setData(ClipboardData(text: str));
    showSnackbar(context, str);
  }

  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static String getBrowserName() {
    String userAgent = html.window.navigator.userAgent.toLowerCase();
    if (userAgent.contains("chrome") &&
        !userAgent.contains("edg") &&
        !userAgent.contains("opr")) {
      return "Chrome";
    } else if (userAgent.contains("safari") && !userAgent.contains("chrome")) {
      return "Safari";
    } else if (userAgent.contains("firefox")) {
      return "Firefox";
    } else if (userAgent.contains("edg")) {
      return "Edge";
    } else if (userAgent.contains("opr") || userAgent.contains("opera")) {
      return "Opera";
    } else {
      return "Unknown";
    }
  }

  static bool isChrome() {
    String bro = getBrowserName();
    if (bro == "Chrome") return true;
    return false;
  }

  static bool isSafari() {
    String bro = getBrowserName();
    if (bro == "Safari") return true;
    return false;
  }

  static String getSocialMediaPlatform() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();

    Map<String, String> socialMediaAgents = {
      'fbav': 'Facebook', // Facebook App
      'instagram': 'Instagram', // Instagram
      'twitter': 'Twitter', // Twitter
      'tiktok': 'TikTok', // TikTok
      'snapchat': 'Snapchat', // Snapchat
      'wechat': 'WeChat', // WeChat
      'whatsapp': 'WhatsApp', // WhatsApp
      'linkedin': 'LinkedIn', // LinkedIn
      'pinterest': 'Pinterest', // Pinterest
      'line': 'LINE', // LINE
      'telegram': 'Telegram' // Telegram
    };

    for (var entry in socialMediaAgents.entries) {
      if (userAgent.contains(entry.key)) {
        return entry.value;
      }
    }
    return "";
  }

  static Map<String, dynamic> getotheruserDataMap(String userid,Map sendmap,String command) {
    Map<String, dynamic> map = {};
    map.putIfAbsent("userid", () => userid);
    map.putIfAbsent("command", () => command);
    String data=JsonUtil.maptostr(sendmap);
    data=JsonUtil.setbase64(data);
    map.putIfAbsent("data", ()=>data);
    return map;
  }

  static bool isIOS() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    if (userAgent.contains("iphone") ||
        userAgent.contains("ipad") ||
        userAgent.contains("ipod")) {
      return true;
    } else if (userAgent.contains("android")) {
      return false;
    }
    return false;
  }

  static bool isAndroid() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    if (userAgent.contains("iphone") ||
        userAgent.contains("ipad") ||
        userAgent.contains("ipod")) {
      return false;
    } else if (userAgent.contains("android")) {
      return true;
    }
    return false;
  }
}

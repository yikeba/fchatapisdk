import 'dart:html' as html;
import 'dart:convert';

import 'package:fchatapi/Util/JsonUtil.dart';
import 'package:fchatapi/util/DateUtil.dart';
import 'package:fchatapi/webapi/FileObj.dart';

import '../Util/PhoneUtil.dart';
import '../webapi/WebUtil.dart';

class DeviceInfo {
  final String userAgent;
  final String language;
  final String browser;
  final String platform;
  final String accessTime;

  DeviceInfo({
    required this.userAgent,
    required this.language,
    required this.browser,
    required this.platform,
    required this.accessTime,
  });

  factory DeviceInfo.detect() {
    final userAgent = html.window.navigator.userAgent;
    final language = html.window.navigator.language;
    final browser = _detectBrowser(userAgent);
    final platform = _detectPlatform(userAgent);
    final accessTime = DateTime.now().toIso8601String();

    return DeviceInfo(
      userAgent: userAgent,
      language: language,
      browser: browser,
      platform: platform,
      accessTime: accessTime,
    );
  }

  static String _detectBrowser(String userAgent) {
    if (userAgent.contains("Chrome")) {
      return "Chrome";
    } else if (userAgent.contains("Firefox")) {
      return "Firefox";
    } else if (userAgent.contains("Safari") && !userAgent.contains("Chrome")) {
      return "Safari";
    } else if (userAgent.contains("Edge")) {
      return "Edge";
    } else if (userAgent.contains("Opera") || userAgent.contains("OPR")) {
      return "Opera";
    } else {
      return "Unknown";
    }
  }

  static String _detectPlatform(String userAgent) {
    if (userAgent.contains("Windows")) {
      return "Windows";
    } else if (userAgent.contains("Mac OS")) {
      return "Mac";
    } else if (userAgent.contains("Android")) {
      return "Android";
    } else if (userAgent.contains("iPhone") || userAgent.contains("iPad")) {
      return "iOS";
    } else {
      return "Unknown";
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'userAgent': userAgent,
      'language': language,
      'browser': browser,
      'platform': platform,
      'accessTime': accessTime,
    };
  }

  static bool isMac() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('macintosh') || userAgent.contains('mac os x');
  }

  static bool isIos() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('iphone') || userAgent.contains('ipad') || userAgent.contains('ipod');
  }

  static bool isWindows() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('windows');
  }

  static bool isAndroid() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('android');
  }


  @override
  String toString() => jsonEncode(toJson());
}


class ClientObj{
  //使用客户端对象
  String recStr="";
  Map _map={};
  FileMD md;
  int timestamp=0;
  ClientObj(this.recStr,this.md){
    _initClient();
  }
  _initClient(){
    timestamp=DateUtil.getUTCint();
    _map=DeviceInfo.detect().toJson();  //读取设备，语言，设备
    _map.putIfAbsent("city", ()=>  WebUtil.city);
    _map.putIfAbsent("rec", ()=> recStr);
    _map.putIfAbsent("time", ()=> timestamp);
  }

  @override
  toString(){
    return JsonUtil.maptostr(_map);
  }

  unlaod(){
    FileObj  file=FileObj();
    file.filemd=md;
    file.writeData(toString(), timestamp.toString(), (value){
         PhoneUtil.applog("完成客户端记录$value");
    });
  }



}

import 'dart:html' as html;

import '../../util/PhoneUtil.dart';

class CookieStorage {


  static void saveToCookie(String name, String value) {
    html.window.localStorage[name] = value;
  }

  static String? getCookie(String name) {
    return html.window.localStorage[name];
  }


  /// **删除 Cookie**
  static void deleteCookie(String name) {
    html.document.cookie = "$name=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/";
  }
}

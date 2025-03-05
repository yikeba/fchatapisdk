
import 'dart:html' as html;

import '../../util/PhoneUtil.dart';

class CookieStorage {


  static void saveToCookie(String name, String value) {
    html.window.localStorage[name] = value;
  }

  static String? getCookie(String name) {
    return html.window.localStorage[name];
  }


  static void deleteFromStorage(String name) {
    html.window.localStorage.remove(name);
  }
}

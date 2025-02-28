
import 'dart:html' as html;
import 'dart:js' as js;

class WebUtil{

  static bool isMobileiBrowser() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('mobile') || userAgent.contains('android') || userAgent.contains('iphone') || userAgent.contains('ipad');
  }
}
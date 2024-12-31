import 'dart:html' as html;
import 'dart:js' as js;
import '../util/PhoneUtil.dart';

class BaseJS{

  static void fchatapiinit() {
    const scriptContent = '''
    function sendMessageToFlutterApp(message) {
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler("FChatAPI", message).then((response) => {
          flutterAppResponseHandler(response)
        });
      } else {
        console.error("flutter_inappwebview is not available!");
      }
    }

    function flutterAppResponseHandler(response) {
      window.postMessage({
        type: "flutterResponse",
        data: response,
      }, "*");
    }
  ''';

    // 查找 index.html 中的动态脚本容器
    final scriptElement = html.document.getElementById("dynamic-script") as html.ScriptElement;

    if (scriptElement != null) {
      scriptElement.text = scriptContent; // 将 JavaScript 内容写入脚本元素
      print("JavaScript injected successfully.");
    } else {
      print("Failed to inject JavaScript: Dynamic script container not found.");
    }
    apiRecdatainit();
  }

  static apiRecdatainit(){
    // 监听来自 Flutter App 的消息
    html.window.onMessage.listen((event) {
      final message = event.data;
      PhoneUtil.applog("Received message from FCapp数据: ${message["data"]}");
    });
  }

  static Future<void> sendtoFChat(String json) async {
    await js.context.callMethod("sendtoFChat", [json]);
  }





}








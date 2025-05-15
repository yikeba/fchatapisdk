import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import '../util/PhoneUtil.dart';

class BaseJS{
  static StreamController<String> _fchatstream = StreamController.broadcast();


  static apiRecdatainit(){
    // 监听来自 Flutter App 的消息
    html.window.onMessage.listen((event) {
      final message = event.data;
      try {
        _fchatstream.add(message["data"]);
      }catch(e){
        PhoneUtil.applog("Fchat api err $e, message$message");
      }

    });
  }

  static Future<void> sendtoFChat(String json,void Function(String recdata) fchatrec) async {
    await js.context.callMethod("sendtoFChat", [json]);
    _fchatstream.stream.listen((value){
        fchatrec(value);
    });
  }


}








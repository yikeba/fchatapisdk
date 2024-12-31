import 'package:fchatapi/appapi/BaseJS.dart';
import 'package:fchatapi/util/UserObj.dart';
import 'package:fchatapi/webapi/FileObj.dart';
import 'package:fchatapi/webapi/HttpWebApi.dart';
import 'dart:html' as html;
import 'dart:js' as js;

class FChatApiSdk {
  static FileObj fileobj = FileObj();
  static FileArrObj filearrobj=FileArrObj();

  static init(String userid, String token, void Function(bool state) webcall,
      void Function(bool state) appcall) {
    UserObj.token = token;
    UserObj.userid = userid;
    HttpWebApi.weblogin().then((value) {
      print("服务器验证返回$value");
      if (value.data == "loginok") {
        webcall(true);
      } else {
        webcall(false);
      }
    });
    BaseJS.apiRecdatainit();
    //服务器增加一个验证接口，初始化验证服务号是否上线，并判断采用url
    //进行登陆服务器，获取临时访问token 加入https 安全访问
  }

}

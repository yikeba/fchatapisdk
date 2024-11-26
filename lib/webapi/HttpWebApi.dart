import 'dart:async';
import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:fchatapi/util/Tools.dart';
import 'package:fchatapi/util/UserObj.dart';
import 'package:fchatapi/webapi/WebCommand.dart';
import 'package:flutter/foundation.dart';
import '../util/JsonUtil.dart';
import '../util/PhoneUtil.dart';
import '../util/SignUtil.dart';

class HttpWebApi {
  static Future<String> postServerForm(String url, Map<String, dynamic> post,
      {String? token} // 新增 token 参数
      ) async {
    try {
      // 如果提供了 token，则加入 Bearer Token 头
      String? authHeader;
      if (token != null) {
        authHeader = 'Bearer $token'; // 设置 Bearer Token
      }

      // 创建 Dio 请求
      Future<Response> dio = Dio().post(
        url,
        queryParameters: post,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          method: "POST",
          contentType: "application/x-www-form-urlencoded;charset=UTF-8",
          // 设置 Content-Type
          headers: authHeader != null
              ? {"Authorization": authHeader} // 如果有 Token，则添加 Authorization 头
              : {},
        ),
      );

      return dio.then((value) {
        if (value.statusCode == 200) {
          return value.data.toString();
        } else {
          PhoneUtil.applog("返回类型：${value.data}");
        }
        return "err";
      });
    } on DioError catch (e) {
      if (e.response?.statusCode == 404) {
        PhoneUtil.applog("404 url：$url");
      }
    }
    return "err";
  }

  static geturl() {
    if (kDebugMode) {
      return "https://www.freechat.cloud/sappbox";
    } else {
      return "https://www.freechat.cloud/sapp";
    }
  }

  static Map<String, dynamic> _logindata() {
    Map<String, dynamic> map = HashMap();
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.sapplogin);
    String data = Tools.generateRandomString(75);
    String basedata = JsonUtil.setbase64(data);
    map.putIfAbsent("data", () => basedata);
    String sign = SignUtil.getmd5Signtostr(basedata, UserObj.token);
    map.putIfAbsent("sign", () => sign);
    return map;
  }

  static Future<RecObj> weblogin() async {
    try {
      String url = geturl();
      //PhoneUtil.applog("访问url:$url");
      //String authHeader = 'Bearer ${UserObj.token}'; // 设置 Bearer Token
      String authHeader = 'Bearer ${WebCommand.sapplogin}'; // 设置 Bearer Token
      FormData senddata = FormData.fromMap(_logindata());
      Future<Response> dio = Dio().post(
        url,
        data:senddata,
        options: Options(
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            method: "POST",
            contentType: 'multipart/form-data',
            // 设置 Content-Type
            headers: {
              "Authorization": authHeader
            } // 如果有 Token，则添加 Authorization
            ),
      );
      return dio.then((value) {
        if (value.statusCode == 200) {
          RecObj robj=RecObj(value.data);
          PhoneUtil.applog("fchat web api 验证返回类型：${robj.toString()},返回code${robj.code}返回原始数据${value.data}");
         return robj;
        } else {
          PhoneUtil.applog("返回类型：${value.data}");
        }
        return RecObj("");
      });
    } on DioError catch (e) {
      if (e.response?.statusCode == 404) {
        PhoneUtil.applog("404 访问错误");
      }
    }
    return RecObj("");
  }

  static Map<String, dynamic> creatdata(String data) {
    Map<String, dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    String basedata = JsonUtil.setbase64(data);
    map.putIfAbsent("data", () => basedata);
    String sign = SignUtil.getmd5Signtostr(basedata, UserObj.token);
    map.putIfAbsent("sign", () => sign);
    return map;
  }

  static String creatuserdata(String command, Map dmap) {
    Map map = HashMap();
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.sapplogin);
    String data = JsonUtil.maptostr(dmap);
    String basedata = JsonUtil.setbase64(data);
    map.putIfAbsent("data", () => basedata);
    return JsonUtil.maptostr(map);
  }
}


class RecObj{
  int code=-1;
  Map json={};
  String data="";
  String rec;
  bool state=false;
  RecObj(this.rec){
    initjson();
  }

  initjson(){
    //解析服务器返回数据
    rec=JsonUtil.getbase64(rec);
    Map recservermap=JsonUtil.strtoMap(rec);
    if(recservermap.containsKey("code")){
      code=recservermap["code"];
    }
    if(code==200){
      if(recservermap.containsKey("token")){
        UserObj.servertoken=recservermap["token"];
      }
      state=true;
      data=recservermap["data"];
      json=JsonUtil.strtoMap(data);
    }else{
      data="err";
    }
  }

  @override
  String toString() {
    return data;
  }
}
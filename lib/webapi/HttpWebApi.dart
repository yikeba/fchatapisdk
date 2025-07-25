import 'dart:async';
import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:fchatapi/FChatApiSdk.dart';
import 'package:fchatapi/util/Tools.dart';
import 'package:fchatapi/util/UserObj.dart';
import 'package:fchatapi/webapi/LoginVerfiy.dart';
import 'package:fchatapi/webapi/WebCommand.dart';
import 'package:flutter/foundation.dart';
import '../util/JsonUtil.dart';
import '../util/PhoneUtil.dart';
import '../util/SignUtil.dart';
import 'package:universal_html/html.dart' as html;

import 'WebUtil.dart';

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
      //return "https://www.freechat.cloud/sappbox";
      //PhoneUtil.applog("开发模式登录验证");
     // return FChatApiSdk.debughost+"sappbox";
      String url="http://43.217.155.53:8080/sappbox";
      return url;
    } else {
      return "${FChatApiSdk.host}sapp";
    }
  }


  static String gethtmlurl() {
    if (kDebugMode) {
      return _getBaseUrl(html.window.location.href);
    } else {
      PhoneUtil.applog("返回url路径:${html.window.location.href}");
      return FChatApiSdk.host+"app/${UserObj.userid}/";
    }
  }

  static String _getBaseUrl(String fullUrl) {
    Uri uri = Uri.parse(fullUrl);
    String baseUrl = "${uri.scheme}://${uri.host}:${uri.port}";
    // 确保去掉 URL 末尾的 `/`
    return baseUrl.replaceAll(RegExp(r'/$'), '');
  }

  static Map<String, dynamic> logindata() {
    Map<String, dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.sapplogin);
    String data = Tools.generateRandomString(75);
    String basedata = JsonUtil.setbase64(data);
    map.putIfAbsent("data", () => basedata);
    String sign = SignUtil.getmd5Signtostr(basedata, UserObj.token);
    map.putIfAbsent("sign", () => sign);
    return map;
  }
 /* static weblogin() async {
    // Map map=await  _weblogin();
    // PhoneUtil.applog("申请向服务器认证，返回$map");
     bool islogin=await LoginVerify().loginAndVerify() ;
     PhoneUtil.applog("登录验证返回$islogin");
  }*/

  static Future<RecObj> weblogin() async {
    try {
      String url = geturl();
      String authHeader = 'Bearer ${WebCommand.sapplogin}'; // 设置 Bearer Token
      Map<String,dynamic> sendmmap=logindata();
      FormData senddata = FormData.fromMap(sendmmap);
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
      PhoneUtil.applog("登录验证auth:$authHeader, 访问url$url, 上传form data$sendmmap");
      return dio.then((value) {
        if (value.statusCode == 200) {
          RecObj robj=RecObj(value.data);
          PhoneUtil.applog("fchat web api 验证返回类型：${robj.toString()},返回code${robj.code}返回原始数据${robj.data}");
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

  static Options buildRequestOptions({String? sessionId, String? authHeader}) {
    final headers = <String, String>{
      'Content-Type': 'multipart/form-data',
    };
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
    }
    return Options(headers: headers);
  }

  static Future<String> httpspost(Map<String,dynamic> map) async {
    try {
      final Dio _dio = Dio();
      String authHeader = 'Bearer ${UserObj.servertoken}'; // 设置 Bearer Token
      FormData formData=FormData.fromMap(map); // 发送 POST 请求
      String url = HttpWebApi.geturl();
      Response response = await _dio.post(
        url,
        data: formData,
        options: buildRequestOptions(sessionId:UserObj.sessionid,authHeader: authHeader)
      );
      // 检查上传结果
      if (response.statusCode == 200) {
        return response.data;
      } else {
        print("文件上传失败: ${response.statusCode}");
      }
    } catch (e) {
      print("上传过程中出现错误: $e");
    }
    return "err";
  }
}


class RecObj{
  int code=-1;
  Map json={};
  List listarr=[];
  String data="";
  String rec;
  bool state=false;
  Uint8List? databyte;

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
    if(recservermap.containsKey("city")){
      WebUtil.city=recservermap["city"];
    }
    if(code==200){
      if(recservermap.containsKey("token")){
        UserObj.servertoken=recservermap["token"];
        //PhoneUtil.applog("获得服务器返回安全token${UserObj.servertoken}");
      }
      if(recservermap.containsKey("sessionId")){
        UserObj.sessionid=recservermap["sessionId"];
        //PhoneUtil.applog("开发模式下获得服务器sessionID:${UserObj.sessionid}");
      }
      state=true;
      if(recservermap.containsKey("data")) {
        data = recservermap["data"];
        json = JsonUtil.strtoMap(data);
        listarr = JsonUtil.strotList(data);
        databyte = Uint8List.fromList(json
            .toString()
            .codeUnits);
      }
    }else{
      data="err";
    }
  }

  @override
  String toString() {
    return data;
  }
}
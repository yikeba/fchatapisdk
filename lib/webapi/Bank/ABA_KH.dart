import 'package:dio/dio.dart';
import 'package:fchatapi/util/Tools.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'dart:js' as js;

import '../../util/JsonUtil.dart';
import '../../util/PhoneUtil.dart';
import '../../util/UserObj.dart';
import '../HttpWebApi.dart';
import '../WebCommand.dart';
import '../WebUtil.dart';


class ABA_KH{

  //这事是打开aba app 区分android ios打开
  static Future<bool> openpayaba(BuildContext context,Map abamap) async {
    if (abamap.isEmpty) return false;
    String _url = abamap["abapay_deeplink"];
    if (!WebUtil.isMobileiBrowser()) {
      _url = abamap["qrString"];
    }
    Uri uri = Uri.parse(_url);
    try {
      if (await launchUrl(uri,mode: LaunchMode.externalApplication)) {
        return true;
      }
    } catch (e) {
      print("打开 ABA App 失败: $e");
      Tools.showSnackbar(context, "打开aba bank err $e");
      return false;
    }
    return false;
  }

  static Future<String> _creatABAordert(Map<String,dynamic> map) async {
    FormData formData = FormData.fromMap(map);
    String url = HttpWebApi.geturl();
    String authHeader = 'Bearer ${UserObj.servertoken}'; // 设置 Bearer Token
    try {
      Dio dio = Dio();
      Future<Response> res = dio.post(
        url,
        options: Options(
          sendTimeout: const Duration(minutes: 10),
          receiveTimeout: const Duration(minutes:  10),
          method: "POST",
          headers: {
            'Content-Type': 'multipart/form-data',
            "Authorization": authHeader
          },
        ),
        data: formData,
        onReceiveProgress: (int received, int total) {

        },
      );
      return res.then((value) {
        try {
          if (value.statusCode == 200) {
            return value.data.toString();
          } else {
            PhoneUtil.applog("返回类型：${value.data}");
          }
        } catch (e) {
          PhoneUtil.applog("返回错误value 错误$e");
        }
        return "err";
      });
    } on DioError catch (dioError) {
      print("识别到 DioError catch: ${dioError.message}");

    }
    return "err";
  }

  static Map<String, dynamic> _getDataMap(Map sendmap) {
    Map<String, dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.ABApay);
    String data=JsonUtil.maptostr(sendmap);
    data=JsonUtil.setbase64(data);
    map.putIfAbsent("data", ()=>data);
    print("上传服务器文本map$map");
    return map;
  }

  static Future<bool> abapayweb(BuildContext context,String amount, String payid) async {
    PhoneUtil.applog("支付金额:$amount");
    Map map = {};
    map.putIfAbsent("amount", () => amount);
    map.putIfAbsent("payid", () => payid);
    map.putIfAbsent("return", () => "http://18.142.173.182:8080/aba");
    Map<String,dynamic> sendmap=_getDataMap(map);
    PhoneUtil.applog("提交服务器aba json:$sendmap");
    String rec = await _creatABAordert(sendmap);
    PhoneUtil.applog("aba服务器返回$rec");
    RecObj robj=RecObj(rec);
    PhoneUtil.applog("服务器发起aba支付调用${robj.json}");
    bool isopenaba=await openpayaba(context,robj.json);
    return isopenaba;
  }

}


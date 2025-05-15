import 'package:dio/dio.dart';
import 'package:fchatapi/util/Tools.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;
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
   // return await AppLauncherUtil.openPayAba(context, abamap);
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
    //print("上传服务器文本map$map");
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


class AppLauncherUtil {
  /// 打开 ABA App，支持微信拦截判断 + fallback 跳转 + PC 兼容
  static Future<bool> openPayAba(BuildContext context, Map abamap) async {
    if (abamap.isEmpty) return false;

    // 判断是否为微信内打开
    final isWeChat = html.window.navigator.userAgent.toLowerCase().contains("micromessenger");
    final isMobile = WebUtil.isMobileiBrowser();

    // 非手机设备，使用二维码 URL（一般是 PC）
    String deeplinkUrl = abamap["abapay_deeplink"];
    String fallbackUrl = abamap["qrString"] ?? abamap["abapay_fallback"];

    if (!isMobile && fallbackUrl != null) {
      html.window.location.href = fallbackUrl;
      return false;
    }

    if (isWeChat) {
      _showWeChatDialog(context);
      return false;
    }

    try {
      final success = await launchUrl(Uri.parse(deeplinkUrl), mode: LaunchMode.externalApplication);

      // 如果系统未报错但无法打开，可用定时 fallback
      _handlePossibleFailure(deeplinkUrl, fallbackUrl);
      return success;
    } catch (e) {
      print("打开 ABA App 失败: $e");
      Tools.showSnackbar(context, "打开aba bank 出错: $e");
      return false;
    }
  }

  /// fallback 判断机制：如果 App 未安装，1 秒后跳转 fallbackUrl
  static void _handlePossibleFailure(String deeplinkUrl, String fallbackUrl) {
    final int before = DateTime.now().millisecondsSinceEpoch;

    html.window.location.href = deeplinkUrl;

    Future.delayed(const Duration(seconds: 1), () {
      final int after = DateTime.now().millisecondsSinceEpoch;
      if (after - before < 1500 && fallbackUrl.isNotEmpty) {
        html.window.location.href = fallbackUrl;
      }
    });
  }

  /// 微信中提示用户“用浏览器打开”
  static void _showWeChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("提示"),
        content: const Text("微信内无法打开 ABA Bank App。\n请点击右上角菜单，选择『在浏览器中打开』后再试。"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("我知道了"),
          ),
        ],
      ),
    );
  }
}


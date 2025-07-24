import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import 'package:encrypt/encrypt.dart';
import 'package:fchatapi/FChatApiSdk.dart';
import 'package:fchatapi/webapi/HttpWebApi.dart';

import '../Util/PhoneUtil.dart';
import 'WebCommand.dart';

class LoginVerify {
  final Dio dio = Dio();

  String hmacSha256Base64(String data, String key) {
    final hmac = Hmac(sha256, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(data));
    return base64.encode(digest.bytes);
  }

  /// 修复后
  parsePublicKeyFromBase64(String base64Key) {
    final pemKey = '''-----BEGIN PUBLIC KEY-----\n${base64Key.replaceAllMapped(RegExp(r'.{1,64}'), (match) => '${match.group(0)}\n')}-----END PUBLIC KEY-----''';
    final parser = RSAKeyParser();
    return parser.parse(pemKey);
  }
  String encryptJsonWithPublicKey(String jsonString, String base64PublicKey) {
    final publicKey = parsePublicKeyFromBase64(base64PublicKey);
    final encrypter = Encrypter(RSA(publicKey: publicKey));
    final encrypted = encrypter.encrypt(jsonString);
    return base64.encode(encrypted.bytes);
  }

  Future<bool> loginAndVerify() async {
    try {
      // 第一步：获取服务器的 RSA 公钥和 hmacSalt
      String url = "${FChatApiSdk.host}applogin";
      String authHeader = 'Bearer ${WebCommand.sapplogin}'; // 设置 Bearer Token
      Map<String,dynamic> sendmmap=HttpWebApi.logindata();
      FormData senddata = FormData.fromMap(sendmmap);
      final loginResp = await dio.post(
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

      //final loginResp = await dio.post('https://fchat.us/sapplogin');
      final cookies = loginResp.headers['Set-Cookie'];
      final sessionId = RegExp(r'sessionId=([^;]+)')
          .firstMatch(cookies.toString() ?? '')
          ?.group(1);
      PhoneUtil.applog("申请建立会话id$cookies");
      final data = loginResp.data;
      final hmacSalt = data["hmacSalt"];
      final timestamp = data["serverTimestamp"];
      final rsaPublicKey = data["rsaPublicKey"];
      PhoneUtil.applog("第一次申请返回参数$data");
      // 构造签名和加密体
      final hmac = hmacSha256Base64(timestamp, hmacSalt);
      final payload = {
        "timestamp": timestamp,
        "hmac": hmac,
      };
      final jsonPayload = jsonEncode(payload);
      final encryptedBase64 = encryptJsonWithPublicKey(jsonPayload, rsaPublicKey);

      // 第二步：发送认证请求，Dio 自动附带 Cookie
      final verifyResp = await dio.post(
        '${FChatApiSdk.host}sappToken',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Cookie": "sessionId=$sessionId",
          },
          responseType: ResponseType.json,
        ),
        data: encryptedBase64,
      );

      print("认证成功: ${verifyResp.data}");
      return true;
    } catch (e) {
      print("认证失败: $e");
      return false;
    }
  }


}

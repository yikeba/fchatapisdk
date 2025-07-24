import 'package:dio/dio.dart';

class NetUtil{

  static Future<String> postString(String url, String post) async {
    try {
      Future<Response> dio = Dio().post(
        url,
        data: post,
      );
      return dio.then((value) {
        if (value.statusCode == 200) {
          return value.data.toString();
        }
        print("访问错误返回${value.statusCode}");
        return "err";
      });
    } on DioError catch (e) {
      print("post 错误$url");
    }
    return "locerr";
  }



}
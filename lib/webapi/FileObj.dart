import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:dio/dio.dart';
import 'package:fchatapi/util/SignUtil.dart';
import 'package:fchatapi/webapi/HttpWebApi.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert'; // 用于编码
import 'dart:typed_data';

import '../util/JsonUtil.dart';
import '../util/UserObj.dart';
import 'WebCommand.dart'; // 用于二进制处理

class FileObj {
  html.File? file;
  String? filedata;
  String md5Hash="";
  final Dio _dio = Dio();
  Uint8List? fileBytes;
  String authHeader = 'Bearer ${UserObj.servertoken}'; // 设置 Bearer Token
  initfile() async {
    try {
      // 使用 FileReader 读取文件内容
      if (file == null) return;
      final reader = html.FileReader();
      final completer = Completer<Uint8List>();
      // 定义 onLoad 回调，当读取完成后将结果传递给 completer
      reader.onLoad.listen((event) {
        final result = reader.result as Uint8List;
        completer.complete(result);
      });
      // 读取文件为字节数据
      reader.readAsArrayBuffer(file!); // 等待读取完成
      fileBytes = await completer.future;
      // 生成 MD5 签名
      md5Hash = SignUtil.getUint8(fileBytes!);
    } catch (e) {
      print("Error generating MD5 from file: $e");
      return "Error";
    }
  }

  Map<String,dynamic> _getFileMap(){
    Map<String,dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.upfile);
    map.putIfAbsent("md5", ()=> md5Hash);
    map.putIfAbsent("sapppath", ()=> FileMD.base.name);
    return map;
  }
  Map<String,dynamic> _getDataMap(){
    md5Hash=SignUtil.MD5str(filedata!);
    Map<String,dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.upData);
    map.putIfAbsent("md5", ()=> md5Hash);
    map.putIfAbsent("sapppath", ()=> FileMD.base.name);
    return map;
  }

  Future<void> writeData(String data,void Function(bool state) upstate) async {
    try {
      if (data.isEmpty) {
        print("无法读取文件内容");
        return;
      }
      // 准备表单数据
      filedata=data;
      Map<String,dynamic> map=_getDataMap();
      map.putIfAbsent('file', ()=>MultipartFile.fromBytes(
        fileBytes!,
        filename: file!.name,
        contentType: MediaType('text', 'html'),
      ),);
      FormData formData = FormData.fromMap(map);
      // 发送 POST 请求
      String url = HttpWebApi.geturl();
      Response response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            "Authorization": authHeader
          },
        ),
      );
      // 检查上传结果
      if (response.statusCode == 200) {
        upstate(true);
        print("文件上传成功: ${response.data}");
      } else {
        print("文件上传失败: ${response.statusCode}");
      }
    } catch (e) {
      print("上传过程中出现错误: $e");
    }
  }

  Future<void> writeFile(html.File file,void Function(bool state) upstate) async {
    this.file=file;
    await initfile();
    try {
      if (fileBytes == null) {
        print("无法读取文件内容");
        return;
      }
      // 准备表单数据
      Map<String,dynamic> map=_getFileMap();
      map.putIfAbsent('file', ()=>MultipartFile.fromBytes(
        fileBytes!,
        filename: file!.name,
        contentType: MediaType('text', 'html'),
      ),);
      FormData formData = FormData.fromMap(map);
      // 发送 POST 请求
      String url = HttpWebApi.geturl();
      Response response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            "Authorization": authHeader
          },
        ),
      );
      // 检查上传结果
      if (response.statusCode == 200) {
        upstate(true);
        print("文件上传成功: ${response.data}");
      } else {
        print("文件上传失败: ${response.statusCode}");
      }
    } catch (e) {
      print("上传过程中出现错误: $e");
    }
  }


}

class FileArrObj{
  final Dio _dio = Dio();
  String authHeader = 'Bearer ${UserObj.servertoken}'; // 设置 Bearer Token

  Map<String,dynamic> _getReadmdMap(String md){
    Map<String,dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.readMD);
    map.putIfAbsent("sapppath", ()=> md);
    return map;
  }

  Future<void> readMD(void Function(List<FileObj>) filearr,{String md=""}) async {
    try {
      if(md.isEmpty) md=FileMD.base.name;
      Map<String,dynamic> map=_getReadmdMap(md);
      FormData formData = FormData.fromMap(map);
      // 发送 POST 请求
      String url = HttpWebApi.geturl();
      Response response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            "Authorization": authHeader
          },
        ),
      );
      // 检查上传结果
      if (response.statusCode == 200) {
        String rec=response.data;
        parsefileobj(RecObj(rec).json);
        print("读取内容: $rec");
      } else {
        print("文件上传失败: ${response.statusCode}");
      }
    } catch (e) {
      print("上传过程中出现错误: $e");
    }
  }

  parsefileobj(Map map){
    map.forEach((key, value) {


    });
  }


}


enum FileMD {
  base,
  assets, //用户信息
  other
}
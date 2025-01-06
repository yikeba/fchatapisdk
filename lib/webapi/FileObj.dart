import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:dio/dio.dart';
import 'package:fchatapi/util/SignUtil.dart';
import 'package:fchatapi/webapi/HttpWebApi.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as pathobj;
import '../util/JsonUtil.dart';
import '../util/UserObj.dart';
import 'WebCommand.dart'; // 用于二进制处理

class FileObj {
  html.File? file;
  String? filedata;
  String md5Hash = "";
  final Dio _dio = Dio();
  Uint8List? fileBytes;
  FileMD filemd = FileMD.base;
  String authHeader = 'Bearer ${UserObj.servertoken}'; // 设置 Bearer Token

  initfile() async {
    try {
      if (file == null) return;
      final reader = html.FileReader();
      final completer = Completer<Uint8List>();
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

  Map<String, dynamic> _getFileMap() {
    Map<String, dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.upfile);
    map.putIfAbsent("md5", () => md5Hash);
    map.putIfAbsent("sapppath", () => filemd.name);
    return map;
  }

  Map<String, dynamic> _getDataMap() {
    //md5Hash=SignUtil.MD5str(filedata!);
    md5Hash = SignUtil.getUint8(fileBytes!);
    Map<String, dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.upData);
    map.putIfAbsent("md5", () => md5Hash);
    map.putIfAbsent("sapppath", () => filemd.name);
    print("上传服务器文本map$map");
    return map;
  }

  Future<void> writeByte(
      Uint8List data, String name, void Function(bool state) upstate) async {
    try {
      fileBytes = data;
      Map<String, dynamic> map = _getFileMap();
      map.putIfAbsent(
        'file',
        () => MultipartFile.fromBytes(
          fileBytes!,
          filename: name,
          contentType: MediaType('text', 'html'),
        ),
      );
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
        String rec = JsonUtil.getbase64(response.data);
        print("文件上传成功: $rec");
      } else {
        print("文件上传失败: ${response.statusCode}");
      }
    } catch (e) {
      print("上传过程中出现错误: $e");
    }
  }

  Future<void> writeData(
      String data, String name, void Function(bool state) upstate) async {
    try {
      if (data.isEmpty) {
        print("无法读取文件内容");
        return;
      }
      filedata = JsonUtil.setbase64(data);
      //filedata=data;
      fileBytes = Uint8List.fromList(filedata!.codeUnits);
      if (fileBytes == null) {
        print("数据转换base64 byte错误");
        return;
      }
      print("上传文本二进制长度${fileBytes!.length}");
      Map<String, dynamic> map = _getDataMap();
      map.putIfAbsent(
        'file',
        () => MultipartFile.fromBytes(
          fileBytes!,
          filename: name,
          contentType: MediaType('text', 'html'),
        ),
      );
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
        String rec = JsonUtil.getbase64(response.data);
        print("文件上传成功: $rec");
      } else {
        print("文件上传失败: ${response.statusCode}");
      }
    } catch (e) {
      print("上传过程中出现错误: $e");
    }
  }

  Future<void> writeFile(
      html.File file, void Function(bool state) upstate) async {
    this.file = file;
    await initfile();
    try {
      if (fileBytes == null) {
        print("无法读取文件内容");
        return;
      }
      // 准备表单数据
      Map<String, dynamic> map = _getFileMap();
      map.putIfAbsent(
        'file',
        () => MultipartFile.fromBytes(
          fileBytes!,
          filename: file!.name,
          contentType: MediaType('text', 'html'),
        ),
      );
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
        String rec = JsonUtil.getbase64(response.data);
        print("文件上传成功: $rec");
      } else {
        print("文件上传失败: ${response.statusCode}");
      }
    } catch (e) {
      print("上传过程中出现错误: $e");
    }
  }

  Map<String, dynamic> _getreadMap(path) {
    Map<String, dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.readfile);
    map.putIfAbsent("sapppath", () => path);
    return map;
  }

  Future<void> readFile(
      String path, void Function(String data) filedata) async {
    try {
      Map<String, dynamic> map = _getreadMap(path);
      String rec = await HttpWebApi.httpspost(map);
      String data = RecObj(rec).data;
      filedata(data);
    } catch (e) {
      print("上传过程中出现错误: $e");
    }
  }

  Map<String, dynamic> _getdelMap(path) {
    Map<String, dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.delfile);
    map.putIfAbsent("sapppath", () => path);
    return map;
  }

  Future<void> delFile(String path, void Function(bool state) call) async {
    try {
      Map<String, dynamic> map = _getdelMap(path);
      String rec = await HttpWebApi.httpspost(map);
      String data = RecObj(rec).data;
      call(true);
    } catch (e) {
      print("上传过程中出现错误: $e");
    }
  }
}

class FileArrObj {
  Map<String, dynamic> _getReadmdMap(String md) {
    Map<String, dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.readMD);
    map.putIfAbsent("sapppath", () => md);
    return map;
  }

  Map<String, dynamic> _getReadfileMap(String md, String name) {
    Map<String, dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.readfile);
    map.putIfAbsent("sapppath", () => md + "/" + name);
    return map;
  }

  Map<String, dynamic> _getReadmdthbMap(String md) {
    Map<String, dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.readMDthb);
    map.putIfAbsent("sapppath", () => md);
    return map;
  }

  Future<void> readfile(void Function(FileObj) file,
      {String md = "", String filename = ""}) async {
    if (md.isEmpty) md = FileMD.base.name;
    Map<String, dynamic> map = _getReadfileMap(md, filename);
    String rec = await HttpWebApi.httpspost(map);
    rec = JsonUtil.getbase64(rec);
    print("读取文件制定文件返回$rec");
    file(parsefile(RecObj(rec).data, filename));
  }

  Future<void> readMD(void Function(List<FileObj>) filearr,
      {String md = ""}) async {
    if (md.isEmpty) md = FileMD.base.name;
    // print("读取服务器目录$md");
    Map<String, dynamic> map = _getReadmdMap(md);
    String rec = await HttpWebApi.httpspost(map);
    //print("读取文件目录返回$rec");
    filearr(parsefileobj(RecObj(rec).json));
  }

  Future<void> readMDthb(void Function(List) filearr, {String md = ""}) async {
    if (md.isEmpty) md = FileMD.base.name;
    Map<String, dynamic> map = _getReadmdthbMap(md);
    String rec = await HttpWebApi.httpspost(map);
    filearr(RecObj(rec).listarr);
  }

  List<FileObj> parsefileobj(Map map) {
    List<FileObj> arr = [];
    map.forEach((key, value) {
      FileObj file = FileObj();
      String fileName = pathobj.basename(key);
      file.md5Hash = fileName;
      file.filedata = value;
      arr.add(file);
    });
    return arr;
  }

  FileObj parsefile(String data, String name) {
    FileObj file = FileObj();
    file.md5Hash = name;
    file.filedata = data;
    file.fileBytes = Uint8List.fromList(data.codeUnits);
    return file;
  }
}

enum FileMD { base, assets, image, video, product, order, payorder, other }

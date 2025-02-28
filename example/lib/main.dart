import 'package:fchatapi/FChatApiSdk.dart';
import 'package:fchatapi/appapi/PayObj.dart';
import 'package:fchatapi/util/PhoneUtil.dart';
import 'package:fchatapi/webapi/FileObj.dart';
import 'package:fchatapi/webapi/StripeUtil/WebPayUtil.dart';
import 'package:fchatapi/webapi/WebUItools.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'dart:html' as html;
void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    initload();
  }

  String userid="";
  String token = "";
  initload() {
    userid = dotenv.get('userid');
    token = dotenv.get('token');
    FChatApiSdk.init(userid, token, (webstate) {
      print("fchat web api 返回状态$webstate");
    }, (appstate) {});
  }

  String? selectedFileName;
  String? selectedFilePath;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      if (kIsWeb) {
        final fileBytes = result.files.first.bytes;
        html.File file = result.files.first.bytes != null
            ? html.File([result.files.first.bytes!], result.files.first.name)
            : result.files.first as html.File;
        FChatApiSdk.fileobj.filemd=FileMD.video;
        FChatApiSdk.fileobj.writeFile(file, (value) {
          print("File 上传访问状态: $value");
        });
        print('本地 File Name: $selectedFileName');
        print('本地 File Size: ${fileBytes?.length} bytes');
      } else {
        print('File Path: $selectedFilePath');
      }

    } else {
      setState(() {
        selectedFileName = null;
        selectedFilePath = null;
      });
    }
  }

  Future<void> readmd() async {
    FChatApiSdk.filearrobj.readMD((value) {
      print("读取文件目录返回文件对象数量:${value.length}");
    }, md: "assetsmd");
  }

  Future<void> delfile() async {
    FChatApiSdk.filearrobj.readMDthb((value) {
      for (String str in value) {
        String name=str.replaceAll("$userid/", "");
        print("删除指定文件名称路径:$name");
        FChatApiSdk.fileobj.delFile(name, (data) {
          print("指定文件删除完毕$name,状态$data");
        });
        break;
      }
    }, md: "assetsmd");
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<void> readmdthb() async {
    int index = 0;
    int endindex = 0;
    _showLoadingDialog();
    FChatApiSdk.filearrobj.readMDthb((value) {
      for (String str in value) {
        index++;
        print("读取服务器原始路径:$str");
        String name=str.replaceAll("$userid/", "");
        print("读取文件明显名称:$name");
        FChatApiSdk.fileobj.readFile(name, (data) {
          PhoneUtil.applog("读取指定文件内容:${data}");
          endindex++;
          if (endindex == index) {
            Navigator.of(context).pop();
          }
        });
      }
    }, md: "assetsmd");
  }

  Future<void> readmdthbinfo() async {
    _showLoadingDialog();
    FChatApiSdk.filearrobj.readMDthb((value) {
      for (String str in value) {
        String name=str.replaceAll("$userid/", "");
        print("读取文件明显名称:$name");
      }
      Navigator.of(context).pop();
    }, md: "assetsmd");
  }

  Future<void> pickImage() async {
    try {
      final pickedImage = await ImagePickerWeb.getImageAsFile();
      String? _fileName;
      if (pickedImage != null) {
        FChatApiSdk.fileobj.filemd=FileMD.image;
        FChatApiSdk.fileobj.writeFile(pickedImage, (value) {
          print("File 上传访问状态: $value");
        });
        setState(() {
          _fileName = pickedImage.name;
        });
        print("File Name: $_fileName");
        print("Image Size: ${pickedImage.size} bytes");
      } else {
        print("No image selected.");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  paytest(){
    PayObj pay=PayObj();
    pay.amount="0.05";
    pay.paytext="测试支付";
    pay.pay((value){
       print("app 支付返回结果$value");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FChat Api'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickFile,
              child: const Text("选择Pick a File"),
            ),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("选择图片文件"),
            ),
            ElevatedButton(
              onPressed: readmd,
              child: const Text("读取文件目录"),
            ),
            ElevatedButton(
              onPressed: readmdthb,
              child: const Text("读取文件列表"),
            ),
            ElevatedButton(
              onPressed: readmdthbinfo,
              child: const Text("读取文件列表信息"),
            ),
            ElevatedButton(
              onPressed: delfile,
              child: const Text("删除文件"),
            ),
            ElevatedButton(
              onPressed: paytest,
              child: const Text("app支付"),
            ),
            ElevatedButton(
              onPressed: webpaytest,
              child: const Text("网页支付"),
            ),
          ],
        ),
      ),
    );
  }
  webpaytest(){
     if(WebPayUtil.isLocCard()){
       WebUItools.opencardlist(context,null,null);
     }else {
       WebUItools.openWebpay(context,null,null);
     }
  }
}
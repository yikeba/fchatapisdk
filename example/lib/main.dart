import 'package:fchatapi/FChatApiSdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fchatapi/fchatapi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker_web/image_picker_web.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _fchatapiPlugin = Fchatapi();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initload();
  }

  initload() {
    String userid = dotenv.get('userid');
    String token = dotenv.get('token');
    FChatApiSdk.init(userid, token, (webstate) {
      print("fchat web api 返回状态$webstate");
    }, (appstate) {});
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _fchatapiPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  String? selectedFileName;
  String? selectedFilePath;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // 允许选择任意类型的文件
      allowMultiple: false, // 只允许选择单个文件
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFileName = result.files.first.name;
        selectedFilePath = result.files.first.path; // 在 Web 上为 null
      });

      // Web 平台特定：获取文件内容
      if (kIsWeb) {
        final fileBytes = result.files.first.bytes; // 获取文件的二进制内容
        print(' 本地 File Name: $selectedFileName');
        print('本地  File Size: ${fileBytes?.length} bytes');
      } else {
        print('File Path: $selectedFilePath');
      }
    } else {
      // 用户取消了文件选择
      setState(() {
        selectedFileName = null;
        selectedFilePath = null;
      });
    }
  }

  Future<void> readmd() async {
    FChatApiSdk.filearrobj.readMD((value) {
      print("读取文件目录返回文件对象数量:${value.length}");
    });
  }

  Future<void> pickImage() async {
    try {
      // 使用 image_picker_web 选择图片
      final pickedImage = await ImagePickerWeb.getImageAsFile();

      String? _fileName; // 存储文件名
      if (pickedImage != null) {
        FChatApiSdk.fileobj.writeFile(pickedImage, (value) {
          print("File 上传访问状态: $value");
        });
        setState(() {
          _fileName = pickedImage.name ?? "Unknown File";
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('FChat Api'),
      ),
      body: Center(
        child: Column(
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
              onPressed: (){
                readmd();
              },
              child: const Text("读取文件目录"),
            ),
          ],
        ),
      ),
    ));
  }
}

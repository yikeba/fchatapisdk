import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

class FileHtmlUtil{
  static Future<Uint8List?> readHtmlFile(html.File file) async {
    try {
      final reader = html.FileReader();
      final completer = Completer<Uint8List>();
      reader.onLoad.listen((event) {
        final result = reader.result as Uint8List;
        completer.complete(result);
      });
      // 读取文件为字节数据
      reader.readAsArrayBuffer(file); // 等待读取完成
      return await completer.future;
    } catch (e) {
      print("Error generating MD5 from file: $e");
      return null;
    }
  }

}
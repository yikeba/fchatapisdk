import 'dart:convert';

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;

class MeidaUtil{


  /// 将 base64 图片压缩为缩略图 base64，输出为 PNG 格式
  static String? getBase64Thumbnail(String base64Str, {int maxSide = 150}) {
    try {
      final uriPattern = RegExp(r'data:image/[^;]+;base64,');
      final cleanedBase64 = base64Str.replaceAll(uriPattern, '');
      Uint8List imageBytes = base64Decode(cleanedBase64);

      final image = img.decodeImage(imageBytes);
      if (image == null) return null;
      final Size newSize = getbase64ThumbBestSize(image.width, image.height, maxSide: maxSide);
      final thumbnail = img.copyResize(
        image,
        width: newSize.width.toInt(),
        height: newSize.height.toInt(),
        interpolation: img.Interpolation.linear,
      );

      final thumbnailBytes = img.encodePng(thumbnail);
      // return 'data:image/png;base64,${base64Encode(thumbnailBytes)}';
      return base64Encode(thumbnailBytes);
    } catch (e) {
      // print("生成缩略图失败: $e");
      return null;
    }
  }


  /// 根据图像尺寸计算缩略图目标大小（可修改为你需要的大小逻辑）
  static Size getbase64ThumbBestSize(int width, int height, {int maxSide = 150}) {
    if (width <= maxSide && height <= maxSide) return Size(width.toDouble(), height.toDouble());
    double ratio = min(maxSide / width, maxSide / height);
    return Size(width * ratio, height * ratio);
  }


}
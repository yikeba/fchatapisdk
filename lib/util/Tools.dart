import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'PhoneUtil.dart';



class Tools {

  static sleepwaittime(int w) {
    sleep(Duration(milliseconds: w));
  }

  static Color generateRandomColor() {
    Random random = Random();
    int r, g, b;
    do {
      r = random.nextInt(256);
      g = random.nextInt(256);
      b = random.nextInt(256);
    } while (r == 255 && g == 255 && b == 255);  // 确保颜色不是白色
    return Color.fromRGBO(r, g, b, 1);
  }

  static String strtoUrl(String text){
      RegExp regExp = RegExp(
          r"(https?://(?:www\.|(?!www))[^\s.]+\.[^\s]{2,}|www\.[^\s]+\.[^\s]{2,})");
      Iterable<RegExpMatch> matches = regExp.allMatches(text);
      String? url="";
      for (RegExpMatch match in matches) {
        url=match.group(0);
      }
      if(url==null) return "";
      return url;
  }

  //随机数
  static int  Ramnums(int n) {
    var rng = Random();
    var str = rng.nextInt(n);
    return str;
  }


  static String generateRandomString(int length) {
    final _random = Random();
    const _availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final randomString = List.generate(length,
            (index) => _availableChars[_random.nextInt(_availableChars.length)])
        .join();
    return randomString;
  }

  //int ---> hex
  static String intToHex(int num) {
    String hexString = num.toRadixString(16);
    return hexString;
  }

  static String getIntRom(int length) {
    const _availableChars = '0123456789';
    final _random = Random();
    final randomString = List.generate(length,
            (index) => _availableChars[_random.nextInt(_availableChars.length)])
        .join();
    return randomString;
  }

  static double getDoubleRom() {
    String str="";
    for(int i=0;i<10;i++){
      Random rng = Random();
      int s = rng.nextInt(9);
      str=str+s.toString();
    }
    str="0.$str";
    double s=double.parse(str);
    return s;
  }

  static String gethexprivate() {
    //879757c776aa88e2c824a0fc94258caf6b8163670a1dad0e680ca616e3e5a681
    int length = 61;
    String startstr = "879";
    const _availableChars = '0123456789abcdef';
    final _random = Random();
    final randomString = List.generate(length,
            (index) => _availableChars[_random.nextInt(_availableChars.length)])
        .join();
    String pkey = startstr + randomString;
    return pkey;
  }

  static List<int> randMaxMinarr(int maxmoney, int rpmnum) {
    List<int> arr = [];
    for (int i = 0; i < rpmnum; i++) {
      arr.add(1);
      maxmoney--;
    }
    while (maxmoney > 0) {
      int index = 0;
      if (rpmnum > 1) {
        index = Ramnums(rpmnum);
        if (index == rpmnum) index = index - 1;
        PhoneUtil.applog(
            "红包随机序列索引：$index红包总数：$rpmnum");
      }
      int je = Ramnums(maxmoney);
      if (je == 0) je = 1;
      arr[index] = arr[index] + je;
      maxmoney = maxmoney - je;
    }
    return arr;
  }



  static BigInt strtobigint(String str) {
    try {
      return BigInt.parse(str);
    } catch (e) {
      return BigInt.from(-1);
    }
  }

  static int strtoint(String str) {
    try {
      return int.parse(str);
    } catch (e) {
      return -1;
    }
  }

  static num strtodou(String str) {
    try {
      return double.parse(str);
    } catch (e) {
      return -1;
    }
  }





  static openChrome(String _url) async {
    try {
      var rec = await launch(_url);
      print("打开正确，返回：$rec打开的链接:$_url");
    } catch (e) {
      print("打开错误，打开下载页面");
      return await launch(_url);
    }
  }





  static getmoneyint(String str) {
    //元单位字符串 转化为分单位整型
    num mdu = Tools.strtodou(str);
    mdu = mdu * 100;
    return mdu.toInt();
  }



  static Size oldgetTextSize(String text, TextStyle style) {
    TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    );
    painter.layout();
    return painter.size;
  }

  static String isurl(String text) {
    // final urlRegExp = RegExp(
    //     r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
    final urlRegExp = RegExp(
        r'(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?');
    final urlMatches = urlRegExp.allMatches(text);
    List<String> urls = urlMatches
        .map((urlMatch) => text.substring(urlMatch.start, urlMatch.end))
        .toList();
    if (urls.isEmpty) return "";
    return strtoUrl(urls[0]);
    //return urls[0];
  }


  static Future<String> getWebTitle(String url) async {
    final res = await Dio().get(url);
    String? title = RegExp(
            r"<[t|T]{1}[i|I]{1}[t|T]{1}[l|L]{1}[e|E]{1}(\s.*)?>([^<]*)</[t|T]{1}[i|I]{1}[t|T]{1}[l|L]{1}[e|E]{1}>")
        .stringMatch(res.data);

    if (title != null) {
      return title.substring(title.indexOf('>') + 1, title.lastIndexOf("<"));
    } else {
      return "";
    }
  }

  static Size boundingTextSize(String text, TextStyle style,
      {int maxLines = 2 ^ 31, double maxWidth = double.infinity}) {
    if (text == null || text.isEmpty) {
      return Size.zero;
    }
    final TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(text: text, style: style),
        maxLines: maxLines)
      ..layout(maxWidth: maxWidth);
    return textPainter.size;
  }

  static bool isemail(String input) {
    //邮件判断格式
    if (input.isEmpty) return false;
    // 邮箱正则
    String regexEmail = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$";
    return RegExp(regexEmail).hasMatch(input);
  }

// 验证是否为数字
  static bool isNumber(String str) {
    final reg = RegExp(r'^-?[0-9]+');
    print('$str 是否数字:${reg.hasMatch(str)}');
    return reg.hasMatch(str);
  }

  //  判断是否是hi货币格式
  static bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  //  判断是否是hi货币格式
  static bool isMoney(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }


  static String isTexturl(String text) {
    // final urlRegExp = RegExp(
    //     r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
    final urlRegExp = RegExp(
        r'(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?');
    final urlMatches = urlRegExp.allMatches(text);
    List<String> urls = urlMatches
        .map((urlMatch) => text.substring(urlMatch.start, urlMatch.end))
        .toList();
    if (urls.isEmpty) return "";
    return urls[0];
  }
}

//返回文本长度，宽度，或限制宽度的高度
class getTextSize {
  TextStyle style;
  String value;

  getTextSize(this.style, this.value);

  setwidhtgetheight(double setwidth) {
    //返回高度
    Size size = Tools.boundingTextSize(value, style);
    if (size.width > setwidth) {
      double wbl = size.width / setwidth;
      return size.height * wbl;
    } else {
      return size.height;
    }
  }
}



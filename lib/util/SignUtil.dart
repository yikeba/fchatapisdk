
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'PhoneUtil.dart';


class SignUtil{
  static String getSign(Map parameter,String keystr) {
    var Key = keystr;
    //var timestamp = DateTime.now().millisecondsSinceEpoch;
    //var versionNumber = 'app-v1';
   // parameter['timestamp'] = timestamp.toString();
    //parameter['versionNumber'] = versionNumber;
    /// 存储所有key
    List<String> allKeys = [];
    parameter.forEach((key,value){
      String valuestr="";
      if(value.runtimeType.toString()!="String"){
         valuestr=value.toString();
      }else{
        valuestr=value;
      }
      allKeys.add(key + valuestr);
    });
    /// key排序
    allKeys.sort((obj1,obj2){
      return obj1.compareTo(obj2);
    });
    /// 数组转string
    String pairsString = allKeys.join("");
    PhoneUtil.applog("list to str:$pairsString");
    /// 拼接 ABC 是你的秘钥
    String sign =  pairsString + Key;
    /// hash
   // String signString = generateMd5(sign).toUpperCase();
    String signString = md5.convert(utf8.encode(sign)).toString().toLowerCase();  //直接写也可以
    return signString;
  }



  static hmacSHA512(String value,String key){
    var keystr = utf8.encode(key);
    var bytes = utf8.encode(value);
    var h512 = Hmac(sha512, keystr);
    Digest sha512Result =h512.convert(bytes);
    String s512str=base64.encode(sha512Result.bytes);
    return s512str;
  }

  static Map<String,dynamic> getmd5Signtomap(Map<String,dynamic> parameter,String Key) {
    String pairsString = mapsortasc(parameter);
   // print("待签名字符串："+pairsString);
    String sign =  pairsString + Key; /// 拼接 ABC 是你的秘钥
    String signString = md5.convert(utf8.encode(sign)).toString().toLowerCase();  //直接写也可以
    //PhoneUtil.applog("md签名："+signString);
    parameter.putIfAbsent("sign", () => signString);
    return parameter;
  }

  static String oldgetmd5Signtostr(String pairsString,String Key) {
    String sign =  pairsString + Key; /// 拼接 ABC 是你的秘钥
    String signString = md5.convert(utf8.encode(sign)).toString().toLowerCase();  //直接写也可以
    return signString;
  }


  static String getmd5Signtostr(String inputString, String key) {
    final bytes = utf8.encode(inputString + key);  // 将字符串和密钥转换成字节数据
    final md5Digest = md5.convert(bytes);  // 对整个字节数据计算MD5
    return md5Digest.toString();
  }




  static MD5str(String str){
    String signString = md5.convert(utf8.encode(str)).toString().toLowerCase();  //直接写也可以
    return signString;
  }
  static String getmd5Sign(Map<String,String> parameter,String Key) {
    String pairsString = mapsortasc(parameter);
    String sign =  pairsString + Key; /// 拼接 ABC 是你的秘钥
    //print("map  key:"+Key);
    //String signString = generateMd5(sign);  /// hash
    String signString = md5.convert(utf8.encode(sign)).toString().toLowerCase();  //直接写也可以
    return signString;
  }
  static generateMd5(String str)  {
    var bytes = utf8.encode(str); // data being hashed
    Hash hasher=md5;
    Digest md5str =hasher.convert(bytes);
    return md5str;
  }


//将map 按照ASCII 顺序排序，返回字符串
  static String mapsortasc(Map<String,dynamic> map){
    List<String> keys = map.keys.toList();
    // key排序
    keys.sort((a, b) {
      List<int> al = a.codeUnits;
      List<int> bl = b.codeUnits;
      for (int i = 0; i < al.length; i++) {
        if (bl.length <= i) return 1;
        if (al[i] > bl[i]) {
          return 1;
        } else if (al[i] < bl[i]) return -1;
      }
      return 0;
    });
    String ascstr="";
    for(String key in keys){
       String? value=map[key];
       ascstr=ascstr+key+"="+value.toString()+"&";
    }
   // print("排序结果:"+ascstr);
    ascstr= ascstr.substring(0,ascstr.length - 1);
   // print("去掉最后一个字符:"+ascstr);
    return ascstr;
  }
  static String getUint8(Uint8List byte)  {
    return md5.convert(byte).toString().toLowerCase();  //直接写也可以
  }

  static Future getMd5Path(String path)  {
    File file=File(path);
    Hash hasher=md5;
    var md5str = hasher.bind(file.openRead()).first;
    return md5str.then((value) {
      //PhoneUtil.applog("文件md5签名结果:"+value.toString());
         return value.toString();
    });
  }
  static Future<String> getMd5file(File file)  async {
    Hash hasher=md5;
    var md5str = hasher.bind(file.openRead()).first;
    return await md5str.then((value) {
        return value.toString();
    });
  }

  /// 验证文件的 MD5 是否一致
  static Future<bool> verifyMd5(Uint8List fileBytes, String expectedMd5) async {
    Digest md5Hash = md5.convert(fileBytes);  // 计算传入数据的 MD5
    return md5Hash.toString() == expectedMd5;  // 比较结果是否匹配
  }

  static Future<String> getfiletomd5(File file)  async {
    Hash hasher=md5;
    return hasher.bind(file.openRead()).first.toString();
  }

  static bool verifymd5(String data, String token,String sgin) {
    String md5sgin=getmd5Signtostr(data,token);
    return sgin==md5sgin;
  }

  // 计算文件的 SHA-256 或 MD5 哈希值
  static Future<String> calculateFileHash256(String filePath) async {
    try {
      File file = File(filePath);

      if (await file.exists()) {
        // 读取文件字节
        var bytes = await file.readAsBytes();
        // 根据选择的算法计算哈希值
        Digest digest = sha256.convert(bytes); // 计算 SHA-256
        // 返回哈希值的字符串
        return digest.toString();
      } else {
        throw Exception("文件不存在: $filePath");
      }
    } catch (e) {
      print("计算哈希时出错: $e");
      return "";
    }
  }







}
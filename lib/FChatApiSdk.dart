import 'package:fchatapi/Express/ZtoApi.dart';
import 'package:fchatapi/Util/JsonUtil.dart';
import 'package:fchatapi/appapi/LoginFChat.dart';
import 'package:fchatapi/util/PhoneUtil.dart';
import 'package:fchatapi/util/Translate.dart';
import 'package:fchatapi/util/UserObj.dart';
import 'package:fchatapi/webapi/ChatUserobj.dart';
import 'package:fchatapi/webapi/FileObj.dart';
import 'package:fchatapi/webapi/HttpWebApi.dart';
import 'package:fchatapi/webapi/StripeUtil/CardArr.dart';
import 'package:fchatapi/webapi/StripeUtil/WebPayUtil.dart';
import 'package:fchatapi/webapi/WebCommand.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'appapi/BaseJS.dart';

// 顶部
import 'src/web/WebFirebaseEnv_stub.dart'
if (dart.library.html) 'src/web/WebFirebaseEnv.dart';


class FChatApiSdk {
  static FileObj fileobj = FileObj();
  static FileArrObj filearrobj = FileArrObj();
  static String griupid="";  //默认客户群聊
  static CardArr loccard=CardArr();
  static bool isFchatBrower=false;  //是否在fchat app中运行
  static String host="https://fchat.us/";
  static String debughost="http://fchat.us/";

  static init(String userid, String token, void Function(bool state) webcall,
      void Function(bool state) appcall,{String appname=""})  async {
    WidgetsFlutterBinding.ensureInitialized();
    //initenv();
    await WebFirebaseEnv.initenv();
    Translate.initTra();
    UserObj.token = token;
    UserObj.userid = userid;
    UserObj.appname=appname;
    _readApiJson();
    HttpWebApi.weblogin().then((value) {
      if (value.data == "loginok") {
        webcall(true);
        _readgroupid();
      } else {
        PhoneUtil.applog("服务号鉴权失败");
        webcall(false);
      }
    });
    BaseJS.apiRecdatainit();  //初始化app接口
    Loginfchat().send((value){
       if(value=="err") value="";
       PhoneUtil.applog("返回Fchat 环境内容:$value");
       if(value.isEmpty) {
         appcall(false);
       } else{
         appcall(true);
       }
       isFchatBrower=value.isNotEmpty ? true : false;
    });
    //服务器增加一个验证接口，初始化验证服务号是否上线，并判断采用url
  }
  static _readgroupid() async {
    Map<String,dynamic> map=_getgroupid();
    String rec=await HttpWebApi.httpspost(map);
    griupid=RecObj(rec).data;
    PhoneUtil.applog("读取服务号默认客户群聊$griupid");
  }

  static _readApiJson() async {
    try {
      String content = await rootBundle.loadString('packages/fchatapi/assets/json/zto.json');
      content=content.trim();
      content=content.replaceAll(r'\', '');
      Map map=JsonUtil.strtoMap(content);
      ZtoApi.initZtoObj(map["data"]);
      //PhoneUtil.applog("中通配置地理位置字典文件内容：${ZtoApi.ztoLocJson}");
    } catch (e) {
      PhoneUtil.applog("中通配置地理位置字典文件读取失败: $e");
    }
  }


  static Future<ChatUserobj?> searchCHATid<T>(String id) async {
    //本地查询好友结果
    String userid = id;
    Map map = {};
    map.putIfAbsent("userid", () => userid);
    final value = await WebPayUtil.getDataMap(map, WebCommand.searchCHATid);
    final rec=await WebPayUtil.httpFchatserver(value);
    RecObj recobj =RecObj(rec);
    PhoneUtil.applog("返回用户信息${recobj.json}");
    if(recobj.json.isNotEmpty) {
      return ChatUserobj.withNameAndAge(recobj.json);
    }
    return null;

  }

/*  static initenv() async {
    if (!kIsWeb) return;
    await dotenv.load(fileName: "packages/fchatapi/assets/.env");
    FirebaseConfig.apiKey= dotenv.get('firebaseapiKey');
    FirebaseConfig.authDomain=dotenv.get('firebaseauthDomain');
    FirebaseConfig.projectId=dotenv.get('firebaseprojectId');
    FirebaseConfig.storageBucket= dotenv.get('firebasestorageBucket');
    FirebaseConfig.messagingSenderId= dotenv.get('firebasemessagingSenderId');
    FirebaseConfig.appId=dotenv.get('firebaseappId');
    FirebaseConfig.measurementId= dotenv.get('firebasemeasurementId');
    FirebaseConfig.clientId=dotenv.get('clientId');
    FirebaseConfig.redirectUri=dotenv.get('redirectUri');
    await Firebase.initializeApp(
      options: FirebaseConfig.webConfig,  // 获取配置
    );
    //PhoneUtil.applog("firebase config:${FirebaseConfig.webConfig.toString()}");
  }*/

  static Map<String,dynamic> _getgroupid(){
    Map<String,dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.readGroup);
    return map;
  }

}

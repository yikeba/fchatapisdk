import 'package:fchatapi/util/DeviceInfo.dart';
import 'package:fchatapi/util/PhoneUtil.dart';
import 'package:fchatapi/util/Translate.dart';
import 'package:fchatapi/util/UserObj.dart';
import 'package:fchatapi/webapi/FileObj.dart';
import 'package:fchatapi/webapi/HttpWebApi.dart';
import 'package:fchatapi/webapi/StripeUtil/CardArr.dart';
import 'package:fchatapi/webapi/WebCommand.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart';
import 'WidgetUtil/AuthWidget.dart';
import 'appapi/BaseJS.dart';

class FChatApiSdk {
  static FileObj fileobj = FileObj();
  static FileArrObj filearrobj = FileArrObj();
  static String griupid="";  //默认客户群聊
  static CardArr loccard=CardArr();
  static init(String userid, String token, void Function(bool state) webcall,
      void Function(bool state) appcall,{String appname=""})  async {
    WidgetsFlutterBinding.ensureInitialized();

    initenv();
    Translate.initTra();
    UserObj.token = token;
    UserObj.userid = userid;
    UserObj.appname=appname;

    HttpWebApi.weblogin().then((value) {
      if (value.data == "loginok") {
        webcall(true);
        _readgroupid();
      } else {
        PhoneUtil.applog("服务号鉴权失败");
        webcall(false);
      }
    });
    BaseJS.apiRecdatainit();
    //服务器增加一个验证接口，初始化验证服务号是否上线，并判断采用url
    //进行登陆服务器，获取临时访问token 加入https 安全访问
  }
  static _readgroupid() async {
    Map<String,dynamic> map=_getgroupid();
    String rec=await HttpWebApi.httpspost(map);
    griupid=RecObj(rec).data;
    //PhoneUtil.applog("读取服务号默认客户群聊$griupid");
  }

  static initenv() async {
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
    PhoneUtil.applog("firebase config:${FirebaseConfig.webConfig.toString()}");
  }

  static Map<String,dynamic> _getgroupid(){
    Map<String,dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.readGroup);
    return map;
  }

}

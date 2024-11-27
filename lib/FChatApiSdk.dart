import 'package:fchatapi/util/PhoneUtil.dart';
import 'package:fchatapi/util/UserObj.dart';
import 'package:fchatapi/webapi/FileObj.dart';
import 'package:fchatapi/webapi/HttpWebApi.dart';
import 'package:fchatapi/webapi/WebCommand.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FChatApiSdk {
  static FileObj fileobj = FileObj();
  static FileArrObj filearrobj = FileArrObj();
  static String griupid="";  //默认客户群聊
  static init(String userid, String token, void Function(bool state) webcall,
      void Function(bool state) appcall) {
    UserObj.token = token;
    UserObj.userid = userid;
    HttpWebApi.weblogin().then((value) {
      PhoneUtil.applog("服务器验证返回$value");
      if (value.data == "loginok") {
        webcall(true);
        _readgroupid();
      } else {
        webcall(false);
      }
    });
    //服务器增加一个验证接口，初始化验证服务号是否上线，并判断采用url
    //进行登陆服务器，获取临时访问token 加入https 安全访问
  }
  static _readgroupid() async {
    Map<String,dynamic> map=_getgroupid();
    String rec=await HttpWebApi.httpspost(map);
    griupid=RecObj(rec).data;
    PhoneUtil.applog("读取服务号默认客户群聊$griupid");
  }

  static Map<String,dynamic> _getgroupid(){
    Map<String,dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.readGroup);
    return map;
  }

}


import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../util/JsonUtil.dart';
import '../util/UIxml.dart';

abstract class UserBase {
  /// Id of your User
  String get id;
  /// Typically the username
  String get name;
  /// The URL to fetch the avatar
  String get avatar;
}

class ChatUser extends UserBase {
  @override
  String id;
  String? username;
  String? fullname;
  String souname = ""; //当用户备注名称，souname显示原来的名字
  String? avatarURL;
  Uint8List? imgbyte;
  File? imgfile;
  bool topstate = false; //是否置顶状态
  Map map = {}; //不能final
  Color? usercolor;
  ChatUser({required this.id, this.username, this.fullname, required avatarURL});


  @override
  String get name => username ?? "";

  @override
  String get avatar => avatarURL ?? "";

  setname(String name) {
    username = name;
  }



  Widget getavatar(
      {double width = 45, double height = 45, double radius = 10}) {
    if (avatarURL!.contains("assets")) {
      Widget w = ClipRRect(
          borderRadius: BorderRadius.circular(radius), //弧度
          child: Image.asset(avatarURL!,
              width: width, height: height, fit: BoxFit.cover));
      return w;
    }
    if (imgbyte != null) {
      Widget w = ClipRRect(
          borderRadius: BorderRadius.circular(radius), //弧度
          child: Image.memory(imgbyte!,
              width: width, height: height, fit: BoxFit.cover));
      return w;
    }
    if (avatarURL!.contains("http")) {
      Widget w = ClipRRect(
          borderRadius: BorderRadius.circular(radius), //弧度
          child: Image.network(
            avatarURL!,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return getStrchatuserimg(Size(width, height));
            },
          ));
      return w;
    }
    return getStrchatuserimg(Size(width, height));
  }


  getJson() {
    map = {};
    map.putIfAbsent("id", () => id);
    map.putIfAbsent("username", () => username);
    map.putIfAbsent("avatarURL", () => avatarURL);
    return map;
  }

  @override
  String toString() {
    return JsonUtil.maptostr(getJson());
  }

  Widget getavatarUrl({double width = 45, double height = 45, double radius = 10,double fontsize=0}) {
    if (avatarURL!.contains("assets")) {
      Widget w = ClipRRect(
          borderRadius: BorderRadius.circular(radius), //弧度
          child: Image.asset(avatarURL!,
              width: width, height: height, fit: BoxFit.cover));
      return w;
    }
    Uint8List? byte = imgbyte;
    if (byte != null) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(radius), //弧度
          child: Image.memory(byte,
              width: width, height: height, fit: BoxFit.cover));
    }
    return getStrchatuserimg(Size(width, height), fontsize: fontsize);
  }

  getStrchatuserimg(Size size,{double fontsize=0}) {
    username ?? "";
    bool isutf8=false;
    String userimgone="";
    double vfsize=UIxml.bestFontsize(size.width/2.5);
    if(fontsize>0){
      vfsize=fontsize;
      //PhoneUtil.applog("头像自定义字体大小$vfsize");
    }
    if(username!.isEmpty) {
      userimgone = "F";
    }else {
      userimgone = username!.substring(0, 1);
      //isutf8 = ChatUserUtil.isValidUtf16(userimgone);
    }
    if(!isutf8){
      int sint=name.length;
      if(sint>=2) {
        sint = 2;
        userimgone= name.substring(0, sint);
      }else{
        userimgone = "F";
      }
    }
    return Container(
      padding: EdgeInsets.all(size.width/5),
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: usercolor,
        borderRadius: const BorderRadius.all(Radius.circular(100)),
      ),
      alignment: Alignment.center,
      child: Text(
        userimgone,
        style: TextStyle(fontSize: vfsize, color: Colors.white),
      ),
    );
  }

}

class ChatUserobj {

  ChatUser? chatuser;
  Map _usermap = {};
  String key = "";
  String type = ChatUserUtil.chatUser;
  String pass = "";
  String paypass = "";
  bool tcplogin = false; //登录状态
  int messageid = 0;
  int maxmessageid = 0;
  String privatekey = "";
  List groupuser = [];
  List groupmain = [];
  String groupmainuser = "";
  String imgmd5 = "";
  String inviteCode = "";
  String token = "";
  String nicename = "";

  String dyobj="";
  ChatUserobj(String userid, String name, String imgurl, this.type) {
    chatuser = ChatUser(id: userid, username: name, avatarURL: null);
    _usermap.putIfAbsent("id", () => userid);
    _usermap.putIfAbsent("name", () => name);
    _usermap.putIfAbsent("imgurl", () => imgurl);
    _usermap.putIfAbsent("key", () => key);
  }


  ChatUserobj.withNameAndAge(Map map) {
    dyobj="from map";
    setUsermap(map);
  }

  setUsermap(Map map) {
    _usermap = map;
    String userid = "";
    // PhoneUtil.applog("用户信息解析$map");
    if (map.containsKey("key")) {
      key = map["key"];
      //PhoneUtil.applog("用户map key value:$key");
    }

    if (map.containsKey("paypass")) {
      paypass = map["paypass"];
    }
    if (map.containsKey("userid")) userid = map["userid"];
    if (map.containsKey("id")) userid = map["id"];
    String name = "";
    if (map.containsKey("name")) {
      name = map["name"];
    }
    if (map.containsKey("username")) {
      name = map["username"];
    }
    String imgurl = "";
    if (map.containsKey("imgurl")) {
      imgurl = map["imgurl"];
    }
    if (map.containsKey("avatarURL")) {
      imgurl = map["avatarURL"];
    }
    if (map.containsKey("type")) {
      type = map["type"];
    } else {
      type = ChatUserUtil.chatUser;
    }
    if (map.containsKey("groupmainuser")) {
      groupmainuser = map["groupmainuser"];
    }
    if (map.containsKey("img")) {
      imgmd5 = map["img"];
    }
    if (map.containsKey("inviteCode")) {
      inviteCode = map["inviteCode"];
    }
    if (map.containsKey("token")) {
      token = map["token"];
    }
    //PhoneUtil.applog("对象名称$name");
    if (name.isEmpty) {
      //PhoneUtil.applog("对象名称空，对象id$userid,什么东西没有userid$map");
    }
    //if(userid=="1564043"){
    //PhoneUtil.applog("社交对象头像初始化:$imgurl,来源$dyobj");
    //}
    chatuser = ChatUser(id: userid, username: name, avatarURL: null);
    if (map.containsKey("pass")) pass = map["pass"];
    if (map.containsKey("nicename")) {
      nicename = map["nicename"];
      if (nicename.isNotEmpty) {
        chatuser!.souname = name;
        chatuser!.username = nicename;
        chatuser!.setname(nicename);
        //PhoneUtil.applog("对象$userid,对象nicename:$nicename");
      } else {
        chatuser!.souname = name;
        chatuser!.setname(name);
      }
    } else {
      chatuser!.souname = name;
      chatuser!.setname(name);
    }

  }

  groupgetJson(List groupuser) {
    List arr = [];
    for (ChatUserobj u in groupuser) {
      arr.add(u.getJson());
    }
    return arr;
  }

  getJson() {
    Map usermap = {};
    String chatstr = chatuser!.toString();
    usermap = JsonUtil.strtoMap(chatstr);
    usermap.putIfAbsent("userid", () => chatuser!.id);
    //PhoneUtil.pclog("用户对象userimg读取消息所以记录:$messageid");
    usermap.putIfAbsent("messageid", () => messageid);
    usermap.putIfAbsent("type", () => type);
    usermap.putIfAbsent("pass", () => pass);
    //usermap.putIfAbsent("img", () => imgmd5);
    //usermap.putIfAbsent("imgurl", () => chatuser!.avatarURL);
    //usermap.putIfAbsent("type", () => type);
    usermap.putIfAbsent("key", () => key);
    //usermap.putIfAbsent("inviteCode", () => inviteCode);
    //usermap.putIfAbsent("token", () => token);
    // if(serviceobj!=null) usermap.putIfAbsent("serviceobj", () => serviceobj.toString());
    if(nicename.isNotEmpty)usermap.putIfAbsent("nicename", () => nicename);
    usermap.putIfAbsent("maxmessageid", () => maxmessageid);
    if (kDebugMode || kProfileMode) usermap.putIfAbsent("debug", () => "debug");
    if (privatekey.isNotEmpty) usermap.putIfAbsent("privatekey", () => privatekey);
    if (groupuser.isNotEmpty) usermap.putIfAbsent("groupuser", () => groupgetJson(groupuser));
    if (groupmain.isNotEmpty) usermap.putIfAbsent("groupmain", () => groupgetJson(groupmain));
    if (groupmainuser.isNotEmpty) usermap.putIfAbsent("groupmainuser", () => groupmainuser);
    return usermap;
  }


  getMessageidJson(int mesid) {
    Map usermap = {};
    String chatstr = chatuser!.toString();
    usermap = JsonUtil.strtoMap(chatstr);
    usermap.putIfAbsent("userid", () => chatuser!.id);
    usermap.putIfAbsent("messageid", () => mesid);
    usermap.putIfAbsent("type", () => type);
    usermap.putIfAbsent("pass", () => pass);
    usermap.putIfAbsent("img", () => imgmd5);
    usermap.putIfAbsent("type", () => type);
    usermap.putIfAbsent("key", () => key);
    if (kDebugMode || kProfileMode) usermap.putIfAbsent("debug", () => "debug");
    if (privatekey.isNotEmpty) usermap.putIfAbsent("privatekey", () => privatekey);
    if (groupuser.isNotEmpty) usermap.putIfAbsent("groupuser", () => groupgetJson(groupuser));
    if (groupmain.isNotEmpty) usermap.putIfAbsent("groupmain", () => groupgetJson(groupmain));
    if (groupmainuser.isNotEmpty) usermap.putIfAbsent("groupmainuser", () => groupmainuser);
    return usermap;
  }

  @override
  String toString() {
    Map map = getJson();
    String str = JsonUtil.maptostr(map);
    return str;
  }


}

class ChatUserUtil {
  static ChatUserobj? nowuser; //当期本地用户
  static List<ChatUserobj> userobjarr = []; //聊天用户，群聊，对象集合
  static List<ChatUserobj> userobjAll = []; //所有有好友，群聊用户，群聊非好友信息
  static List<ChatUserobj> grouparr = []; //群聊获取信息参数
  static List<ChatUserobj> fuserarr = []; //好友对象，仅用户
  static List groupmainarr = []; //当群主，后赶礼的群聊集合,自己当群主
  static late ChatUserobj? serviceUser;
  static late ChatUser wordleservice;
  static late ChatUser exchangeservice;
  static late ChatUser myWalletservice;
  static const chatUser = "chatUser"; //聊天用户
  static const chatGroup = "chatGroup"; //聊天群聊对象
  static const chatMerchant = "chatMerchant"; //聊天商户号
  static String userimagebase64 = ""; //初始化头像内容存储
  static List<imgobj> userimgarr = []; //用户头像缓冲
  static Map locUserinfo = {}; //本地用户信息
  static Map avatarMap = {}; //缓存用户头像bytes


}

class imgobj {
  String id;
  Widget wobj;
  imgobj(this.id, this.wobj);
}


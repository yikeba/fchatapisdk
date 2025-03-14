import 'package:fchatapi/util/Translate.dart';
import 'package:fchatapi/util/UserObj.dart';
import 'package:fchatapi/webapi/HttpWebApi.dart';
import 'package:fchatapi/webapi/StripeUtil/WebPayUtil.dart';
import 'package:fchatapi/webapi/WebCommand.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../Util/PhoneUtil.dart';
import '../WidgetUtil/CountodwnCached.dart';
import '../util/Tools.dart';
import '../webapi/ChatUserobj.dart';


class Weblogin extends StatefulWidget {
  final Function(Map user) onloginstate; // 传入的回调函数
  bool isMerchant = true; //是否验证登录必须为服务号所有人
  Weblogin({Key? key, required this.onloginstate, this.isMerchant=true})
      : super(key: key);

  @override
  _applogin createState() => _applogin();
}

class _applogin extends State<Weblogin> {
  Color selColor = const Color(0xFF3BB815);
  String meqrstr = "";
  String logintoken = "";
  bool isstate = false;
  int downint = 100000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      postlogin();
      if (mounted) {
        setState(() {

        });
      }
    });
  }

  postlogin() async {
    isstate = true;
    downint = 100000;
    logintoken = Tools.generateRandomString(73); //生成一个token登录编码上传服务器
    meqrstr = "pclogin:$logintoken";
    Map map = {};
    map.putIfAbsent("pclogin", () => logintoken);
    for (;;) {
      await Future.delayed(const Duration(milliseconds: 5000));
      if (!isstate) break;
      Map<String, dynamic>sendmap = WebPayUtil.getDataMap(
          map, WebCommand.weblogin);
      String rec = await WebPayUtil.httpFchatserver(sendmap);
      RecObj recobj = RecObj(rec);
      if (!recobj.json.containsKey("userid")) continue;
      ChatUserobj user = ChatUserobj.withNameAndAge(recobj.json);
      if (user.chatuser != null) {
        if (user.chatuser!.id.isNotEmpty && !widget.isMerchant) {
          widget.onloginstate(recobj.json);
          break;
        }
        if (user.chatuser!.id == UserObj.userid && widget.isMerchant) {
          widget.onloginstate(recobj.json);
        } else {
          _showSnackbar("账户没有权限登录");
          isstate = false;
          widget.onloginstate({});
        }
        break;
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    super.dispose();
  }

  _setQR() {
    if (isstate) {
      return QrImageView(
        data: meqrstr,
        foregroundColor: Colors.white,
        // 自定义二维码颜色
        backgroundColor: Colors.black,
        version: QrVersions.auto,
        size: 180,
        gapless: false,
        embeddedImageStyle: const QrEmbeddedImageStyle(
          size: Size(100, 100),
          color: Colors.transparent,
        ),
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      );
    } else {
      return InkWell(
        onTap: () {
          postlogin();
          if (mounted) {
            setState(() {

            });
          }
        },
        child: const Icon(
          Icons.refresh,
          size: 50,
        ),
      );
    }
  }

  _setDownint() {
    if (isstate) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(Translate.show("有效时间") + ":"),
          CountodwnCached(
            key: ValueKey(Tools.generateRandomString(30)),
            downtime: downint,
            txtstyle: const TextStyle(fontSize: 12),
            callBack: (String value) async {
              isstate = false;
              downint = 0;
              PhoneUtil.applog("pc登录扫码倒计时$value");
              if (mounted) {
                setState(() {});
              }
            },
          ),
        ],
      );
    } else {
      return Text('');
    }
  }


  getLoginUI() {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.center,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 1,
          height: 30,
        ),
        Text(UserObj.appname,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        const SizedBox(
          width: 1,
          height: 20,
        ),
        _setQR(),
        const SizedBox(
          width: 1,
          height: 30,
        ),
        _setDownint(),
        const SizedBox(
          width: 1,
          height: 30,
        ),
        ElevatedButton(
          onPressed: () async {
            Tools.openChrome("https://www.freechat.cloud/");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // 设置圆角半径为10
            ),
            padding: const EdgeInsets.all(12), // 控制按钮大小
          ),
          child: Text(
            Translate.show("点击下载移动端下载安装"),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: getLoginUI(),
      ),
    );
  }
}

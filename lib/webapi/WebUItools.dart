import 'package:fchatapi/FChatApiSdk.dart';
import 'package:fchatapi/Login/WebLogin.dart';
import 'package:fchatapi/Util/JsonUtil.dart';
import 'package:fchatapi/Util/PhoneUtil.dart';
import 'package:fchatapi/webapi/FChatAddress.dart';
import 'package:fchatapi/webapi/SendMessage.dart';
import 'package:fchatapi/webapi/StripeUtil/WebPay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../WidgetUtil/MapScreen.dart';
import '../appapi/PayObj.dart';
import '../appapi/SendOrder.dart';
import 'PayHtmlObj.dart';
import 'StripeUtil/CardListWidget.dart';
import 'StripeUtil/WebPayPage.dart';
import 'package:universal_html/html.dart' as html;
class WebUItools{

  static openWebpay(BuildContext context,Widget? order,PayHtmlObj? pobj) async {
    //打开插件支付
    if(FChatApiSdk.isFchatBrower && pobj!=null){
      PayObj fchatpay=PayObj();
      fchatpay.amount=pobj.money;
      fchatpay.paytext=pobj.paystr;
      fchatpay.pay((value){
        Map recmap=JsonUtil.strtoMap(value);
        String payid=recmap["payid"];
        String url = "${pobj.probj!.returnurl}&payid=$payid";
        PhoneUtil.applog("app支付回调通知，本地进行验证$payid");
        PhoneUtil.applog("网页服务号验证支付url$url");
        html.window.location.href = url;
        //发送消息到预定客户
        Sendorder(payid,pobj.money,pobj.paystr,url).send((value){
          PhoneUtil.applog("发送订单消息到app，收到回复$value");
        });
      });
    }else {
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Webpaypage(cardobj: null, order: order, pobj: pobj);
          },
        ),
      );
    }
  }

  static openWeblogin(BuildContext context) async {
    //打开钱包账户
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          //return WebpayScreen(cardobj: null,order: order,pobj:pobj);
          return Weblogin(onloginstate: (Map state) {

          },);
        },
      ),
    );
  }

  static openMap(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SelectLocationPage();
        },
      ),
    );
  }

  static opencardlist(BuildContext context,Widget? order,PayHtmlObj? pobj) async {
    //打开钱包账户
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return BankCardScreen();
        },
      ),
    );
  }

}
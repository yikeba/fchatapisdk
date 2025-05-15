import 'package:fchatapi/FChatApiSdk.dart';
import 'package:fchatapi/Login/WebLogin.dart';
import 'package:fchatapi/Util/JsonUtil.dart';
import 'package:fchatapi/webapi/FChatAddress.dart';
import 'package:fchatapi/webapi/SendMessage.dart';
import 'package:fchatapi/webapi/StripeUtil/WebPay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../WidgetUtil/MapScreen.dart';
import '../appapi/PayObj.dart';
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
        html.window.location.href = url;
        //发送消息到客户服务号
        String text="Orderid: $payid \r\n Procudt: ${pobj.paystr} \r\n Payment Amount: ${pobj.money} \r\n Order Url: $url";
        SendMessage(payid).send(text);

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
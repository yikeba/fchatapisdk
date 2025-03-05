import 'package:fchatapi/Login/WebLogin.dart';
import 'package:fchatapi/webapi/FChatAddress.dart';
import 'package:fchatapi/webapi/StripeUtil/WebPay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'PayHtmlObj.dart';
import 'StripeUtil/CardListWidget.dart';
import 'StripeUtil/WebPayPage.dart';

class WebUItools{

  static openWebpay(BuildContext context,Widget? order,PayHtmlObj? pobj) async {
    //打开钱包账户
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          //return WebpayScreen(cardobj: null,order: order,pobj:pobj);
          return Webpaypage(cardobj: null,order: order,pobj:pobj);
        },
      ),
    );
  }

  static openWeblogin(BuildContext context) async {
    //打开钱包账户
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          //return WebpayScreen(cardobj: null,order: order,pobj:pobj);
          return Weblogin(onloginstate: (bool state) {

          },);
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
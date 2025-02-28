import 'package:fchatapi/webapi/FChatAddress.dart';
import 'package:fchatapi/webapi/StripeUtil/WebPay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'PayHtmlObj.dart';
import 'StripeUtil/CardListWidget.dart';

class WebUItools{

  static openWebpay(BuildContext context,Widget? order,PayHtmlObj? pobj) async {
    //打开钱包账户
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return WebpayScreen(cardobj: null,order: order,pobj:pobj);
        },
      ),
    );
  }

  static opencardlist(BuildContext context,Widget? order,FChatAddress? fchataddress) async {
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
import 'package:fchatapi/webapi/StripeUtil/WebPay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'StripeUtil/CardListWidget.dart';

class WebUItools{

  static openWebpay(BuildContext context) async {
    //打开钱包账户
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return WebpayScreen(cardobj: null);
        },
      ),
    );
  }

  static opencardlist(BuildContext context) async {
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

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fchatapi/webapi/PayHtmlObj.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../Util/JsonUtil.dart';
import '../../Util/PhoneUtil.dart';
import '../../util/UserObj.dart';
import '../HttpWebApi.dart';
import '../WebCommand.dart';
import 'CardObj.dart';
import 'dart:js' as js;


class CardPay{
  Future<Map> handlePayment(PayHtmlObj pobj,CardObj card) async {

    Map<String,dynamic> cardmap={};
    cardmap.putIfAbsent("amount", ()=> JsonUtil.getmoneyint(pobj.money));
    cardmap.putIfAbsent("id", ()=> card.getpaymentMethodID());
    //cardmap.putIfAbsent("customerId", ()=> card.customerid);
    cardmap.putIfAbsent("payid", ()=> pobj.payid);
    cardmap.putIfAbsent("currency", ()=> "USD");
    Map<String,dynamic> sendmap=_getDataMap(cardmap);
    String rec=await _createStripnOrder(sendmap);
    RecObj robj=RecObj(rec);
    PhoneUtil.applog("返回card支付内容${robj.json}");

    final billingDetails = BillingDetails(
      email: pobj.fChatAddress!.email,
      phone: pobj.fChatAddress!.phone,
      name:pobj.fChatAddress!.consumer,

    ); // mo mock
   /* final shippingDetails =ShippingDetails(
      name:pobj.paystr,
      address: Address(
        city: 'Houston',
        country: 'US',
        line1: '1459  Circle Drive',
        line2: '',
        state: 'Texas',
        postalCode: '77063',
      ),

    );*/
    final paymentIntent = await Stripe.instance.confirmPayment(
      paymentIntentClientSecret:robj.json['client_secret'],
      data: PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(
          billingDetails: billingDetails,
         // shippingDetails: shippingDetails,
        ),
      ),
    );

    PhoneUtil.applog("处理支付后续工作$paymentIntent");
    //{amount_details: {tip: {}}, metadata: {}, livemode: true, amount_capturable: 0, latest_charge: ch_3QpMw1LARWDrZ1N91aVEGkY5, automatic_payment_methods: {allow_redirects: always, enabled: true}, currency: usd, client_secret: pi_3QpMw1LARWDrZ1N91b7L08xW_secret_tPykiz7wmuD9YEwnTHUARWsZj, id: pi_3QpMw1LARWDrZ1N91b7L08xW, payment_method_options: {link: {}, card: {request_three_d_secure: automatic}}, payid: 47652231ijcp3q9i, payment_method: pm_1QpM0zLARWDrZ1N9Ytj6Cad8, capture_method: automatic_async, amount: 150, created: 1738817009, payment_method_types: [card, link], amount_received: 150, confirmation_method: manual, payment_method_configuration_details: {id: pmc_1Qi91uLARWDrZ1N9t1yPYzdZ}, object: payment_intent, status: succeeded}
    return robj.json;
  }



  Map<String, dynamic> _getDataMap(Map sendmap) {
    Map<String, dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.stripeorder);
    String data=JsonUtil.maptostr(sendmap);
    data=JsonUtil.setbase64(data);
    map.putIfAbsent("data", ()=>data);
    PhoneUtil.applog("发起银行卡支付:$map");
    return map;
  }

  Future<String> _createStripnOrder(Map<String,dynamic> map) async {
    FormData formData = FormData.fromMap(map);
    String url = HttpWebApi.geturl();
    String authHeader = 'Bearer ${UserObj.servertoken}'; // 设置 Bearer Token
    try {
      Dio dio = Dio();
      Future<Response> res = dio.post(
        url,
        options: Options(
          sendTimeout: const Duration(minutes: 10),
          receiveTimeout: const Duration(minutes:  10),
          method: "POST",
          headers: {
            'Content-Type': 'multipart/form-data',
            "Authorization": authHeader
          },
        ),
        data: formData,
        onReceiveProgress: (int received, int total) {

        },
      );
      return res.then((value) {
        try {
          if (value.statusCode == 200) {
            return value.data.toString();
          } else {
            PhoneUtil.applog("返回类型：${value.data}");
          }
        } catch (e) {
          PhoneUtil.applog("返回错误value 错误$e");
        }
        return "err";
      });
    } on DioError catch (dioError) {
      print("识别到 DioError catch: ${dioError.message}");

    }
    return "err";
  }


}


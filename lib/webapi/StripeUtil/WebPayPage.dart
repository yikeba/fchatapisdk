
import 'package:fchatapi/Util/JsonUtil.dart';
import 'package:fchatapi/WidgetUtil/CheckWidget.dart';
import 'package:fchatapi/util/Tools.dart';
import 'package:fchatapi/util/Translate.dart';
import 'package:fchatapi/webapi/Bank/ABA_KH.dart';
import 'package:fchatapi/webapi/StripeUtil/CookieStorage.dart';
import 'package:fchatapi/webapi/StripeUtil/WebPayUtil.dart';
import 'package:fchatapi/webapi/WebUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../FChatApiSdk.dart';
import '../../WidgetUtil/AutoWaitWidget.dart';
import '../../util/PhoneUtil.dart';
import '../HttpWebApi.dart';
import '../PayHtmlObj.dart';
import '../WebCommand.dart';
import 'CardObj.dart';
import 'LoadButton.dart';
import 'dart:html' as html;

class Webpaypage extends StatefulWidget {
  CardObj? cardobj;
  Widget? order;
  PayHtmlObj? pobj;
  Webpaypage({super.key, required this.cardobj, this.order,this.pobj});

  @override
  _WebhookPaymentScreenState createState() => _WebhookPaymentScreenState();
}

class _WebhookPaymentScreenState extends State<Webpaypage> {
  //bool? _saveCard = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  double fontsize = 13;
  String cardnumber = "";
  Widget orderheight = const SizedBox(
    height: 20,
  );
  double width = 512;
  double height = 0;
  bool isCardinput=false;
  bool isstripestate=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.order == null) {
      widget.order = const SizedBox(
        width: 1,
      );
      orderheight = const SizedBox(
        width: 1,
      );
    }
  /*  if (widget.cardobj == null) {
      String? cardinfo = CookieStorage.getCookie("fchat.card");
      if (cardinfo != null) {
        //PhoneUtil.applog("读取到本地cookie 数据$cardinfo");
        widget.cardobj = CardObj.decryptCard(cardinfo);
        cardnumber = widget.cardobj!.maskCardNumber();
      } else {

        widget.cardobj = CardObj();
        widget.cardobj!.cardHolderName=widget.pobj!.fChatAddress!.consumer;
        PhoneUtil.applog("初始化赋予银行卡客户名称${widget.cardobj!.cardHolderName}");
      }
    }*/
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      String stripekey=await WebPayUtil.readstripekey();
      Stripe.publishableKey=stripekey;
      Stripe.urlScheme = 'flutterstripe';
      await Stripe.instance.applySettings();
      await WebPayUtil.getWebcreateWebPaymentIntent(widget.pobj!);

      isstripestate=true;

    });

  }

  List initcards() {
    List arr = [];
    arr.add("assets/pay/visa.png");
    arr.add("assets/pay/master.png");
    arr.add("assets/pay/fcb.png");
    arr.add("assets/pay/unionpay.png");
    arr.add("assets/pay/discover.png");
    return arr;
  }

  String _getcardnum() {
    if (cardnumber.isNotEmpty) return "";
    if (widget.cardobj == null) return "";
    if (widget.cardobj!.cardNumber.isNotEmpty) return widget.cardobj!.cardNumber;
    return "";
  }

  String _getHetext() {
    if (cardnumber.isNotEmpty) return cardnumber;
    return 'XXXX XXXX XXXX 1234';
  }

  List<Widget> cardarr() {
    List arr = initcards();
    List<Widget> cwidget = [];
    for (String url in arr) {
      Widget im = Image.asset(
        url,
        width: 30,
        height: 30,
        fit: BoxFit.fill,
        package: "fchatapi",
      );
      cwidget.add(im);
      cwidget.add(const SizedBox(width: 5));
    }
    return cwidget;
  }

  _setABA() {
    if(WebUtil.isMobileiBrowser()) {
      return Row(children: [
        // 产品图片
        const SizedBox(width: 20),
        Image.asset(
          "assets/pay/aba.png",
          width: 50,
          height: 50,
          fit: BoxFit.fill,
          package: "fchatapi",
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          child: Text(
            Translate.show('去ABA银行支付'),
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
        const SizedBox(width: 20),
      ]);
    }else{
      return SizedBox(width: 1,);
    }
  }

  Widget _getCardInput(void Function(InputCard value) callCard){
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: cardarr(),
      ),
    );
  }

  InputCard inputCard=InputCard();
  Widget old_getCardInput(void Function(InputCard value) callCard){
    return  Container(
      width: width,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: CreditCardForm(
        formKey: formKey,
        obscureCvv: true,
        obscureNumber: false,
        cardNumber: _getcardnum(),
        cvvCode: widget.cardobj?.cvvCode ?? "",
        isHolderNameVisible: true,
        isCardNumberVisible: true,
        isExpiryDateVisible: true,
        cardHolderName: widget.cardobj?.cardHolderName ?? widget.pobj!.fChatAddress!.consumer,
        expiryDate: widget.cardobj?.expiryDate ?? "",
        onFormComplete: () {
          inputCard.state=true;
          callCard(inputCard);
          print("收到信用卡完成通知");
        },
        inputConfiguration: InputConfiguration(
          cardNumberDecoration: InputDecoration(
            labelText: 'Card Numer',
            hintText: _getHetext(),
            labelStyle: TextStyle(
                fontSize: fontsize, color: Colors.white),
            hintStyle: TextStyle(
                fontSize: fontsize, color: Colors.white),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            suffixIconConstraints: BoxConstraints(minWidth: 70),
            suffix: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: cardarr(),
              ),
            ),
          ),
          expiryDateDecoration: InputDecoration(
            labelText: 'Expired Date',
            hintText: 'XX/XX',
            labelStyle: TextStyle(
                fontSize: fontsize, color: Colors.white),
            hintStyle: TextStyle(
                fontSize: fontsize, color: Colors.white),
          ),
          cvvCodeDecoration: InputDecoration(
            labelText: 'CVV',
            hintText: 'XXX',
            labelStyle: TextStyle(
                fontSize: fontsize, color: Colors.white),
            hintStyle: TextStyle(
                fontSize: fontsize, color: Colors.white),
          ),
          cardHolderDecoration: InputDecoration(
            labelText: 'Card Holder',
            labelStyle: TextStyle(
                fontSize: fontsize, color: Colors.white),
            hintStyle: TextStyle(
                fontSize: fontsize, color: Colors.white),
          ),
        ),
        onCreditCardModelChange: (CreditCardModel creditCardModel){
          //inputCard=InputCard(creditCardModel, false);

          callCard(inputCard);
        },
      ),
    );
  }
  bool iscard=false;
  bool isaba=false;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 512) {
      width = MediaQuery.of(context).size.width;
    }
    // height=MediaQuery.of(context).size.height;
    //PhoneUtil.applog("显示UI高度$height");
    return Scaffold(
      //  appBar: AppBar(title: const Text("网页支付")),
        backgroundColor: Colors.transparent,
        body: Align(
            alignment: Alignment.topCenter, // 底部居中
            child: Container(
                alignment: Alignment.topCenter,
                color: Colors.blueGrey,
                width: width,
                // height: height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 水平居中
                  mainAxisAlignment: MainAxisAlignment.start, // 从上到下排列
                  children: [
                    CheckTextWidget(key:ValueKey(Tools.generateRandomString(70)),initialValue: iscard, onChanged: (state){
                      iscard=state;
                      isaba=false;
                      setState(() {

                      });
                    }, label:"信用卡/借记卡", child:_getCardInput((value){
                      PhoneUtil.applog("信用卡输入完毕${value.creditCardModel}，完成状态${value.state}");
                      if(value.state){

                        isCardinput=value.state;
                        return;
                      }
                      //onCreditCardModelChange(value.creditCardModel);

                    })),
                    const SizedBox(height: 1),
                    if (WebUtil.isMobileiBrowser())
                      CheckTextWidget(
                        key: ValueKey(Tools.generateRandomString(70)),
                        initialValue: isaba,
                        onChanged: (state) {
                          setState(() {
                            isaba = state;
                            iscard = false;
                          });
                        },
                        label: "ABA银行",
                        child: _setABA(),
                      ),
                    const SizedBox(height: 3),
                    widget.order!,
                    const Spacer(),   // 占据剩余空间
                    Align(
                        alignment: Alignment.bottomCenter,
                        child:Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 0.3,
                            padding: const EdgeInsets.all(15),
                            child: LoadingButton(
                              onPressed: pay,
                              text: '支付',
                            )
                        )),
                    // 底部添加些空间
                    const SizedBox(height: 5),
                  ],
                )
            )));
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    widget.cardobj!.cardNumber = creditCardModel.cardNumber;
    widget.cardobj!.expiryDate = creditCardModel.expiryDate;
    widget.cardobj!.cardHolderName = creditCardModel.cardHolderName;
    widget.cardobj!.cvvCode = creditCardModel.cvvCode;
    widget.cardobj!.isCvvFocused = creditCardModel.isCvvFocused;
  }



  Future<PayHtmlObj?> pay() async {
    if(widget.pobj!=null) {
      bool ispayorder=await widget.pobj!.creatPayorder();
      //Tools.showSnackbar(context, Translate.show("创建完毕支付流水点"));
      if(ispayorder) {
        if (isaba) {
          bool isopen = await ABA_KH.abapayweb(context,widget.pobj!.money, widget.pobj!.payid);
          //Tools.showSnackbar(context, Translate.show("打开aba应用进行支付"));
          if (isopen) {
            //bool ispaystatus=await watiAba(widget.pobj!.payid);
            //if(ispaystatus) {
              String url = "${widget.pobj!.probj!.returnurl}&payid=${widget
                  .pobj!.payid}";
              await Tools.openChrome(url);
           // }else{
            //  return null;
           // }
          } else {
           _showSnackbar(Translate.show("打开ABA银行失败"));
          }
        } else {
          AutoWaitWidget.autoStrProgress("正在跳转到银行卡支付", context);
          StripeUrlObj stripeurl = await getStripPayUrl();
          AutoWaitWidget.closeProgress();
          if(WebUtil.isSafari()){
            html.window.location.href = stripeurl.url;
          }else{
            Tools.openChrome(stripeurl.url);
          }
        }
      }else{
        _showSnackbar(Translate.show("创建支付订单失败，请稍后再试"));
      }
    }
    return null;
  }

  getStripPayUrl() async {
    StripeUrlObj? stripeurl;
      String? cardurl=CookieStorage.getCookie("cardurl");
      if(cardurl!=null) {
        if (cardurl.isNotEmpty) {
           stripeurl=StripeUrlObj(JsonUtil.strtoMap(cardurl));
           PhoneUtil.applog("返回网络支付参数$stripeurl");
        }
      }
      Map map={};
      if(stripeurl!=null) {
        map.putIfAbsent("phone", () => stripeurl!.phone);
      }else{
        map.putIfAbsent("phone", () => widget.pobj!.fChatAddress!.phone);
      }
      map.putIfAbsent("product", ()=> widget.pobj!.paystr);

      int moneyint=JsonUtil.getmoneyint(widget.pobj!.money);
      //PhoneUtil.applog("返回网络支付金额:${widget.pobj!.money},分金额${moneyint}");
      map.putIfAbsent("amount", ()=> moneyint);
      if(stripeurl!=null){
        map.putIfAbsent("id", () => stripeurl!.customerId);
      }else {
        map.putIfAbsent("id", () => "");
      }
      map.putIfAbsent("surl", ()=> "${widget.pobj!.probj!.returnurl}&session_id={CHECKOUT_SESSION_ID}");
      map.putIfAbsent("curl", ()=> widget.pobj!.probj!.locurl);
      map.putIfAbsent("currency", ()=> "usd");
      map.putIfAbsent("payid", ()=> widget.pobj!.payid);
      Map<String,dynamic> sendmap= WebPayUtil.getDataMap(map,WebCommand.createWebPayUrl);
      String rec=await  WebPayUtil.httpFchatserver(sendmap);
      RecObj robj=RecObj(rec);
      PhoneUtil.applog("返回网络支付参数$rec");
      stripeurl=StripeUrlObj(robj.json);
      //CookieStorage.saveToCookie("cardurl", stripeurl.toJson());  //保存本地cookie
      return StripeUrlObj(robj.json);
  }
}


class StripeUrlObj{
  String url="";
  String customerId="";
  String phone="";
  StripeUrlObj(Map map){
    url=map["url"];
    customerId=map["id"];
    phone=map["phone"];
  }

  String toJson(){
    Map ret={};
    ret.putIfAbsent("url", ()=>url);
    ret.putIfAbsent("id",()=>customerId);
    ret.putIfAbsent("phone", ()=>phone);
    return JsonUtil.maptostr(ret);
  }
}

class InputCard{
  CreditCardModel? creditCardModel;
  bool state=false;
  CardFieldInputDetails? card;
//InputCard(this.creditCardModel,this.state);

}
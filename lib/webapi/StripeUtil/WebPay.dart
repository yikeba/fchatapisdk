
import 'package:fchatapi/WidgetUtil/CheckWidget.dart';
import 'package:fchatapi/util/Tools.dart';
import 'package:fchatapi/webapi/Bank/ABA_KH.dart';
import 'package:fchatapi/webapi/StripeUtil/CardPay.dart';
import 'package:fchatapi/webapi/StripeUtil/CookieStorage.dart';
import 'package:fchatapi/webapi/StripeUtil/WebPayUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../FChatApiSdk.dart';
import '../../util/PhoneUtil.dart';
import '../PayHtmlObj.dart';
import 'CardObj.dart';
import 'LoadButton.dart';

class WebpayScreen extends StatefulWidget {
  CardObj? cardobj;
  Widget? order;
  PayHtmlObj? pobj;
  WebpayScreen({super.key, required this.cardobj, this.order,this.pobj});

  @override
  _WebhookPaymentScreenState createState() => _WebhookPaymentScreenState();
}

class _WebhookPaymentScreenState extends State<WebpayScreen> {
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
    if (widget.cardobj == null) {
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
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      String stripekey=await WebPayUtil.readstripekey();
      Stripe.publishableKey=stripekey;
      Stripe.urlScheme = 'flutterstripe';
      await Stripe.instance.applySettings();
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
            child: const Text(
              '点击去ABA银行支付',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
        ]);
  }

  InputCard? inputCard;
  Widget _getCardInput(void Function(InputCard value) callCard){
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
          inputCard!.state=true;
          callCard(inputCard!);
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
          inputCard=InputCard(creditCardModel, false);
          callCard(inputCard!);
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
                            onCreditCardModelChange(value.creditCardModel);

                        })),
                        const SizedBox(height: 1),
                        CheckTextWidget(key:ValueKey(Tools.generateRandomString(70)),initialValue: isaba, onChanged: (state){
                           isaba=state;
                           iscard=false;
                           setState(() {

                           });
                        }, label:"ABA银行", child:_setABA(),),
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
        widget.pobj!.creatPayorder();
        if(isaba) {
          await ABA_KH.abapayweb(context,widget.pobj!.money, widget.pobj!.payid);
          return widget.pobj;
        }else{
           print("银行卡卡号${widget.cardobj!.cardNumber}");
           print("银行卡信息输入${widget.cardobj!.toJson()}");
           if(isCardinput || widget.cardobj!.isCardInfoComplete()){
              FChatApiSdk.loccard.saveCard(widget.cardobj!);  //保存本地cookie
              _showSnackbar("银行卡输入完毕，发起支付等待服务器通知");
              await CardPay().handlePayment(widget.pobj!, widget.cardobj!);
           }else{
             //print("银行卡信息没有输入完善${widget.cardobj!.toJson()}");
             _showSnackbar("请输入完毕银行卡信息，在发起支付");
           }
        }
      }
      return null;
  }
}

class InputCard{
  CreditCardModel creditCardModel;
  bool state=false;
  InputCard(this.creditCardModel,this.state);

}
import 'package:fchatapi/FChatApiSdk.dart';
import 'package:fchatapi/util/JsonUtil.dart';
import 'package:fchatapi/webapi/StripeUtil/CookieStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../util/PhoneUtil.dart';
import 'CardObj.dart';
import 'LoadButton.dart';

class WebpayScreen extends StatefulWidget {
  CardObj? cardobj;

  //WebpayScreen({super.key,required this.cardobj});
  WebpayScreen({super.key, required this.cardobj});

  @override
  _WebhookPaymentScreenState createState() => _WebhookPaymentScreenState();
}

class _WebhookPaymentScreenState extends State<WebpayScreen> {
  //bool? _saveCard = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  double fontsize = 13;
  FocusNode cardFocusNode = FocusNode();
  String cardnumber="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.cardobj == null) {
      String? cardinfo=CookieStorage.getCookie("fchat.card");
      if(cardinfo!=null){
        PhoneUtil.applog("读取到本地cookie 数据$cardinfo");
        widget.cardobj = CardObj.decryptCard(cardinfo);
        cardnumber=widget.cardobj!.maskCardNumber();
      }else {
        PhoneUtil.applog("未读取到本地cookie");
        widget.cardobj = CardObj();
      }
    }
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

  String _getcardnum(){
    if(cardnumber.isNotEmpty) return "";
    if(widget.cardobj==null) return "";
    if(widget.cardobj!.cardNumber.isNotEmpty) return widget.cardobj!.cardNumber;
    return "";
  }
  String _getHetext(){
    if(cardnumber.isNotEmpty) return cardnumber;
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
      cwidget.add(SizedBox(width: 5));
    }
    return cwidget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("网页支付")),
        backgroundColor: Colors.blueGrey,
        body: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min, // 让内容紧凑
          children: [

            Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 0), // 适当减少内边距
                //padding: const EdgeInsets.all(8), // 适当减少内边距
                child: CreditCardForm(
                  formKey: formKey,
                  obscureCvv: true,
                  obscureNumber: false,
                  cardNumber: _getcardnum(),
                  cvvCode: widget.cardobj?.cvvCode ?? "",
                  isHolderNameVisible: true,
                  isCardNumberVisible: true,
                  isExpiryDateVisible: true,
                  cardHolderName: widget.cardobj?.cardHolderName ?? "",
                  expiryDate: widget.cardobj?.expiryDate ?? "",

                  onFormComplete: () {
                    PhoneUtil.applog("信用卡输入完毕");
                    pay();
                  },
                  inputConfiguration: InputConfiguration(
                    cardNumberDecoration: InputDecoration(
                      labelText: 'Card Numer',
                      hintText: _getHetext(),
                      labelStyle:
                          TextStyle(fontSize: fontsize, color: Colors.white),
                      // 缩小标签字体
                      hintStyle:
                          TextStyle(fontSize: fontsize, color: Colors.white),
                      // 缩小提示字体
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      // 调整输入框内边距
                      suffixIconConstraints: BoxConstraints(minWidth: 70),
                      // 限制图标区域宽度
                      suffix: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        // 让输入文字与图标之间有间距
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: cardarr(), // 调用 cardarr() 返回信用卡图标
                        ),
                      ),
                     // enabled: cardnumber.isEmpty,
                    ),
                    expiryDateDecoration: InputDecoration(
                      labelText: 'Expired Date',
                      hintText: 'XX/XX',
                      labelStyle:
                      TextStyle(fontSize: fontsize, color: Colors.white),
                      // 缩小标签字体
                      hintStyle:
                      TextStyle(fontSize: fontsize, color: Colors.white),
                    ),
                    cvvCodeDecoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: 'XXX',
                      labelStyle:
                      TextStyle(fontSize: fontsize, color: Colors.white),
                      // 缩小标签字体
                      hintStyle:
                      TextStyle(fontSize: fontsize, color: Colors.white),
                    ),
                    cardHolderDecoration: InputDecoration(
                      labelText: 'Card Holder',
                      labelStyle:
                      TextStyle(fontSize: fontsize, color: Colors.white),
                      // 缩小标签字体
                      hintStyle:
                      TextStyle(fontSize: fontsize, color: Colors.white),
                    ),

                  ),
                  onCreditCardModelChange: onCreditCardModelChange,

                ),

            ),
            const SizedBox(height: 20),
            Container(
                width: MediaQuery.of(context).size.width * 0.6, // 90% 屏幕宽度
                padding: const EdgeInsets.all(15), // 适当减少内边距
                child: LoadingButton(
                  onPressed: pay,
                  text: '支付',
                )),
          ],
        )));
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      widget.cardobj!.cardNumber = creditCardModel.cardNumber;
      widget.cardobj!.expiryDate = creditCardModel.expiryDate;
      widget.cardobj!.cardHolderName = creditCardModel.cardHolderName;
      widget.cardobj!.cvvCode = creditCardModel.cvvCode;
      widget.cardobj!.isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  Future<void> pay() async {
     FChatApiSdk.loccard.saveCard(widget.cardobj!);
     //String carddata=widget.cardobj!.encryptData();
     //CookieStorage.saveToCookie("fchat.card", carddata);

  }
}

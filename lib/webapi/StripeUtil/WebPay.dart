import 'package:fchatapi/FChatApiSdk.dart';
import 'package:fchatapi/WidgetUtil/CheckWidget.dart';
import 'package:fchatapi/util/Tools.dart';
import 'package:fchatapi/util/UserObj.dart';
import 'package:fchatapi/webapi/Bank/ABA_KH.dart';
import 'package:fchatapi/webapi/FChatAddress.dart';
import 'package:fchatapi/webapi/StripeUtil/CookieStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
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
  FocusNode cardFocusNode = FocusNode();
  String cardnumber = "";
  Widget orderheight = const SizedBox(
    height: 20,
  );
  double width = 512;
  double height = 0;

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

  String _getcardnum() {
    if (cardnumber.isNotEmpty) return "";
    if (widget.cardobj == null) return "";
    if (widget.cardobj!.cardNumber.isNotEmpty)
      return widget.cardobj!.cardNumber;
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

  _getCardInput(){
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
        onCreditCardModelChange: onCreditCardModelChange,
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
                        }, label:"信用卡/借记卡", child:_getCardInput()),
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

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      widget.cardobj!.cardNumber = creditCardModel.cardNumber;
      widget.cardobj!.expiryDate = creditCardModel.expiryDate;
      widget.cardobj!.cardHolderName = creditCardModel.cardHolderName;
      widget.cardobj!.cvvCode = creditCardModel.cvvCode;
      widget.cardobj!.isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  Future<PayHtmlObj?> pay() async {
      if(widget.pobj!=null) {
        //FChatApiSdk.loccard.saveCard(widget.cardobj!);
        widget.pobj!.creatPayorder();
        if(isaba) {
          await ABA_KH.ABApayweb(widget.pobj!.money, widget.pobj!.payid);
          return widget.pobj;
        }else{

        }
      }
      return null;
  }
}

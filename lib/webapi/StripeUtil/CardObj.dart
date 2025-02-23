
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/cupertino.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutter/material.dart';
import '../../util/JsonUtil.dart';
import '../../util/PhoneUtil.dart';
import '../../util/SignUtil.dart';
import '../../util/Tools.dart';
import '../../util/UserObj.dart';


class CardObj {
  String cardNumber = "";
  String expiryDate = "";
  String cardHolderName = "";
  String cvvCode = "";
  bool isCvvFocused = false;
  stripe.CardFieldInputDetails? stripeCard;
  num _expiryMonth = 0;
  num _expiryYear = 0;
  Map paymentMethod={};
  String last4="";
  String paymentMethodID="";
  String customerid="";
  String bank="";
  CardObj();

  CardObj.fromStr(String cardinfo) {
    try {
      String cardstr = decrypt(cardinfo);
      Map map = JsonUtil.strtoMap(cardstr);
      cardNumber = map["CardNumber"];
      cardHolderName=map["postalCode"];
      maskBankCard(cardNumber);
      cvvCode = map["cvc"];
      _expiryYear = map["expiryYear"];
      _expiryMonth = map["expiryMonth"];
      if(map.containsKey("PaymentMethod")){
        paymentMethod=map["PaymentMethod"];
        paymentMethodID=paymentMethod["id"];
      }
      if(map.containsKey("customerid")){
        customerid=map["customerid"];
      }
      if(map.containsKey("bank")){
        bank=map["bank"];
        PhoneUtil.applog("读取到服务器银行名称$bank");
      }else{
        //updatebank();
      }
      expiryDate = "$_expiryMonth/$_expiryYear";
    } catch (e) {
      PhoneUtil.applog("卡信息错误");
    }
  }

  CardObj.decryptCard(String data){

    try {
      String cardinfo=decryptData(data);
      Map map = JsonUtil.strtoMap(cardinfo);
      cardNumber = map["CardNumber"];
      cardHolderName=map["postalCode"];
      maskBankCard(cardNumber);
      cvvCode = map["cvc"];
      _expiryYear = map["expiryYear"];
      _expiryMonth = map["expiryMonth"];
      if(map.containsKey("PaymentMethod")){
        paymentMethod=map["PaymentMethod"];
        paymentMethodID=paymentMethod["id"];
      }
      if(map.containsKey("customerid")){
        customerid=map["customerid"];
      }
      if(map.containsKey("bank")){
        bank=map["bank"];
        PhoneUtil.applog("读取到服务器银行名称$bank");
      }else{
        //updatebank();
      }
      expiryDate = "$_expiryMonth/$_expiryYear";
    } catch (e) {
      PhoneUtil.applog("解密端卡信息错误");
    }
  }

  String getId() {
    return SignUtil.MD5str(cardNumber);
  }

  String maskCardNumber() {
    if (cardNumber.length < 4) {
      return '*' * cardNumber.length; // 如果卡号不足4位，全部用 * 代替
    }
    String masked = '*' * (cardNumber.length - 4) + cardNumber.substring(cardNumber.length - 4);
    return masked;
  }
  initStripCard() {
    try {
      _expiryMonth = JsonUtil.strtodou(expiryDate.split("/")[0]);
      _expiryYear = JsonUtil.strtodou(expiryDate.split("/")[1]);
      stripeCard = stripe.CardFieldInputDetails.fromJson(toJson());
    } catch (e) {
      PhoneUtil.applog("输入卡信息转化为stripe card 错误$e");
    }
  }



  /*Future<String> readBankName() async {
    try {
      String cardcode = cardNumber.replaceAll(" ", "");
      String first6 = cardcode.substring(0, 6);
      String url = "https://lookup.binlist.net/$first6";
      Response res = await NetworkUtil.Geturl(url);
      final map = res.data;
      //Map map=JsonUtil.strtoMap(rec);
      PhoneUtil.applog("读取银行信息返回$map");
      if(map.containsKey("bank")){
        Map bankmap = map["bank"];
        bank=bankmap["name"];
        PhoneUtil.applog("读取银行信息$bank");
        return bank;
      }
    }catch(e){
      return "";
    }
    return "";
  }*/

  stripe.CardFieldInputDetails getStripCard() {
    if (stripeCard == null) initStripCard();
    return stripeCard!;
  }

  stripe.CardDetails getCardDetails() {
    return stripe.CardDetails(
        number: cardNumber,
        expirationYear: _expiryYear.toInt(),
        expirationMonth: _expiryMonth.toInt(),
        cvc: cvvCode);
  }

  Future<Map> creatPaymentMethod() async {
    await stripe.Stripe.instance.dangerouslyUpdateCardDetails(getCardDetails());
    final paymentMethod = await stripe.Stripe.instance.createPaymentMethod(
        params: const stripe.PaymentMethodParams.card(
      paymentMethodData: stripe.PaymentMethodData(),
    ));
    PhoneUtil.applog("返回apple pay支付内容$paymentMethod");
    return paymentMethod.toJson();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    String last4 = cardNumber.substring(cardNumber.length - 4); // 获取最后4位
    map.putIfAbsent("CardNumber", () => cardNumber);
    map.putIfAbsent("number", () => cardNumber);
    map.putIfAbsent("cvc", () => cvvCode);
    map.putIfAbsent("expiryMonth", () => _expiryMonth);
    map.putIfAbsent("expiryYear", () => _expiryYear);
    map.putIfAbsent("expirationMonth", () => _expiryMonth);
    map.putIfAbsent("expirationYear", () => _expiryYear);
    map.putIfAbsent("exp_month", () => _expiryMonth);
    map.putIfAbsent("exp_year", () => _expiryYear);
    map.putIfAbsent("postalCode", () => cardHolderName);
    map.putIfAbsent("last4", () => last4);
    map.putIfAbsent("complete", ()=> true);
    map.putIfAbsent("brand", () => detectCardBrand(cardNumber));
    if(bank.isNotEmpty)map.putIfAbsent("bank", ()=>bank);
    if(paymentMethod.isNotEmpty)map.putIfAbsent("PaymentMethod", ()=>paymentMethod);
    return map;
  }

  getpaymentMethod() async {
    paymentMethod=await creatPaymentMethod();
    return paymentMethod;
  }

  Widget cardwidget({required VoidCallback onTap}) {
    if (stripeCard == null) initStripCard();
    return Card(
      color: Tools.generateRandomDarkColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: getCardBrandIcon(),
        title: Text(
            _getbank(),
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        subtitle: Text(
          "**** **** **** " + last4,
          style: TextStyle(color: Colors.white),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.white),
          onPressed: () {
            onTap();
          },
        ),
      ),
    );
  }
  String _getbank(){
    if(bank.isEmpty){
      return detectCardBrand(cardNumber);
    }
    return bank;
  }

 Widget paycardwidget(BuildContext context, {void Function(bool?)? onTap}) {
    if (stripeCard == null) initStripCard();
    return Card(
      color: Tools.generateRandomDarkColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: getCardBrandIcon(),
        title: Text(
          _getbank(),
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        subtitle: Text(
          "**** **** **** " + last4,
          style: TextStyle(color: Colors.white),
        ),
        trailing: IconButton(
          icon: _getcheck(),
          onPressed: () async {
            PhoneUtil.applog("点击选择支付，卡号$cardNumber");
            if(paymentMethod.isEmpty && customerid.isEmpty){
               if(onTap!=null)onTap(false);
            }else {
              _selectbox=true;
              if(onTap!=null)onTap(null);
              //UIxml.autoProgress(context);
             // CardPay().handlePayment(payobj, this);
             // UIxml.closeProgress();
            }
          },
        ),
      ),
    );
  }
  bool _selectbox=false;
  Widget _getcheck(){
    if(!_selectbox) {
      return Icon(Icons.check_box_outline_blank_outlined, color: Colors.white);
    }else{
      return Icon(Icons.check_box_outlined, color: Colors.white);
    }
  }

  // 显示卡组织 Logo
  Widget getCardBrandIcon() {
    String brand = detectCardBrand(cardNumber);
    switch (brand) {
      case 'Visa':
        return Image.asset('assets/pay/visa.png', height: 30, package: "fchatapi",);
      case 'MasterCard':
        return Image.asset('assets/pay/master.png', height: 30, package: "fchatapi",);
      case 'Amex':
        return Image.asset('assets/pay/amex.png', height: 30, package: "fchatapi",);
      case 'UnionPay':
        return Image.asset('assets/pay/unionpay.png', height: 30, package: "fchatapi",);
      default:
        return Icon(Icons.credit_card, size: 30);
    }
  }

  String detectCardBrand(String? cardNumber) {
    if (cardNumber == null || cardNumber.length < 2) return 'Unknown';
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'MasterCard';
    if (cardNumber.startsWith('3')) return 'Amex';
    if (cardNumber.startsWith('62')) return 'UnionPay'; // 银联
    if (cardNumber.startsWith('6')) return 'Discover';
    return 'Unknown';
  }

  String maskBankCard(String cardNumber) {
    if (cardNumber.length <= 4) {
      return cardNumber; // 如果卡号少于等于4位，直接返回
    }
    last4 = cardNumber.substring(cardNumber.length - 4); // 获取最后4位
    String maskedPart = '*' *
        (cardNumber.length > 16
            ? 16
            : (cardNumber.length - 4)); // 16位以内全部用 * 代替
    String extraPart =
        cardNumber.length > 16 ? cardNumber.substring(16) : ''; // 超出16位的部分正常显示
    return '$maskedPart$last4$extraPart';
  }

  String decrypt(String encryptedBase64) {
    String key = adjustKeyLength(UserObj.servertoken);
    final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(key), mode: encrypt.AESMode.ecb));
    final decrypted = encrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedBase64));
    return decrypted;
  }

  String toString(){
    return JsonUtil.maptostr(toJson());
  }

  String encryptData() {  //加密
    String key = adjustKeyLength(UserObj.servertoken);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key.fromUtf8(key), mode: encrypt.AESMode.ecb),
    );
    final encrypted = encrypter.encrypt(toString());
    return encrypted.base64; // 返回 Base64 编码的加密字符串
  }

  /// **解密数据**
  String decryptData(String encryptedBase64) {
    String key = adjustKeyLength(UserObj.servertoken);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key.fromUtf8(key), mode: encrypt.AESMode.ecb),
    );
    final decrypted = encrypter.decrypt(
      encrypt.Encrypted.fromBase64(encryptedBase64),
    );
    return decrypted;
  }

  String adjustKeyLength(String key) {
    if (key.length > 16) {
      return key.substring(0, 16);
    } else {
      return key.padRight(16, '0'); // 不足补 0
    }
  }
}

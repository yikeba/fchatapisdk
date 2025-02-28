class PayReturnObj{
  //支付回调对象，支付成功后通知服务器的后续处理，
  //1 想其他系统rueturn url 支付成功通知
  //2 或处理自己的服务号业务逻辑
  String returnurl="";  //想其他服务器发送支付成功通知
  String apptag="";     //处理自己小程序标签业务逻辑
  String json="";  //附加内容数据
  //ChatMessage? mes;  //系统通知消息，将有999账户发出
  //ChatInfo?  chatmes;  //自定义回调消息，将自定义发送

  getJson(){
    Map map={};
    if(returnurl.isNotEmpty) map.putIfAbsent("returnurl", () => returnurl);
    if(apptag.isNotEmpty) map.putIfAbsent("apptag", () => apptag);
    if(json.isNotEmpty) map.putIfAbsent("json", () => json);
    // if(mes!=null) map.putIfAbsent("mes", () => mes!.getJson());
    //if(chatmes!=null) map.putIfAbsent("chatmes", () => chatmes!.toString());
    return map;
  }
}

enum PayType {
  topup,
  transfer,
  paytra,
  redenvelope,
  consumption,
  cash,
  scQrtra
}
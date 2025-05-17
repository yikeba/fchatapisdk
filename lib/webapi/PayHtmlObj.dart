

import 'package:dio/dio.dart';
import 'package:fchatapi/util/JsonUtil.dart';
import 'package:fchatapi/util/Tools.dart';
import 'package:fchatapi/webapi/FChatAddress.dart';
import 'package:fchatapi/webapi/WebCommand.dart';

import '../util/DateUtil.dart';
import '../util/PhoneUtil.dart';
import '../util/UserObj.dart';
import 'ChatUserobj.dart';
import 'HttpWebApi.dart';
import 'PayReturnObj.dart';

class PayHtmlObj{
  String payuserid="";  //付款人id
  String payname="";  //付款人姓名或昵称
  String money="";   //付款金额
  ChatUserobj? recobj;
  PayType paytype=PayType.consumption;   //只能是消费
  String paystr="";   //付款说明文字
  String payid="";
  int date=0;
  String currency="USD";
  FChatAddress? fChatAddress;
  PayReturnObj? probj;
  String merchantorder="";   //服务号订单json str
  bool status=false;   //支付流水单支付状态
  PayHtmlObj(this.recobj,String phone,String name){
    payuserid=phone;
    payname=name;
    payid=Tools.generateRandomString(10)+DateUtil.getUTCint().toRadixString(32);
  }
  PayHtmlObj.dart(String userid,String phone,String name){
    recobj=ChatUserobj(userid, name, "", ChatUserUtil.chatUser);
    payuserid=phone;
    payname=name;
    payid=Tools.generateRandomString(10)+DateUtil.getUTCint().toRadixString(32);

  }
  PayHtmlObj.fromJson(Map map){
    payid=map["payid"];
    payuserid=map["payuserid"];
    if(map.containsKey("status")){
      status=map["status"];
    }
    money=map["money"];
    date=map["date"];
    if(map.containsKey("currency")){
      currency=map["currency"];
    }
  }

  getJson(){
    Map map={};
    map.putIfAbsent("appid", () => "728239");
    map.putIfAbsent("payid", () => payid);
    map.putIfAbsent("payuserid", () => payuserid);
    map.putIfAbsent("payname", () => payname);
    map.putIfAbsent("money",()=>money);   //付款金额
    map.putIfAbsent("currency", ()=> currency);
    if(recobj!=null) map.putIfAbsent("recobj", () => recobj!.getJson()); //="";  //收款人id
    map.putIfAbsent("paytype", () => paytype.toString()) ;  //PayType? paytype;   //付款行为（红包，转账，消费。。。）
    map.putIfAbsent("paystr", () => paystr);        //r="";   //付款说明文字
    if(probj!=null) map.putIfAbsent("probj", () => probj!.getJson());
    return map;
  }


  Map<String, dynamic> _getDataMap() {
    Map<String, dynamic> map = {};
    map.putIfAbsent("userid", () => UserObj.userid);
    map.putIfAbsent("command", () => WebCommand.paymentorder);
    String data=JsonUtil.maptostr(getJson());
    data=JsonUtil.setbase64(data);
    map.putIfAbsent("data", ()=>data);
    //print("上传服务器文本map$map");
    return map;
  }

 Future<bool> creatPayorder() async {
    Map<String,dynamic> order=_getDataMap();
    String rec=await _creatPayordert(order);
    PhoneUtil.applog("服务器统一下单返回$rec");
    RecObj robj=RecObj(rec);
    if(robj.json.containsKey("payid")) {
      String recpayid = robj.json["payid"];
      if(recpayid==payid) return true;
    }
    return false;
  }

  Future<String> _creatPayordert(Map<String,dynamic> map) async {
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
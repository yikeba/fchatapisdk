import 'package:dio/dio.dart';
import 'package:fchatapi/webapi/PayHtmlObj.dart';

import '../../Util/JsonUtil.dart';
import '../../Util/PhoneUtil.dart';
import '../../util/UserObj.dart';
import '../HttpWebApi.dart';
import '../WebCommand.dart';
import 'CookieStorage.dart';

class WebPayUtil{

   static bool isLocCard(){  //判断本地是否保存信用卡
     String? cardinfo=CookieStorage.getCookie("fchat.card");
     if(cardinfo==null) return false;
     return true;
   }
   static void delCard(){  //判断本地是否保存信用卡
     CookieStorage.deleteFromStorage("fchat.card");
   }


   static Future<bool> isQuery_payID(String payid) async {
       Map map={};
       map.putIfAbsent("payid", ()=> payid);
       map.putIfAbsent("userid", ()=> UserObj.userid);
       Map<String,dynamic>sendmap=getDataMap(map,WebCommand.payidQuery);
       String rec=await httpFchatserver(sendmap);
       RecObj robj=RecObj(rec);
      // PhoneUtil.applog("返回查询支付流水单状态$rec");
       if(robj.json.containsKey(payid) && robj.json.containsKey("status")){
          return robj.json["status"];
       }
       return false;
   }

   static Future<VerifyPayObj> isverifyPay(String? sessionId,String? payid) async {
     //b必须有一个不能是null
     VerifyPayObj verifyPayObj=VerifyPayObj();
     if (sessionId == null && payid == null) {
        return verifyPayObj;
     }
     sessionId ?? "";
     payid ?? "";
     Map map={};
     //PhoneUtil.applog("发送服务器payid $payid");
     map.putIfAbsent("payid", ()=> payid);
     map.putIfAbsent("sessionid", ()=> sessionId);
     Map<String,dynamic>sendmap=getDataMap(map,WebCommand.verifyPay);
     String rec=await httpFchatserver(sendmap);
     RecObj robj=RecObj(rec);
     if(robj.json.containsKey("payid")){
       if(payid!.isEmpty) payid=robj.json["payid"];
     }else{
       return verifyPayObj;
     }
     verifyPayObj.payid=payid!;
     verifyPayObj.ispay=false;
     if(robj.json.containsKey("status")){
       verifyPayObj.ispay= robj.json["status"];
     }
     return verifyPayObj;
   }
   //通过payid 返回支付对象
   static Future<PayHtmlObj> getPayHtmlObj(String payid) async {
     Map map={};
     map.putIfAbsent("payid", ()=> payid);
     map.putIfAbsent("userid", ()=> UserObj.userid);
     Map<String,dynamic>sendmap=getDataMap(map,WebCommand.payidQuery);
     String rec=await httpFchatserver(sendmap);
     RecObj robj=RecObj(rec);
    // PhoneUtil.applog("返回查询支付流水单状态$rec");
     return PayHtmlObj.fromJson(robj.json);
   }
   static readstripekey() async {
     Map<String,dynamic>sendmap=getDataMap({},WebCommand.readstripekey);
     String rec=await httpFchatserver(sendmap);
     RecObj robj=RecObj(rec);
    // PhoneUtil.applog("读取stripe key 参数${robj.data}");
     return robj.data;
   }

   static Future<Map> getWebcreateWebPaymentIntent(PayHtmlObj pobj) async {
     Map map={};
     map.putIfAbsent("amount",()=> JsonUtil.getmoneyint(pobj.money));
     map.putIfAbsent("currency", ()=> "usd");
     Map<String,dynamic>sendmap= getDataMap({},WebCommand.createWebPaymentIntent);
     String rec=await httpFchatserver(sendmap);
     RecObj robj=RecObj(rec);
    // PhoneUtil.applog("返回web 调用支付申请${robj.json}");
     return robj.json;
   }

   static Map<String, dynamic> getDataMap(Map sendmap,String command) {
     Map<String, dynamic> map = {};
     map.putIfAbsent("userid", () => UserObj.userid);
     map.putIfAbsent("command", () => command);
     String data=JsonUtil.maptostr(sendmap);
     data=JsonUtil.setbase64(data);
     map.putIfAbsent("data", ()=>data);
     return map;
   }

   static Future<String> httpFchatserver(Map<String,dynamic> map) async {
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

class VerifyPayObj{
   String payid="";
   bool ispay=false;
}
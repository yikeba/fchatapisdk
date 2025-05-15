import '../Util/PhoneUtil.dart';
import 'HttpWebApi.dart';
import 'StripeUtil/WebPayUtil.dart';
import 'WebCommand.dart';

class SendMessage{
   String payid;
   SendMessage(this.payid);
   send(String text) async {
     Map map={};
     map.putIfAbsent("payid", ()=> payid);
     map.putIfAbsent("text", ()=> text);
     Map<String, dynamic>sendmap = WebPayUtil.getDataMap(
         map, WebCommand.sendmessage);
     String rec = await WebPayUtil.httpFchatserver(sendmap);
     RecObj recobj = RecObj(rec);
     PhoneUtil.applog("发送订单消息通知返回${recobj.data}");
   }

}
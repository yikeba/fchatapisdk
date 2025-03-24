import '../Util/PhoneUtil.dart';
import '../webapi/HttpWebApi.dart';
import '../webapi/StripeUtil/WebPayUtil.dart';
import '../webapi/WebCommand.dart';

class ZtoApi{

  static ztocreatorder(String data) async {
    Map map={};
    map.putIfAbsent("data",()=> data);
    map.putIfAbsent("express", ()=>"zto");
    Map<String,dynamic>sendmap= WebPayUtil.getDataMap(map,WebCommand.expresszto);
    String rec=await WebPayUtil.httpFchatserver(sendmap);
    RecObj robj=RecObj(rec);
    PhoneUtil.applog("快递返回情况${robj.json}");
    return robj.json;
  }
}
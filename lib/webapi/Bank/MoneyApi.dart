import '../../Util/PhoneUtil.dart';
import '../HttpWebApi.dart';
import '../StripeUtil/WebPayUtil.dart';
import '../WebCommand.dart';

class MoneyApi{
  //订单资金读取
  static Future<Map>  ordermoney() async {
    Map map={};
    map.putIfAbsent("action", ()=> "order");
    Map<String,dynamic>sendmap=WebPayUtil.getDataMap(map,WebCommand.moneymanagement);
    String rec=await WebPayUtil.httpFchatserver(sendmap);
    RecObj robj=RecObj(rec);
    PhoneUtil.applog("读取订单原始资金数据:${robj.data}");
    PhoneUtil.applog("读取订单资金数据${robj.json}");
    return robj.json;

  }

}
import 'package:fchatapi/Util/PhoneUtil.dart';

import 'HttpWebApi.dart';
import 'StripeUtil/WebPayUtil.dart';
import 'WebCommand.dart';

class ShortUrl{

  static Future<Map> creatShortUrl(String url) async {
    Map map={};
    map.putIfAbsent("url", ()=>url);
    Map<String, dynamic>sendmap = WebPayUtil.getDataMap(
        map, WebCommand.shorturl);
    String rec = await WebPayUtil.httpFchatserver(sendmap);
    RecObj recobj = RecObj(rec);
    PhoneUtil.applog("返回短链接${recobj.json}");
    return recobj.json;
  }


}
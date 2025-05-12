import '../Util/JsonUtil.dart';
import '../Util/PhoneUtil.dart';
import 'FChatApiObj.dart';

class ServiceUrl{
  ApiObj? aobj;
  String url;
  String title;
  String videoUrl="";
  String price="";
  ServiceUrl(this.url,this.title);
  send(void Function(String recdata) fchatsend){
    if(url.isEmpty) return;
    aobj=ApiObj(ApiName.sendurl,(value){
      fchatsend(value);
    });
    aobj!.setData(toString());
  }

  _getJson(){
    Map map={};
    map.putIfAbsent("url", ()=> url);
    map.putIfAbsent("title", ()=> title);
    map.putIfAbsent("video", ()=> videoUrl);
    map.putIfAbsent("price", ()=>price);
    return map;
  }

  @override
  String toString(){
    return JsonUtil.maptostr(_getJson());
  }

}
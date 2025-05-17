import '../Util/JsonUtil.dart';
import 'FChatApiObj.dart';

class Sendorder{
  ApiObj? aobj;
  String payid="";
  String amount="";
  String description="";
  String url="";
  Sendorder(this.payid,this.amount,this.description,this.url);

  send(void Function(String recdata) fchatsend){
    aobj=ApiObj(ApiName.order,(value){
      fchatsend(value);
    });
    aobj!.setData(toString());
  }
  toJson(){
    Map map={};
    map.putIfAbsent("payid",()=> payid);
    map.putIfAbsent("amount",()=> amount);
    map.putIfAbsent("description",()=> description);
    map.putIfAbsent("url",()=> url);
    return map;
  }

  @override
  String toString() {
    // TODO: implement toString
    return JsonUtil.maptostr(toJson());
  }


}
import '../WidgetUtil/MapScreen.dart';
import '../util/JsonUtil.dart';
import 'package:geolocator/geolocator.dart';

class FChatAddress{
  Position? position;
  String address="";
  String phone="";
  String email="";
  String consumer="";
  OsmAddress? osmAddress;
  FChatAddress();

  FChatAddress.dart(this.position,this.address);
  FChatAddress.base64(String base64){
    String data=JsonUtil.getbase64(base64);
    Map map=JsonUtil.strtoMap(data);
    if(map.containsKey("position")){
      position = Position.fromMap(map["position"]);
    }
    if(map.containsKey("phone"))phone=map["phone"];
    if(map.containsKey("address"))address=map["address"];
    if(map.containsKey("email"))email=map["email"];
    if(map.containsKey("consumer"))consumer=map["consumer"];
    if(map.containsKey("osmAddress"))osmAddress=OsmAddress.fromjson(map["osmAddress"]);
  }

  toJson(){
    Map map={};
    if(position!=null )map.putIfAbsent("position", ()=> position!.toJson());
    map.putIfAbsent("phone", ()=> phone);
    map.putIfAbsent("address", ()=>address);
    map.putIfAbsent("email", ()=> email);
    map.putIfAbsent("consumer", ()=>consumer);
    if(osmAddress!=null)  map.putIfAbsent("osmAddress", ()=>osmAddress!.toJson());
    return map;
  }

  toBase64(){
    return JsonUtil.setbase64(toString());
  }

  @override
  String toString() {
    // TODO: implement toString
    return JsonUtil.maptostr(toJson());
  }

}
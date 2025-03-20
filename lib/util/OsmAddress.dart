class OsmAddress{
  String province ="";
  String city = "";
  String district = "";
  String address="";
  OsmAddress(this.province,this.city,this.district,this.address);
  OsmAddress.fromjson(Map map){
    province=map["province"];
    city=map["ciyt"];
    district=map["district"];
    address=map["address"];
  }
  toJson(){
    Map map={};
    map.putIfAbsent("province", ()=> province);
    map.putIfAbsent("city", ()=> city);
    map.putIfAbsent("district", ()=> district);
    map.putIfAbsent("address", ()=>address);
    return map;
  }

}
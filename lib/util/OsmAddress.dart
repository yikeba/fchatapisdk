import 'dart:convert';
import 'package:fchatapi/Express/ZtoApi.dart';
import 'package:http/http.dart' as http;
import 'dart:js' as js;
import '../Util/PhoneUtil.dart';

class OsmAddress {
  String province = "";
  String city = "";
  String district = "";
  String address = "";
  String postcode = "";
  String country = "";
  String countryCode = "";

  OsmAddress(this.province, this.city, this.district, this.address){

  }

  OsmAddress.fromjson(Map map) {
    province = map["province"];
    city = map["city"];
    district = map["district"];
    address = map["address"];
    if (map.containsKey("country")) {
      country = map["country"];
    }
    if (map.containsKey("countryCode")) {
      countryCode = map["countryCode"];
    }

  }
/*  _setZtoBase(){
    PhoneUtil.applog("获得原省级单位名称$province,市县级名称$city,新的区域名称$district");
    province=ZtoApi.ztoobj.getprovince(province);
    city=ZtoApi.ztoobj.getcity(city);
    district=ZtoApi.ztoobj.getdist(district);
    PhoneUtil.applog("获得新省级单位名称$province,市县级名称$city,新的区域名称$district");
  }*/

  toJson() {
    Map map = {};
    map.putIfAbsent("province", () => province);
    map.putIfAbsent("city", () => city);
    map.putIfAbsent("district", () => district);
    map.putIfAbsent("address", () => address);
    if (country.isNotEmpty) map.putIfAbsent("country", () => country);
    if (countryCode.isNotEmpty) map.putIfAbsent("countryCode", () => countryCode);
    PhoneUtil.applog("OSM address 地址json $map");
    return map;
  }


}

class OsmAddressUtil {
  static Future<OsmAddress?> getOsmAddress(double lat, double long) async {
    try {
     /* final response = await http.get(
          Uri.parse(
              'https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${long}&zoom=18&addressdetails=1&accept-language=en'),
          headers: {'Accept': 'application/json', 'User-Agent': 'Flutter App'});*/
      final response = await http.get(
          Uri.parse(
              'https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${long}&zoom=18&addressdetails=1'),
          headers: {'Accept': 'application/json', 'User-Agent': 'Flutter App'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['address'] != null) {
          PhoneUtil.applog("post 回调综合位置信息$data");
          String _address = data['display_name'];
          return _parseOSMAddress(data['address'], _address);
        }
      }
    } catch (e) {
      // 使用原生JavaScript的地理编码功能
      js.context.callMethod('reverseGeocode', [
        lat,
        long,
        js.allowInterop((result) {
          PhoneUtil.applog("js 回调综合位置信息$result");
          String _address = result;
          return _parseAddress(_address);
        })
      ]);
    }
    return null;
  }

  static OsmAddress _parseAddress(String _address) {
    List<String> parts = _address.split(',').map((e) => e.trim()).toList();
    parts.removeLast();
    String province = parts.isNotEmpty ? parts.last : '未知省';
    parts.removeLast();
    String city = parts.isNotEmpty ? parts.last : '未知城市';
    parts.removeLast();
    String district = parts.isNotEmpty ? parts.last : '未知区';
    return OsmAddress(province, city, district, _address);
  }

  static OsmAddress _parseOSMAddress(
      Map<String, dynamic> address, String _address) {
    String province = address['state'] ?? address['province'] ?? '';
    String city = address['city'] ?? '';
    String district = address['county'] ?? address['borough'] ?? address['suburb'] ?? address['town'] ?? address['village'] ??'';
    String country=address["country"] ?? "";
    String country_code=address["country_code"] ?? "";
    PhoneUtil.applog("解析国家名称$country 对应国家代码$country_code");
    if(city.isEmpty) city=province;
    OsmAddress osmAddress=OsmAddress(province,city,district,_address);
    if(country.isNotEmpty) osmAddress.country=country;
    if(country_code.isNotEmpty) osmAddress.countryCode=country_code;
    return osmAddress;
  }
}

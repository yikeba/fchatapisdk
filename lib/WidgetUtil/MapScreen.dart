import 'dart:convert';
import 'package:fchatapi/Util/PhoneUtil.dart';
import 'package:fchatapi/util/Translate.dart';
import 'package:fchatapi/webapi/FChatAddress.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:js' as js;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class SelectLocationPage extends StatefulWidget {
  Position? position;
  final Function(LatLng, String)? onLocationSelected; // 选择后回调
  SelectLocationPage({super.key,this.position,this.onLocationSelected});

  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  LatLng _selectedLocation=const LatLng(11.3440837,103.6592343) ;
  String _address="";
  FChatAddress? faddress;
  OsmAddress? osmAddress;
  @override
  void initState() {
    super.initState();
    //WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (widget.position != null) {
        _selectedLocation =
            LatLng(widget.position!.latitude, widget.position!.longitude);
        _currentLocation = _selectedLocation;
      } else {
        _getCurrentLocation();
      }
    //});
  }

  /// 获取 GPS 位置
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar('请启用定位服务');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar('定位权限被拒绝');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnackbar('定位权限被永久拒绝');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _currentLocation = LatLng(position.latitude, position.longitude);
    _selectedLocation = _currentLocation!;
    await _getAddress(_currentLocation!);
    setState(() {
      _mapController.move(_selectedLocation, 16);

    });
  }

  /// 通过经纬度获取地址
  /// 通过经纬度获取地址
  Future<void> _getAddress(LatLng location) async {
    try {

      try {
        // 备选方案：使用OpenStreetMap API
        final response = await http.get(
            Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1'),
            headers: {'Accept': 'application/json', 'User-Agent': 'Flutter App'}
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data != null && data['display_name'] != null) {
            PhoneUtil.applog("http返回综合位置信息$data");
            _parseOSMAddress(data);
            setState(() {
              _address = data['display_name'];
              setAddress();
            });
          }
        } else {
          setState(() {
            _address = "无法获取地址信息";
          });
        }
      } catch (httpError) {
        setState(() {
          _address = "获取地址失败";
        });
      }
    } catch (e) {
      // 使用原生JavaScript的地理编码功能
      js.context.callMethod('reverseGeocode', [
        location.latitude,
        location.longitude,
        js.allowInterop((result) {
          PhoneUtil.applog("js 回调综合位置信息$result");
          if(mounted) {
            setState(() {
              _address = result;
              _parseThaiAddress();
              setAddress();
            });
          }
        })
      ]);
    }
  }

  void _parseThaiAddress() {
    List<String> parts = _address.split(',').map((e) => e.trim()).toList();
    parts.removeLast(); // 移除"泰国"
    String province = parts.isNotEmpty ? parts.last : '未知省';
    parts.removeLast();
    String city = parts.isNotEmpty ? parts.last : '未知城市';
    parts.removeLast();
    String district = parts.isNotEmpty ? parts.last : '未知区';
    osmAddress=OsmAddress(province,city,district,_address);
    setState(() {
      _address = "$province, $city, $district";
      setAddress();
    });
  }

  void _parseOSMAddress(Map<String, dynamic> address) {
    String province = address['state'] ?? '未知省份';
    String city = address['city'] ?? address['town'] ?? address['village'] ?? '未知城市';
    String district = address['county'] ?? address['borough'] ?? address['suburb'] ?? '未知地区';
    osmAddress=OsmAddress(province,city,district,_address);
    setState(() {
      _address = "$province, $city, $district";
      setAddress();
    });
  }



  /// 监听地图移动，更新 `selectedLocation`
  void _updateSelectedLocation() async {
    // 获取地图当前中心点
    LatLng centerPosition = _mapController.camera.center;
    setState(() {
      _selectedLocation = centerPosition;
    });
    // 获取新位置的地址信息
    await _getAddress(_selectedLocation);
    // 更新位置对象
   // setAddress();
  }
  setAddress(){
    if (widget.position != null) {
      widget.position = Position(
          latitude: _selectedLocation.latitude,
          longitude: _selectedLocation.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0
      );
    }
    // 更新地址对象
    PhoneUtil.applog("加载地址到联系对象信息:$_address");
    faddress = FChatAddress.dart(widget.position ?? Position(
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0
    ), _address);
    faddress!.osmAddress=osmAddress;
  }
  /// 显示 Snackbar 提示
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 16.0,
              onMapEvent: (MapEvent event) {
                if (event is MapEventMoveEnd) {
                  _updateSelectedLocation();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),
          // **地图中心点图标**
          const Center(
            child: Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
          // **确认按钮**
          Positioned(
            bottom: 20,
            left: 50,
            right: 50,
            child: Column(
              children: [
                if (_address.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      _address,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    if (widget.onLocationSelected != null) {
                      widget.onLocationSelected!(_selectedLocation, _address);
                    }
                    Navigator.of(context).pop(faddress);
                  },
                  child: Text(Translate.show("确认位置")),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


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
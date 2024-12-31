
import 'package:fchatapi/util/JsonUtil.dart';
import 'package:fchatapi/util/SignUtil.dart';
import 'package:fchatapi/util/Tools.dart';
import 'package:fchatapi/util/UserObj.dart';

enum ApiName {
  system,
  userinfo, //用户信息
  pay, //支付调用
  gps, //位置信息
  localstorage, //存储接口，客户端本地存储和s3
  readstorage, //读取文件
}

class ApiObj{
   ApiName apiname;
   String actionid="";
   String data="";
   String sign="";

   ApiObj(this.apiname){
     actionid=Tools.generateRandomString(70);
   }
   setData(String data){
     this.data=JsonUtil.getbase64(data);
     sign=SignUtil.hmacSHA512(this.data, UserObj.token);
   }
   String toString(){
     return JsonUtil.maptostr(_getJSON());
   }
   _getJSON(){
     Map map={};
     map.putIfAbsent("apiname", ()=> apiname.name);
     map.putIfAbsent("data", ()=> data);
     map.putIfAbsent("sign", ()=> sign);
     map.putIfAbsent("id", ()=>actionid);
   }

}

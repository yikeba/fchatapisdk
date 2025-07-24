
import 'package:fchatapi/appapi/BaseJS.dart';
import 'package:fchatapi/util/JsonUtil.dart';
import 'package:fchatapi/util/SignUtil.dart';
import 'package:fchatapi/util/Tools.dart';
import 'package:fchatapi/util/UserObj.dart';

import '../util/PhoneUtil.dart';


enum ApiName {
  system,
  userinfo, //用户信息
  pay, //支付调用
  gps, //位置信息
  localstorage, //存储接口，客户端本地存储和s3
  readstorage, //读取文件
  sendurl,
  order, //服务号订单
  appport
}

class ApiObj{
   ApiName apiname;
   String actionid="";
   String data="";
   String sign="";
   void Function(String)? recData;
   ApiObj(this.apiname,this.recData){
     actionid=Tools.generateRandomString(70);
   }
   setData(String data){
     this.data=JsonUtil.getbase64(data);
     sign=SignUtil.hmacSHA512(this.data, UserObj.token);
     BaseJS.sendtoFChat(toString(),(value){
         recaction(value);
     });
   }

   recaction(String value){
     if(value=="err"){
       if(recData!=null)recData!("err");
       return;
     }
     Map recmap=JsonUtil.strtoMap(value);
     String fsgin="";
     String fdata="";
     String vdata="";
     String fid="";
     int code=-1;
     //PhoneUtil.applog("API对象收到app返回数据，进行解析$recmap");
     if(recmap.containsKey("code")){
       code=recmap["code"];
     }
     if(recmap.containsKey("sign")){
       fsgin=recmap["sign"];
     }
     if(recmap.containsKey("data")){
       fdata=recmap["data"];
       vdata=fdata;
       vdata=JsonUtil.getbase64(vdata);
     }
     if(recmap.containsKey("id")){
        fid=recmap["id"];
     }
     //{"code":200,"data":"e30=","sign":"1e19878b79083e3738ca801c9a289d87","api":"pay","id":"VjRQajMrCC8M74y99qcA4Bau7giitD3Ev2lft81I9S5C6eJdM8dKXBgAVy0XF7QWKYdbpF"}}
     if(fid==actionid && code==200){  //核对操作id
       bool isv= SignUtil.verifysha512(fdata,UserObj.token,fsgin);//验证签名
       if(isv){
         if(recData!=null){
            recData!(vdata);
         }else{
           PhoneUtil.applog("回调接口为null,无法返回数据到主程序");
         }
       }else{
         PhoneUtil.applog("验证签名错误$sign");
         if(recData!=null)recData!("err");
       }
     }else{
       PhoneUtil.applog("无法核对id$actionid");
     }
   }

   @override
   String toString(){
     return JsonUtil.maptostr(_getJSON());
   }

   _getJSON(){
     Map map={};
     map.putIfAbsent("api", ()=> apiname.name);
     map.putIfAbsent("data", ()=> data);
     map.putIfAbsent("sign", ()=> sign);
     map.putIfAbsent("id", ()=>actionid);
     map.putIfAbsent("userid", ()=> UserObj.userid);
     return map;
   }
}

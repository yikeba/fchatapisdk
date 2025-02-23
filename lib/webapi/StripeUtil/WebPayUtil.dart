import 'CookieStorage.dart';

class WebPayUtil{

   static bool isLocCard(){  //判断本地是否保存信用卡
     String? cardinfo=CookieStorage.getCookie("fchat.card");
     if(cardinfo==null) return false;
     return true;
   }



}
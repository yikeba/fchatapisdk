import 'package:fchatapi/util/JsonUtil.dart';

import 'CardObj.dart';
import 'CookieStorage.dart';

class CardArr{
    List<CardObj> cardarr=[];

    readCard(){
      cardarr.clear();
      String? cardinfo=CookieStorage.getCookie("fchat.card");
      if(cardinfo==null) return;
      List arr=JsonUtil.strotList(cardinfo);
      for(String data in arr){
         cardarr.add(CardObj.decryptCard(data));
      }
    }

    saveCard(CardObj card){
        cardarr.add(card);
        _save();
    }

    _save(){
       List<String> arr=[];
       for(CardObj card in cardarr){
          String carddata=card.encryptData();
          arr.add(carddata);
       }
       if(arr.isNotEmpty) {
         String data = JsonUtil.listtostr(arr);
         CookieStorage.saveToCookie("fchat.card", data);
       }
    }

    delCard(CardObj card){
       cardarr.remove(card);
       _save();
    }


}
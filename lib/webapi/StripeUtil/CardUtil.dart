
import '../../util/PhoneUtil.dart';
import 'CardObj.dart';

class CardUtil{
  static List<CardObj> cardarr=[];
  static String cardname="";
  static initCard(List list){
    for(Map map in list){
       String cardinfo=map.values.first;
       CardObj card=CardObj.fromStr(cardinfo);
       if(cardname.isEmpty) {
         cardname = card.cardHolderName;
         PhoneUtil.applog("账户实名$cardname");
       }
       cardarr.add(card);
    }
  }


}
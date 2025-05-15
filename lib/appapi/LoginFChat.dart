import '../Util/JsonUtil.dart';
import '../Util/PhoneUtil.dart';
import 'FChatApiObj.dart';

class Loginfchat{
  ApiObj? aobj;

  send(void Function(String recdata) fchatsend){
    aobj=ApiObj(ApiName.system,(value){
      fchatsend(value);
    });
    aobj!.setData("{}");
  }
}
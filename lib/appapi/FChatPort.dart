import 'package:fchatapi/Util/PhoneUtil.dart';

import 'FChatApiObj.dart';

class FChatPort{
  //从app获取可以下载的端口和ip

  ApiObj? aobj;

  send(void Function(String recdata) fchatsend){
    aobj=ApiObj(ApiName.appport,(value){
       PhoneUtil.applog("收到app返回的可以上下文件数据$value");
       fchatsend(value);
    });
    aobj!.setData("{}");
  }
}
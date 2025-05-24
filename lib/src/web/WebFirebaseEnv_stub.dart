// lib/src/web/WebFirebaseEnv_stub.dart
import '../../Util/PhoneUtil.dart';

class WebFirebaseEnv {
  static Future<void> initenv() async {
    // 非 web 平台不执行任何操作
    PhoneUtil.applog("app需要初始化内容");
  }
}

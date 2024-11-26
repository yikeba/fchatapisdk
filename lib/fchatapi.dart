
import 'fchatapi_platform_interface.dart';

class Fchatapi {
  Future<String?> getPlatformVersion() {
    return FchatapiPlatform.instance.getPlatformVersion();
  }
}

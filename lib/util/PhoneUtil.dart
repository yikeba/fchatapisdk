import 'package:flutter/foundation.dart';

class PhoneUtil{

  static applog(String info) {
    bool inputinfo = false;
    if (kDebugMode || inputinfo) {
        print("[FChat Api: ${DateTime.now().millisecondsSinceEpoch}]$info");
    }
  }

}
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fchatapi_platform_interface.dart';

/// An implementation of [FchatapiPlatform] that uses method channels.
class MethodChannelFchatapi extends FchatapiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fchatapi');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

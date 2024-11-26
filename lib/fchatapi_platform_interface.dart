import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fchatapi_method_channel.dart';

abstract class FchatapiPlatform extends PlatformInterface {
  /// Constructs a FchatapiPlatform.
  FchatapiPlatform() : super(token: _token);

  static final Object _token = Object();

  static FchatapiPlatform _instance = MethodChannelFchatapi();

  /// The default instance of [FchatapiPlatform] to use.
  ///
  /// Defaults to [MethodChannelFchatapi].
  static FchatapiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FchatapiPlatform] when
  /// they register themselves.
  static set instance(FchatapiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

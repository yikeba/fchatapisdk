import 'package:flutter_test/flutter_test.dart';
import 'package:fchatapi/fchatapi.dart';
import 'package:fchatapi/fchatapi_platform_interface.dart';
import 'package:fchatapi/fchatapi_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFchatapiPlatform
    with MockPlatformInterfaceMixin
    implements FchatapiPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FchatapiPlatform initialPlatform = FchatapiPlatform.instance;

  test('$MethodChannelFchatapi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFchatapi>());
  });

  test('getPlatformVersion', () async {
    Fchatapi fchatapiPlugin = Fchatapi();
    MockFchatapiPlatform fakePlatform = MockFchatapiPlatform();
    FchatapiPlatform.instance = fakePlatform;

    expect(await fchatapiPlugin.getPlatformVersion(), '42');
  });
}

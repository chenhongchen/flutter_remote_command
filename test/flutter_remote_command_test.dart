import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_remote_command/flutter_remote_command.dart';
import 'package:flutter_remote_command/flutter_remote_command_platform_interface.dart';
import 'package:flutter_remote_command/flutter_remote_command_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterRemoteCommandPlatform 
    with MockPlatformInterfaceMixin
    implements FlutterRemoteCommandPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterRemoteCommandPlatform initialPlatform = FlutterRemoteCommandPlatform.instance;

  test('$MethodChannelFlutterRemoteCommand is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterRemoteCommand>());
  });

  test('getPlatformVersion', () async {
    FlutterRemoteCommand flutterRemoteCommandPlugin = FlutterRemoteCommand();
    MockFlutterRemoteCommandPlatform fakePlatform = MockFlutterRemoteCommandPlatform();
    FlutterRemoteCommandPlatform.instance = fakePlatform;
  
    expect(await flutterRemoteCommandPlugin.getPlatformVersion(), '42');
  });
}

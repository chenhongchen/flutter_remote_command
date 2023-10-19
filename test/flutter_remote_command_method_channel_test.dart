import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_remote_command/flutter_remote_command_method_channel.dart';

void main() {
  MethodChannelFlutterRemoteCommand platform = MethodChannelFlutterRemoteCommand();
  const MethodChannel channel = MethodChannel('flutter_remote_command');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

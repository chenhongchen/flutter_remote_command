import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_remote_command_platform_interface.dart';

/// An implementation of [FlutterRemoteCommandPlatform] that uses method channels.
class MethodChannelFlutterRemoteCommand extends FlutterRemoteCommandPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_remote_command/method');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

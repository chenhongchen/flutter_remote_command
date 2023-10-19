import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_remote_command_method_channel.dart';

abstract class FlutterRemoteCommandPlatform extends PlatformInterface {
  /// Constructs a FlutterRemoteCommandPlatform.
  FlutterRemoteCommandPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterRemoteCommandPlatform _instance = MethodChannelFlutterRemoteCommand();

  /// The default instance of [FlutterRemoteCommandPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterRemoteCommand].
  static FlutterRemoteCommandPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterRemoteCommandPlatform] when
  /// they register themselves.
  static set instance(FlutterRemoteCommandPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

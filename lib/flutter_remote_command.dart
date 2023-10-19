import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_remote_command/flutter_remote_command_platform_interface.dart';

typedef RemoteCommandListener = void Function(String command, dynamic value);

class RemoteCommandType {
  static const pause = 'pause'; // 暂停当前播放器
  static const play = 'play'; // 开始播放当前播放器
  static const stop = 'stop'; // 停止当前播放器
  static const togglePlayPause = 'togglePlayPause'; // 切换播放器的播放/暂停状态
  static const nextTrack = 'nextTrack'; // 播放下一首
  static const previousTrack = 'previousTrack'; // 播放上一首
}

class FlutterRemoteCommand {
  static const EventChannel _eventChannel =
      EventChannel('flutter_remote_command/event');
  static StreamSubscription? _streamSubscription;
  static final Set<RemoteCommandListener> _listeners =
      <RemoteCommandListener>{};

  /// 销毁资源
  static dispose() {
    _streamSubscription?.cancel().catchError((e) {});
    _streamSubscription = null;
  }

  /// 通道事件监听
  static void onEvent(dynamic arg) {
    final Map<dynamic, dynamic> map = arg;
    String event = map['event'] ?? '';
    dynamic value = map['value'];
    Set<RemoteCommandListener> listeners =
        Set<RemoteCommandListener>.from(_listeners);
    listeners.toList().forEach((listener) {
      listener.call(event, value);
    });
  }

  /*
  * 添加监听者
  * listener: 要加入的监听者
  * */
  static void addListener(RemoteCommandListener listener) {
    _streamSubscription ??=
        _eventChannel.receiveBroadcastStream().listen(onEvent);
    _listeners.add(listener);
  }

  /*
  * 移除监听者
  * listenerId: 要移除的监听id
  * */
  static removeListener(RemoteCommandListener listener) {
    _listeners.remove(listener);
  }

  Future<String?> getPlatformVersion() async {
    return FlutterRemoteCommandPlatform.instance.getPlatformVersion();
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_remote_command/flutter_remote_command.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterRemoteCommandPlugin = FlutterRemoteCommand();
  final _player = AudioPlayer();

  @override
  void dispose() {
    FlutterRemoteCommand.removeListener(_remoteCommandListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    FlutterRemoteCommand.addListener(_remoteCommandListener);
    _player.onPlayerStateChanged.listen((event) {
      setState(() {});
    });
  }

  void _remoteCommandListener(String command, dynamic value) {
    print('_remoteCommandListener event : $command');
    if (command == RemoteCommandType.pause) {
      _player.pause();
    } else if (command == RemoteCommandType.play) {
      _player.resume();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterRemoteCommandPlugin.getPlatformVersion() ??
              'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    String text = '开始播放';
    if (_player.state == PlayerState.completed) {
      text = '播放完成';
    } else if (_player.state == PlayerState.paused) {
      text = '播放暂停';
    } else if (_player.state == PlayerState.playing) {
      text = '播放中';
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Text('Running on: $_platformVersion\n'),
              GestureDetector(
                onTap: () async {
                  if (_player.state == PlayerState.stopped ||
                      _player.state == PlayerState.completed ||
                      _player.state == PlayerState.paused) {
                    await _player.play(AssetSource('/voice.m4a'));
                  } else if (_player.state == PlayerState.playing) {
                    await _player.pause();
                  }
                },
                child: Container(
                  color: Colors.orange,
                  alignment: Alignment.center,
                  height: 50,
                  width: 100,
                  child: Text(text),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

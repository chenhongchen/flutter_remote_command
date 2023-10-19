#import "FlutterRemoteCommandPlugin.h"
#import <MediaPlayer/MediaPlayer.h>

@interface FlutterRemoteCommandPlugin()<FlutterStreamHandler>
@property (strong, nonatomic) FlutterEventSink flutterEventSink;
@property (strong, nonatomic) AVAudioSessionCategory oldCategory;
@property (strong, nonatomic) MPRemoteCommandCenter *commandCenter;
@end

@implementation FlutterRemoteCommandPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_remote_command/method"
            binaryMessenger:[registrar messenger]];
    FlutterRemoteCommandPlugin* instance = [[FlutterRemoteCommandPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel *event = [FlutterEventChannel eventChannelWithName:@"flutter_remote_command/event" binaryMessenger:[registrar messenger]];
    [event setStreamHandler:instance];
}

// 原生给flutter发消息
- (void)emitEvent:(NSString *)event params:(NSDictionary *)params
{
    if (![event isKindOfClass:[NSString class]] || event.length <= 0) {
        return;
    }
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[@"event"] = event;
    dictM[@"value"] = params;
    self.flutterEventSink(dictM);
}

#pragma mark - flutter call native
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark - FlutterStreamHandler
- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    self.flutterEventSink = events;
    [self startCommandMonitor];
    return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.flutterEventSink = nil;
    [self stopCommandMonitor];
    return nil;
}

- (void)startCommandMonitor {
    self.oldCategory = AVAudioSession.sharedInstance.category;
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayback error:nil];
    [AVAudioSession.sharedInstance setActive:YES error:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // 注册远程控制事件
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    });
    self.commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    // 暂停当前播放器
    self.commandCenter.pauseCommand.enabled = YES;
    [self.commandCenter.pauseCommand addTarget:self action:@selector(pauseCommand)];
    // 开始播放当前播放器
    self.commandCenter.playCommand.enabled = YES;
    [self.commandCenter.playCommand addTarget:self action:@selector(playCommand)];
    // 停止当前播放器
    self.commandCenter.stopCommand.enabled = YES;
    [self.commandCenter.stopCommand addTarget:self action:@selector(stopCommand)];
    // 切换播放器的播放/暂停状态
    self.commandCenter.togglePlayPauseCommand.enabled = YES;
    [self.commandCenter.togglePlayPauseCommand addTarget:self action:@selector(togglePlayPauseCommand)];
    // 播放下一首
    self.commandCenter.nextTrackCommand.enabled = YES;
    [self.commandCenter.nextTrackCommand addTarget:self action:@selector(nextTrackCommand)];
    // 播放上一首
    self.commandCenter.previousTrackCommand.enabled = YES;
    [self.commandCenter.previousTrackCommand addTarget:self action:@selector(previousTrackCommand)];
}

- (void)stopCommandMonitor {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    self.commandCenter.pauseCommand.enabled = NO;
    [self.commandCenter.pauseCommand removeTarget:self];
    self.commandCenter.playCommand.enabled = NO;
    [self.commandCenter.playCommand removeTarget:self];
    self.commandCenter.stopCommand.enabled = NO;
    [self.commandCenter.stopCommand removeTarget:self];
    self.commandCenter.togglePlayPauseCommand.enabled = NO;
    [self.commandCenter.togglePlayPauseCommand removeTarget:self];;
    // 播放下一首
    self.commandCenter.nextTrackCommand.enabled = NO;
    [self.commandCenter.nextTrackCommand removeTarget:self];
    // 播放上一首
    self.commandCenter.previousTrackCommand.enabled = NO;
    [self.commandCenter.previousTrackCommand removeTarget:self];
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    });
    [AVAudioSession.sharedInstance setCategory:self.oldCategory error:nil];
}

- (MPRemoteCommandHandlerStatus)pauseCommand {
    [self emitEvent:@"pause" params:@{}];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)playCommand {
    [self emitEvent:@"play" params:@{}];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)stopCommand {
    [self emitEvent:@"stop" params:@{}];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)togglePlayPauseCommand {
    [self emitEvent:@"togglePlayPause" params:@{}];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)nextTrackCommand {
    [self emitEvent:@"nextTrack" params:@{}];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)previousTrackCommand {
    [self emitEvent:@"previousTrack" params:@{}];
    return MPRemoteCommandHandlerStatusSuccess;
}
@end

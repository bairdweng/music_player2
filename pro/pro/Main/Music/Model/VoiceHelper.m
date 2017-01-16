//
//  VoiceHelper.m
//  pro
//
//  Created by Xiaowz on 16/10/10.
//  Copyright © 2016年 huaxia. All rights reserved.
//

#import "VoiceHelper.h"
#import <AVFoundation/AVFoundation.h>


//const static int max_height = 250;

@interface VoiceHelper() {
    NSTimer *_timer;
}
@property (nonatomic, strong) AVAudioRecorder *recorder;
@end

@implementation VoiceHelper

static VoiceHelper *_instance;
+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [VoiceHelper new];
    });
    return _instance;
}

#pragma mark - call back
- (void)levelTimerCallback:(NSTimer *)timer {
    [self.recorder updateMeters];
    float temp = [_recorder peakPowerForChannel:0];
    //转化范围为0 － 1；
    double result = pow(10, (0.05 * temp));
    [_delegate volumeDidChanged:result];
}
- (void)pause {
    [self.recorder pause];
    [_timer invalidate];
}
- (void)record {
    [self configSelf];
    [self.recorder record];
    _timer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
}
#pragma mark - private
- (void)configSelf {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
}
#pragma mark - getter
- (AVAudioRecorder *)recorder {
    if (!_recorder) {
        NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
        NSLog(@"%@",url);
        NSDictionary *settings = @{AVSampleRateKey: @44100.0, AVFormatIDKey: [NSNumber numberWithInt:kAudioFormatAppleLossless], AVNumberOfChannelsKey: @2, AVEncoderAudioQualityKey: [NSNumber numberWithInt:AVAudioQualityMax]};
        _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:nil];
        [_recorder prepareToRecord];
        _recorder.meteringEnabled = YES;
    }
    return _recorder;
}
@end

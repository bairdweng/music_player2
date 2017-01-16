//
//  CMDModel.m
//  pro
//
//  Created by Xiaowz on 16/9/26.
//  Copyright © 2016年 huaxia. All rights reserved.
//

#import "CMDModel.h"
#import <UIKit/UIKit.h>




static const int byte_len = 8;
static const int start = 0xea;
@interface CMDModel() {
    Byte _bytes[byte_len];
    Byte _bright;
    NSArray<NSData *> *_colors;
    
}
@property (nonatomic, assign, readwrite) BOOL on;
@end

@implementation CMDModel

static CMDModel *_instance;
+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [CMDModel new];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self configSelf];
    }
    return self;
}

- (NSData *)getCuttentData {
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];

}

- (void) writeCMD: (Byte[])bytes {
    _bytes[1] = bytes[0];
    _bytes[2] = 0x04;
    _bytes[3] = bytes[1];
    _bytes[4] = bytes[2];
    _bytes[5] = bytes[3];
    _bytes[6] = bytes[4];
}

- (NSData *)queryCMD {
    Byte temp[] = {0xea,0x0a};
    return [[NSData alloc] initWithBytes:temp length:2];
    
}

- (NSArray<NSData *> *)singleColors {
    if (!_colors) {
        _colors = @[self.redCMD, self.blueCMD, self.greenCMD, self.pinkCMD, self.yellowCMD, self.babyBlueCMD, self.whiteCMD];
    }
    return _colors;
}

- (NSData *)redCMD {
    //_bytes[1] = 0x01;
    //_bytes[2] = 0x04;
    _bytes[3] = 0xff;
    _bytes[4] = 0x00;
    _bytes[5] = 0x00;
//    if (_bytes[6] == 0) {
//        _bytes[6] = 0x64;
//    }
    _bytes[7] = [self examine];
    
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (NSData *)greenCMD {
    //_bytes[1] = 0x01;
    //_bytes[2] = 0x04;
    _bytes[3] = 0x00;
    _bytes[4] = 0xff;
    _bytes[5] = 0x00;
//    if (_bytes[6] == 0) {
//        _bytes[6] = 0x64;
//    }
    _bytes[7] = [self examine];
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (NSData *)blueCMD {
    //_bytes[1] = 0x01;
    //_bytes[2] = 0x04;
    _bytes[3] = 0x00;
    _bytes[4] = 0x00;
    _bytes[5] = 0xff;
//    if (_bytes[6] == 0) {
//        _bytes[6] = 0x64;
//    }
    _bytes[7] = [self examine];
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (NSData *)pinkCMD {
    //_bytes[1] = 0x01;
    //_bytes[2] = 0x04;
    _bytes[3] = 0xff;
    _bytes[4] = 0x00;
    _bytes[5] = 0xff;
//    if (_bytes[6] == 0) {
//        _bytes[6] = 0x64;
//    }
    _bytes[7] = [self examine];
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (NSData *)yellowCMD {
    //_bytes[1] = 0x01;
    //_bytes[2] = 0x04;
    _bytes[3] = 0xff;
    _bytes[4] = 0xff;
    _bytes[5] = 0x00;
//    if (_bytes[6] == 0) {
//        _bytes[6] = 0x64;
//    }
    _bytes[7] = [self examine];
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (NSData *)babyBlueCMD {
    //_bytes[1] = 0x01;
    //_bytes[2] = 0x04;
    _bytes[3] = 0x00;
    _bytes[4] = 0xff;
    _bytes[5] = 0xff;
//    if (_bytes[6] == 0) {
//        _bytes[6] = 0x64;
//    }
    _bytes[7] = [self examine];
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (NSData *)whiteCMD {
    //_bytes[1] = 0x01;
    //_bytes[2] = 0x04;
    _bytes[3] = 0xff;
    _bytes[4] = 0xff;
    _bytes[5] = 0xff;
//    if (_bytes[6] == 0) {
//        _bytes[6] = 0x64;
//    }
    _bytes[7] = [self examine];
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (NSData *)blackCMD {
    //_bytes[1] = 0x01;
    //_bytes[2] = 0x04;
    _bytes[3] = 0x00;
    _bytes[4] = 0x00;
    _bytes[5] = 0x00;
//    if (_bytes[6] == 0) {
//        _bytes[6] = 0x64;
//    }
    _bytes[7] = [self examine];
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (NSData *)speedCMD: (int)speed {
    if (speed < 0) {
        speed = 0;
    }
    if (speed > 10) {
        speed = 10;
    }
    
    
    
    Byte temp[5];
    temp[0] = 0xea;
//    if (_bytes[1] == 0) {
//        _bytes[1] = 0x01;
//        _bytes[2]= 0x04;
//    }
    temp[1] = 0x04;
    temp[2] = 0x01;
    temp[3] = speed;
    temp[4] = temp[1] + temp[2] + temp[3];
    //[self senNotifition];
    return [[NSData alloc] initWithBytes:temp length:5];
}

- (NSData *)brightnessCMD: (int)brightness {
   
    if (brightness < 0) {
        brightness = 0;
    }
    if (brightness > 100) {
        brightness = 100;
    }
    
    if (_bytes[1] == 0) {
        _bytes[1] = 0x01;
        _bytes[2] = 0x04;
        _bytes[3] = 0xff;
        _bytes[4] = 0x00;
        _bytes[5] = 0x00;
//        _bytes[1] = 0x01;
//        _bytes[2] = 0x04;
//        _bytes[3] = 0xff;
//        _bytes[4] = 0x00;
//        _bytes[5] = 0x00;
//        _bytes[6] = 0x64;
    }
    
    if (_bytes[3] ==0 &&  _bytes[4] == 0 && _bytes[5] == 0) {
        //_bytes[1] = 0x01;
        //_bytes[2] = 0x04;
        _bytes[3] = 0xff;
        _bytes[4] = 0x00;
        _bytes[5] = 0x00;
    }
    
    _bytes[6] = brightness;
    _bytes[7] = [self examine];
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (NSData *)threeBlinkCMD {
    _bytes[1] = 0x01;
    _bytes[2] = 0x04;
    _bytes[7] = [self examine];
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (NSData *)threeBreathCMD {
    _bytes[1] = 0x05;
    _bytes[2] = 0x04;
    _bytes[7] = [self examine];
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (NSData *)sevenBlinkCMD {
    _bytes[1] = 0x03;
    _bytes[2] = 0x04;
    _bytes[7] = [self examine];
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (NSData *)sevenBreathCMD {
    _bytes[1] = 0x08;
    _bytes[2] = 0x04;
    _bytes[7] = [self examine];
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (NSData *)singleColorCMD: (int)progess {
    [self single:progess];
    _bytes[7] = [self examine];
    
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (UIColor *)singleColor: (int)progess {
    [self single:progess];
    [self senNotifition];
    return [UIColor colorWithRed:_bytes[3] / 255.0 green:_bytes[4] / 255.0  blue:_bytes[5] / 255.0  alpha:1 ];
}

- (NSData *)musicCMD: (float)volume {
    if (volume < 0) {
        volume = 0;
    }
    if (volume > 1) {
        volume = 1;
    }
    
    NSData *data;
    static float lastVolume;
    if (((volume - lastVolume) / volume) > _sentivity || volume > 0.5) {
        _bytes[1] = 0x09;
        data = [[NSData alloc] initWithBytes:_bytes length:byte_len];
    }
    else if(((lastVolume - volume) / volume) > _sentivity) {
        //sleep(300 - 20);
        [NSThread sleepForTimeInterval:0.2 - 0.06];
        data = [NSData new];
    }
    else {
        data = [NSData new];
    }
    
    lastVolume = volume;
    [self senNotifition];
    return data;
}

- (NSData *)singleMusicCMD: (float)volume {
    if (volume < 0) {
        volume = 0;
    }
    if (volume > 1) {
        volume = 1;
    }
    
    NSData *data;
    static float lastVolume;
    if (((volume - lastVolume) / volume) > _sentivity || volume > 0.5) {
        _bytes[1] = 0x02;
        _bytes[2] = 0x04;
        if (_bytes[3] == 0 && _bytes[4] == 0 && _bytes[5] == 0) {
            _bytes[3] = 0xff;
        }
        //_bytes[6] = 0x64;
        _bytes[7] = [self examine];
        data = [[NSData alloc] initWithBytes:_bytes length:byte_len];
    }
    else if(((lastVolume - volume) / volume) > _sentivity) {
        //sleep(300 - 20);
        [NSThread sleepForTimeInterval:0.2 - 0.06];
        data = [NSData new];
    }
    else {
        data = [NSData new];
    }
    
    lastVolume = volume;
    [self senNotifition];
    return data;

}

- (NSData *)powerOff {
    if ([self isOff]) {
       
        _bytes[3] = 0xff;
        _bytes[4] = 0x00;
        _bytes[5] = 0x00;

    }
   // _bytes[1] = 0x01;
   // _bytes[2] = 0x04;
    _bright = _bytes[6];
    _bytes[6] = 0x00;
    _bytes[7] = [self examine];
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];

}

- (NSData *)powerOn {
    if ([self isOff]) {
        _bytes[3] = 0xff;
        _bytes[4] = 0x00;
        _bytes[5] = 0x00;
        _bytes[6] = 0x64;
    }
    _bytes[6] = _bright;
//    if (_bright == 0) {
//        _bytes[6] = 0x64;
//    }
    
    //_bytes[1] = 0x01;
    //_bytes[2] = 0x04;
    
    _bytes[7] = [self examine];
    [self senNotifition];
    return [[NSData alloc] initWithBytes:_bytes length:byte_len];
}

- (void)sendData: (NSNotification *)noti {
    id obj = noti.userInfo[@"data"];
    if (obj && [obj isKindOfClass:[NSData class]]) {
        NSData *data = (NSData *)obj;
        Byte result[8] = {0x00};
        [data getBytes:&result length:8];
        if(result[1] == 0x04) {
            return;
        }
        
        if ((result[3] != 0 || result[4] != 0 || result[5] != 0) && result[0] == 0xea) {
            for (int i = 0; i < 8; i++) {
                _bytes[i] = result[i];
            }
        }
    }
}


#pragma mark - private 
- (void)configSelf {
    _sentivity = 0.08;
    _bytes[0] = start;
    _bytes[1] = 0x01;
    _bytes[2] = 0x04;
    _bytes[6] = 0x64;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendData:) name:@"kBluServerSendData" object:nil];
  }

- (int)examine {
    return _bytes[1] + _bytes[2] + _bytes[3] + _bytes[4] + _bytes[5] + _bytes[6];
}

- (void)single: (int)progess {
    //_bytes[1] = 0x01;
    //_bytes[2] = 0x04;
//    if (_bytes[6] == 0) {
//        _bytes[6] = 0x64;
//    }
    if (_bytes[1] == 0) {
        _bytes[1] = 0x01;
        _bytes[2] = 0x04;
    }
    if (progess < 0) {
        progess = 0;
    }
    if (progess >= 1422) {
        progess = 1421;
    }
    
    if (progess >= 0 && progess < 243) {
        _bytes[3] = 255;
        _bytes[4] = progess;
        _bytes[5] = 0;
    }
    else if (progess >= 243 && progess < 458) {
        _bytes[3] = 458 - progess;
        _bytes[4] = 255;
        _bytes[5] = 0;
    }
    else if (progess >= 458 && progess < 645) {
        _bytes[3] = 0;
        _bytes[4] = 255;
        _bytes[5] = progess - 390;
    }
    else if (progess >= 645 && progess < 900) {
        _bytes[3] = 0;
        _bytes[4] = 900 - progess;
        _bytes[5] = 255;
    }
    else if (progess >= 900 && progess < 1155) {
        _bytes[3] = progess - 900;
        _bytes[4] = 0;
        _bytes[5] = 255;
    }
    else if (progess >= 1155 && progess < 1410) {
        _bytes[3] = 255;
        _bytes[4] = 0;
        _bytes[5] = 1410 - progess;
    }
    else if (progess >= 1410 && progess < 1422) {
        _bytes[3] = 255;
        _bytes[4] = progess - 1410;
        _bytes[5] = 0;
    }
}

- (BOOL)isOff {
    return (_bytes[3] == 0 && _bytes[4] == 0 && _bytes[5] == 0);
}

- (void)senNotifition {
//    NSNotification *noti = [[NSNotification alloc] initWithName:@"CMDModelOnChanged" object:nil userInfo:@{@"on": [NSNumber numberWithBool:self.on]}];
//    [[NSNotificationCenter defaultCenter] postNotification:noti];
}
#pragma mark - getter
- (BOOL)on {
    return _bytes[6] != 0;
}

#pragma mark - setter
- (void)setSentivity:(int)sentivity {
    _sentivity = sentivity;
    if (sentivity < 0 || sentivity > 0.5) {
        _sentivity = 0.08;
    }
}
@end













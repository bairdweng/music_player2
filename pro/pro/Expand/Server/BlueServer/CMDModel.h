//
//  CMDModel.h
//  pro
//
//  Created by Xiaowz on 16/9/26.
//  Copyright © 2016年 huaxia. All rights reserved.
//

#import <Foundation/Foundation.h>





@class UIColor;

@interface CMDModel : NSObject

@property (nonatomic, assign, readonly) BOOL on;

+ (instancetype) sharedInstance;
//command

@property (nonatomic, assign) int sentivity;
- (void) writeCMD: (Byte[])bytes;
- (NSData *)queryCMD;
- (NSArray<NSData *> *)singleColors;
//- (NSData *)redCMD;
- (NSData *)greenCMD;
- (NSData *)blueCMD;
- (NSData *)pinkCMD;
- (NSData *)yellowCMD;
- (NSData *)babyBlueCMD;
- (NSData *)whiteCMD;
- (NSData *)blackCMD;
- (NSData *)speedCMD: (int)speed;
- (NSData *)brightnessCMD: (int)brightness;
- (NSData *)threeBlinkCMD;
- (NSData *)threeBreathCMD;
- (NSData *)sevenBlinkCMD;
- (NSData *)sevenBreathCMD;
- (NSData *)musicCMD: (float)volume;
- (NSData *)singleMusicCMD: (float)volume;
- (NSData *)powerOff;
- (NSData *)powerOn;

- (NSData *)singleColorCMD: (int)progess;
- (UIColor *)singleColor: (int)progess;
- (NSData *)getCuttentData;

@end

//
//  VoiceHelper.h
//  pro
//
//  Created by Xiaowz on 16/10/10.
//  Copyright © 2016年 huaxia. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VoiceHelperDelegate <NSObject>

@optional
- (void) volumeDidChanged: (double)volume;

@end

@interface VoiceHelper : NSObject
@property (nonatomic, weak) id<VoiceHelperDelegate> delegate;
+ (instancetype) sharedInstance;
- (void)pause;
- (void)record;
@end

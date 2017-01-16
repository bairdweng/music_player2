//
//  ServiceManage.h
//  pro
//
//  Created by Baird-weng on 2017/1/10.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceManage : NSObject
+(instancetype)sharedManager;
-(void)regisDevice;
@end

//
//  BlueServerManager.m
//  pro
//
//  Created by Xiaowz on 16/9/26.
//  Copyright © 2016年 huaxia. All rights reserved.
//

#import "BlueServerManager.h"
#import <UIKit/UIKit.h>
#import "MainMacos.h"

#import "CMDModel.h"


static BlueServerManager *_instance;
static NSString *const name = @"SH-HC-08";

@implementation BlueServerManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [BlueServerManager new];
    });
    return _instance;
}
//发送数据。
-(void)sendData:(NSData *)data{
    if (data&&self.currentPeripheral&&self.currentcharacteristic){
        NSLog(@"result============%@",data);
        Byte *testByte = (Byte *)[data bytes];
        for (int i = 0; i<[data length]; i++) {
            printf("testByte = %d\n",testByte[i]);
        }
        [self.currentPeripheral writeValue:data forCharacteristic:self.currentcharacteristic type:CBCharacteristicWriteWithoutResponse];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kBluServerSendData" object:nil userInfo:@{@"data": data}];
    }
}
//查询数据。
- (void)sendQueryData:(NSData *)data{
    if (data&&self.currentPeripheral&&self.currentcharacteristic){
        [self.currentPeripheral writeValue:data forCharacteristic:self.currentcharacteristic type:CBCharacteristicWriteWithoutResponse];
        [self.currentPeripheral readValueForCharacteristic:self.currentcharacteristic];
    }
}
@end

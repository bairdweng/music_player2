//
//  BlueServerManager.h
//  pro
//
//  Created by Xiaowz on 16/9/26.
//  Copyright © 2016年 huaxia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class BlueServerManager;
@class CBPeripheral;

@interface BlueServerManager : NSObject
@property(nonatomic,strong)CBPeripheral *currentPeripheral;
@property (nonatomic, strong)CBCharacteristic *currentcharacteristic;
@property(nonatomic,assign)BOOL isSender;//是否发生请求。
+ (instancetype)sharedInstance;
- (void)sendData: (NSData *)data;
- (void)sendQueryData:(NSData *)data;
@end

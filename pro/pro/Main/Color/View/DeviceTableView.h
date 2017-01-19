//
//  DeviceTableView.h
//  pro
//
//  Created by Baird-weng on 2017/1/19.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void(^selectIndexBlock)(CBPeripheral *peripheral);
@interface DeviceTableView : UITableView
@property(nonatomic,strong)NSArray<CBPeripheral *> *dataSoureArray;

-(void)GetselectIndexBlock:(selectIndexBlock)block;
@end

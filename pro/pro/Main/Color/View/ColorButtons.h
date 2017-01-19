//
//  ColorButtons.h
//  pro
//
//  Created by Baird-weng on 2017/1/17.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ColorButtonsEventBlock)(NSInteger index);

@interface ColorButtons : UIView
@property(nonatomic,assign)NSInteger btnSelectIndex;

-(void)getEventBlck:(ColorButtonsEventBlock)block;
-(void)reset;
@end

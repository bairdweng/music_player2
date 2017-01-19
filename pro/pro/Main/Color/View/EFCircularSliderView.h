//
//  EFCircularSliderView.h
//  pro
//
//  Created by Baird-weng on 2017/1/17.
//  Copyright © 2017年 huaxia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^EFCircularSliderViewEventBlock)(double value);



@interface EFCircularSliderView : UIView
@property (nonatomic) float currentValue;
-(void)getEventBlck:(EFCircularSliderViewEventBlock)block;

@end

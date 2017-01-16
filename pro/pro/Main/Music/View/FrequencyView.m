//
//  FrequencyView.m
//  pro
//
//  Created by Xiaowz on 16/10/10.
//  Copyright © 2016年 huaxia. All rights reserved.
//

#import "FrequencyView.h"
#import "MainMacos.h"

const static CGFloat element_marign = 15;
const static CGFloat element_gap = 5;
const static CGFloat element_width = 8;

const static CGFloat height = 200;

@interface FrequencyView() {
    NSArray<UIColor *> *_backColors;
}
@property (nonatomic, strong) NSArray<UIView *> *elements;

@property (nonatomic, assign, readwrite) NSInteger number;
@end
@implementation FrequencyView

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.width = SCREEN_WIDTH;
    frame.size.height = height;
    frame.origin.x = 0;
    frame.origin.y = SCREEN_HEIGHT - height - 48;
    if (self = [super initWithFrame:frame]) {
        [self configSelf];
        [self configSubview];
    }
    return self;
}


#pragma mark - private
- (void)configSelf {
    //self.backgroundColor = [UIColor redColor];
    _backColors = @[[UIColor purpleColor], [UIColor blueColor], [UIColor greenColor], [UIColor yellowColor], [UIColor redColor]];
}

- (void)configSubview {
    __weak typeof(self) weakSelf = self;
    [self.elements enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf addSubview:obj];
    }];

}
- (NSArray<NSNumber *> *)calculateEelementsHeight: (NSInteger)volume {
    NSMutableArray<NSNumber *> *numbers = [NSMutableArray array];
    for (int i = 0; i < _number; i++) {
        float temp =  volume * ((arc4random() % 10) / 10.0);
        [numbers addObject:[NSNumber numberWithFloat:temp]];
    }
    
    return [numbers copy];
}

- (NSArray<UIView *> *)elements {
    if (!_elements) {
        NSMutableArray<UIView *> *temp = [NSMutableArray array];
        _number = (int)((CGRectGetWidth(self.bounds) - 2 * element_marign + element_gap) / (element_width + element_gap));
        for (int i = 0; i < _number; i++) {
            UIView *element = [UIView new];
            CGRect frame;
            frame.size.width = element_width;
            frame.origin.x = element_marign + (element_gap + element_width) * i;
            frame.size.height = 140;
            frame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(frame);
            element.frame = frame;
            element.backgroundColor = _backColors[i % _backColors.count];
            [temp addObject:element];
        }
        _elements = [temp copy];
        
    }
    return _elements;
}

#pragma mark - setter
- (void)setVolume:(NSInteger)volume {
    _volume = volume;
    
    NSArray<NSNumber *> *temp = [self calculateEelementsHeight:volume];
    [_elements enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect frame = obj.frame;
        frame.size.height = [temp[idx] floatValue];
        frame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(frame);
        obj.frame = frame;
    }];
}

@end

 //
//  MainTabBarController.m
//  pro
//
//  Created by xiaofan on 9/15/16.
//  Copyright © 2016 huaxia. All rights reserved.
//

#import "MainTabBarController.h"
#import "ColorViewController.h"
#import "BLMusicViewController.h"
#import "BabyBluetooth.h"
#import "NewColorViewController.h"
@interface MainTabBarController () {
    NSArray<NSString *> *_controllerNames;
    NSArray<UIViewController *> *_controllers;
    BabyBluetooth *baby;

}

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *view = [[UIView alloc] initWithFrame:self.tabBar.bounds];
    view.backgroundColor = [UIColor whiteColor];
    [self.tabBar insertSubview:view atIndex:0];
    [self configSelf];
    if (ISTOTAKEEFFECT) {
        self.tabBar.tintColor = THETIMECOLOR;
    }
}
#pragma mark - private
- (void)configSelf {
    _controllerNames = @[@"NewColorViewController",@"BLMusicViewController"];
    _controllers = [self controllersFormNames];
    self.viewControllers = _controllers;
}

- (NSArray<UIViewController *> *) controllersFormNames {
    NSMutableArray<UIViewController *> *temps = [NSMutableArray array];
    [_controllerNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id object = [NSClassFromString(obj) new];
        if ([object isKindOfClass:[UIViewController class]]) {
            UIViewController *VC = (UIViewController *)object;
            [temps addObject:VC];
        }
//        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:viewController];
        //[self initNavigation:navi];
        
    }];
    return [temps copy];
}

//- (void)initNavigation: (UINavigationController *)navi {
//    navi.navigationBar.backgroundColor = [UIColor colorWithRed:221.0 / 255 green:221.0 / 255 blue:221.0 / 255 alpha:0.9];
//
//}



























@end

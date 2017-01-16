//
//  MusicListViewController.h
//  Enesco
//
//  Created by Aufree on 11/30/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MusicListViewControllerDelegate <NSObject>
-(void)peakValue:(double)value;
-(void)playerMusic:(BOOL)isplayer;
@end

@interface MusicListViewController : UITableViewController
-(void)musicPlayerStop;
@property(nonatomic,weak)id<MusicListViewControllerDelegate>delegate;
@end

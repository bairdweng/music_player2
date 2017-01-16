//
//  MusicListViewController.m
//  Enesco
//
//  Created by Aufree on 11/30/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//

#import "MusicListViewController.h"
#import "MusicViewController.h"
#import "MusicListCell.h"
#import "MusicIndicator.h"
#import "MBProgressHUD.h"
#import "SimpleAudioPlayer.h"
@interface MusicListViewController () <MusicViewControllerDelegate, MusicListCellDelegate>
@property (nonatomic, strong) NSMutableArray *musicEntities;
@property (nonatomic, assign) NSInteger currentIndex;
@property(nonatomic,assign)BOOL isplayer;
@end

@implementation MusicListViewController{
    AVAudioPlayer *_audioPlayer;
    NSTimer *_musicDurationTimer;
}
-(void)dealloc{
    [_musicDurationTimer invalidate];
}
-(void)musicPlayerStop{
    [_audioPlayer stop];
    self.isplayer = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = @"播放列表";
    self.tableView.separatorColor = [UIColor clearColor];
    [self headerRefreshing];
    self.isplayer = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createIndicatorView];
}

# pragma mark - Custom right bar button item

- (void)createIndicatorView {
    MusicIndicator *indicator = [MusicIndicator sharedInstance];
    indicator.hidesWhenStopped = NO;
    indicator.tintColor = [UIColor redColor];
    if (indicator.state != NAKPlaybackIndicatorViewStatePlaying) {
        indicator.state = NAKPlaybackIndicatorViewStatePlaying;
        indicator.state = NAKPlaybackIndicatorViewStateStopped;
    } else {
        indicator.state = NAKPlaybackIndicatorViewStatePlaying;
    }    
    [self.navigationController.navigationBar addSubview:indicator];
    
    UITapGestureRecognizer *tapInditator = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapIndicator)];
    tapInditator.numberOfTapsRequired = 1;
    [indicator addGestureRecognizer:tapInditator];
}

- (void)handleTapIndicator {
    MusicViewController *musicVC = [MusicViewController sharedInstance];
    if (musicVC.musicEntities.count == 0) {
        [self showMiddleHint:@"暂无正在播放的歌曲"];
        return;
    }
    musicVC.dontReloadMusic = YES;
    [self presentToMusicViewWithMusicVC:musicVC];
    ///Users/baird/Desktop/pro/pro/MusicPlayer/Controllers/MusicList/music_list.json
}

# pragma mark - Load data from server

- (void)headerRefreshing {
    if (!self.musicEntities) {
        self.musicEntities = [[NSMutableArray alloc]init];
    }
    [self.musicEntities removeAllObjects];
    {
        MusicEntity *Entity = [[MusicEntity alloc]init];
        Entity.musicId = @(43);
        Entity.name = @"Old Memory";
        Entity.cover = @"http://aufree.qiniudn.com/images/album/img20/89520/4280541424067346.jpg";
        Entity.musicUrl = @"http://aufree.qiniudn.com/1770059653_2050944_l.mp3";
        Entity.fileName = @"1770059653_2050944_l";
        Entity.artistName = @"三輪学";
        [self.musicEntities addObject:Entity];
    }

    [self.tableView reloadData];
}


# pragma mark - Tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MusicEntity *entity = self.musicEntities[indexPath.row];
    if (!self.isplayer) {
        _audioPlayer =  [SimpleAudioPlayer playFile:[entity.fileName stringByAppendingString:@".mp3"]];
        _audioPlayer.meteringEnabled = YES;//开启仪表计数功能
        self.isplayer = YES;
        NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
       _musicDurationTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
        [myRunLoop addTimer:_musicDurationTimer forMode:NSRunLoopCommonModes];
        [self showMiddleHint:@"播放音乐"];
        if ([self.delegate respondsToSelector:@selector(playerMusic:)]) {
            [self.delegate playerMusic:YES];
        }
    }
    else{
        [_audioPlayer stop];
        self.isplayer = NO;
        [_musicDurationTimer invalidate];
        if ([self.delegate respondsToSelector:@selector(peakValue:)]) {
            [self.delegate peakValue:0.0f];
        }
        [self showMiddleHint:@"音乐停止"];
        if ([self.delegate respondsToSelector:@selector(playerMusic:)]) {
            [self.delegate playerMusic:NO];
        }
    }
  
}
-(void)levelTimerCallback:(NSTimer *)timer{
    [ _audioPlayer updateMeters];
    float temp = [_audioPlayer peakPowerForChannel:0];
    double result = pow(10, (0.05 * temp));
    if ([self.delegate respondsToSelector:@selector(peakValue:)]) {
        [self.delegate peakValue:result];
    }
}
# pragma mark - Jump to music view

- (void)presentToMusicViewWithMusicVC:(MusicViewController *)musicVC {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:musicVC];
    [self presentViewController:navigationController animated:YES completion:nil];
}

# pragma mark - Update music indicator state

- (void)updatePlaybackIndicatorWithIndexPath:(NSIndexPath *)indexPath {
    for (MusicListCell *cell in self.tableView.visibleCells) {
        cell.state = NAKPlaybackIndicatorViewStateStopped;
    }
    MusicListCell *musicsCell = [self.tableView cellForRowAtIndexPath:indexPath];
    musicsCell.state = NAKPlaybackIndicatorViewStatePlaying;
}
- (void)updatePlaybackIndicatorOfVisisbleCells {
   
}

# pragma mark - Tableview datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _musicEntities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *musicListCell = @"musicListCell";
    MusicEntity *music = _musicEntities[indexPath.row];
    MusicListCell *cell = [tableView dequeueReusableCellWithIdentifier:musicListCell];
    cell.backgroundColor = [UIColor clearColor];
    cell.musicNumber = indexPath.row + 1;
    cell.musicEntity = music;
    cell.delegate = self;
    return cell;
}
# pragma mark - HUD
- (void)showMiddleHint:(NSString *)hint {
     UIView *view = [[UIApplication sharedApplication].delegate window];
     MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
     hud.userInteractionEnabled = NO;
     hud.mode = MBProgressHUDModeText;
     hud.label.text = hint;
     hud.label.font = [UIFont systemFontOfSize:15];
     hud.margin = 10.f;
     hud.offset = CGPointMake(hud.offset.x, 0);
     hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}

@end

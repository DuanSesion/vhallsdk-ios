//
//  WatchViewController.m
//  VhallRtmpLiveDemo
//
//  Created by liwenlong on 15/10/10.
//  Copyright © 2015年 vhall. All rights reserved.
//

#import "WatchViewController.h"
#import "VHMoviePlayer.h"
#import "RtmpLiveViewController.h"
#import "ALMoviePlayerController.h"
#import "ALMoviePlayerControls.h"
#import "OpenCONSTS.h"
#import "MBProgressHUD.h"
#import <MediaPlayer/MPMoviePlayerController.h>

@interface WatchViewController ()<VHMoviePlayerDelegate,ALMoviePlayerControllerDelegate>
{
    VHMoviePlayer  *_rtmpMoviePlayer;//播放器
    BOOL _isStart;
    MBProgressHUD * _hud;
    BOOL _isMute;
    BOOL _isAllScreen;
}

@property (weak, nonatomic) IBOutlet UIButton *allScreenBtn;
@property (weak, nonatomic) IBOutlet UILabel *bitRateLabel;
@property (weak, nonatomic) IBOutlet UIButton *startAndStopBtn;
@property(nonatomic,strong)MPMoviePlayerController * hlsMoviePlayer;
@end

@implementation WatchViewController

#pragma mark - Private Method

-(void)initDatas
{
    _isStart = YES;
    _isMute = NO;
    _isAllScreen = NO;
}

- (void)initViews
{
    //阻止iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    _hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view insertSubview:_hud atIndex:0];
    [self registerLiveNotification];
    
   
    if (_watchVideoType == kWatchVideoRTMP) {
        self.view.clipsToBounds = YES;
        _rtmpMoviePlayer = [[VHMoviePlayer alloc]initWithDelegate:self];
        _rtmpMoviePlayer.movieScalingMode = kRTMPMovieScalingModeAspectFit;
        [self.view insertSubview:_rtmpMoviePlayer.moviePlayerView atIndex:0];
    }else if(_watchVideoType == kWatchVideoHLS||_watchVideoType == kWatchVideoPlayback)
    {
        self.hlsMoviePlayer =[[MPMoviePlayerController alloc] init];
        self.hlsMoviePlayer.controlStyle=MPMovieControlStyleDefault;
        [self.hlsMoviePlayer prepareToPlay];
        [self.hlsMoviePlayer.view setFrame:self.view.bounds];  // player的尺寸
        self.hlsMoviePlayer.shouldAutoplay=YES;
        
        //    self.hlsMoviePlayer  = [[ALMoviePlayerController alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        //    self.hlsMoviePlayer.delegate = self; //IMPORTANT!
        //    _rtmpMoviePlayer.moviePlayerController = self.hlsMoviePlayer;
        //    // create the controls
        //    ALMoviePlayerControls * movieControls = [[ALMoviePlayerControls alloc] initWithMoviePlayer:self.hlsMoviePlayer style:ALMoviePlayerControlsStyleDefault];
        //    self.hlsMoviePlayer.shouldAutoplay=YES;
        //    // optionally customize the controls here...
        //    [movieControls setBarColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
        //    [movieControls setTimeRemainingDecrements:YES];
        //    [movieControls setFadeDelay:2.0];
        //    [movieControls setBarHeight:30.f];
        //    [movieControls setSeekRate:2.f];
        //
        //    // assign the controls to the movie player
        //    [self.hlsMoviePlayer setControls:movieControls];
        // add movie player to your view

    }
}

- (void)destoryMoivePlayer
{
    [_rtmpMoviePlayer destroyMoivePlayer];
}
//注册通知
- (void)registerLiveNotification
{
    [self.view addObserver:self forKeyPath:kViewFramePath options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - UIButton Event
- (IBAction)stopWatchBtnClick:(id)sender
{
    if (_isStart) {
        [_hud show:YES];
        if (_watchVideoType == kWatchVideoRTMP)
        {
            //[_rtmpMoviePlayer startPlay:_roomIdText.text withUrl:WatchServerUrl playUrlType:kPlayUrlCDNType];
            [_rtmpMoviePlayer startPlay:_roomId];
            
        }else if(_watchVideoType == kWatchVideoHLS)
        {
            //观看直播
            [VHMoviePlayer startPlay:ROOM_ID withUrl:WatchServerUrl moviePlayer:self.hlsMoviePlayer];
        }else{
            //观看回放地址
            [VHMoviePlayer startPlayback:ROOM_ID moviePlayer:self.hlsMoviePlayer];
        }
        
    }else{
        _bitRateLabel.text = @"";
        [_startAndStopBtn setTitle:@"开始播放" forState:UIControlStateNormal];
        if (_watchVideoType == kWatchVideoRTMP) {
            [_rtmpMoviePlayer stopPlay];
        }else if(_watchVideoType == kWatchVideoHLS||_watchVideoType == kWatchVideoPlayback)
        {
            [_hlsMoviePlayer pause];
        }
        [_hud hide:YES];
    }
    _isStart = !_isStart;
}

- (IBAction)closeBtnClick:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.watchVideoType == kWatchVideoRTMP)
        {
            [weakSelf destoryMoivePlayer];
        }else if(weakSelf.watchVideoType == kWatchVideoHLS||weakSelf.watchVideoType == kWatchVideoPlayback)
        {
            [weakSelf.hlsMoviePlayer stop];
             weakSelf.hlsMoviePlayer = nil;
        }
    }];
}

- (IBAction)muteBtnClick:(id)sender
{
    _isMute = !_isMute;
    [_rtmpMoviePlayer setMute:_isMute];
    if (_isMute) {
        [UIAlertView popupAlertByDelegate:nil title:@"开始静音" message:nil];
    }else{
        [UIAlertView popupAlertByDelegate:nil title:@"静音结束" message:nil];
    }
}

- (IBAction)allScreenBtnClick:(id)sender
{
    _isAllScreen = !_isAllScreen;
    if (_isAllScreen) {
        [_allScreenBtn setTitle:@"自适应" forState:UIControlStateNormal];
        _rtmpMoviePlayer.movieScalingMode = kRTMPMovieScalingModeAspectFill;
    }else{
        [_allScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
        _rtmpMoviePlayer.movieScalingMode = kRTMPMovieScalingModeAspectFit;
    }
}
#pragma mark - Lifecycle Method

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initDatas];
    }
    return self;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initViews];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.watchVideoType == kWatchVideoRTMP)
    {
        _rtmpMoviePlayer.moviePlayerView.frame = self.view.frame;
    }else if(self.watchVideoType == kWatchVideoHLS||self.watchVideoType == kWatchVideoPlayback)
    {
        _hlsMoviePlayer.view.frame = self.view.bounds;
        [self.view insertSubview:self.hlsMoviePlayer.view atIndex:0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //阻止iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self.view removeObserver:self forKeyPath:kViewFramePath];
    VHLog(@"%@ dealloc",[[self class]description]);
}

#pragma mark - VHMoviePlayerDelegate

-(void)connectSucceed:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    [_startAndStopBtn setTitle:@"停止播放" forState:UIControlStateNormal];
}

-(void)bufferStart:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    [_hud show:YES];
}

-(void)bufferStop:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    [_hud hide:YES];
}

-(void)downloadSpeed:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    NSString * content = info[@"content"];
    _bitRateLabel.text = [NSString stringWithFormat:@"%@ kb/s",content];
    //VHLog(@"downloadSpeed:%@",[info description]);
}

- (void)playError:(LivePlayErrorType)livePlayErrorType;
{
    [_hud hide:YES];
    
    void (^resetStartPaly)(NSString * msg) = ^(NSString * msg){
        _isStart = YES;
        _bitRateLabel.text = @"";
        [_startAndStopBtn setTitle:@"开始播放" forState:UIControlStateNormal];
        if (APPDELEGATE.isNetworkReachable) {
            [UIAlertView popupAlertByDelegate:nil title:msg message:nil];
        }else{
            [UIAlertView popupAlertByDelegate:nil title:@"没有可以使用的网络" message:nil];
        }
    };
    
    NSString * msg = @"";
    switch (livePlayErrorType) {
        case kLivePlayParamError:
        {
            msg = @"参数错误";
            resetStartPaly(msg);
        }
        break;
        case kLivePlayRecvError:
        {
            msg = @"对方已经停止直播";
            resetStartPaly(msg);
        }
            break;
        case kLivePlayCDNConnectError:
        {
            msg = @"服务器任性...连接失败";
            resetStartPaly(msg);
        }
            break;
        case kLivePlayGetUrlError:
        {
            msg = @"获取服务器地址报错";
            [MBHUDHelper showWarningWithText:msg];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - ALMoviePlayerControllerDelegate
- (void)movieTimedOut
{
    
}

- (void)moviePlayerWillMoveFromWindow
{
    if (![self.view.subviews containsObject:self.hlsMoviePlayer.view])
        [self.view insertSubview:self.hlsMoviePlayer.view atIndex:0];
    //you MUST use [ALMoviePlayerController setFrame:] to adjust frame, NOT [ALMoviePlayerController.view setFrame:]
    //[self.hlsMoviePlayer setFrame:self.view.frame];
}

#pragma mark - ObserveValueForKeyPath

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:kViewFramePath])
    {
        CGRect frame = [[change objectForKey:NSKeyValueChangeNewKey]CGRectValue];
        if (self.watchVideoType == kWatchVideoRTMP)
        {
            _rtmpMoviePlayer.moviePlayerView.frame = frame;
            
        }else if(self.watchVideoType == kWatchVideoHLS||self.watchVideoType == kWatchVideoPlayback)
        {
            _hlsMoviePlayer.view.frame = frame;
            [self.view insertSubview:self.hlsMoviePlayer.view atIndex:0];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

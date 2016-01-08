//
//  DemoViewController.m
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import "RtmpLiveViewController.h"
#import "CameraEngineRtmp.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "UIAlertView+ITTAdditions.h"
#import "CONSTS.h"
#import "MBProgressHUD.h"

@interface RtmpLiveViewController ()<CameraEngineRtmpDelegate,UITextFieldDelegate>
{
    BOOL  _isStart;
    BOOL  _torchType;
    BOOL  _onlyVideo;
    BOOL  _isFontVideo;
    MBProgressHUD * _hud;
}

@property (weak, nonatomic) IBOutlet UIView *perView;
@property (strong, nonatomic)CameraEngineRtmp *engine;
@property (weak, nonatomic) IBOutlet UIButton *startAndStopBtn;
@property (weak, nonatomic) IBOutlet UILabel *bitRateLabel;
@property (weak, nonatomic) IBOutlet UIButton *torchBtn;

@end

@implementation RtmpLiveViewController

#pragma mark - UIButton Event
- (IBAction)closeBtnClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    [self.navigationController popViewControllerAnimated:NO];
    [_engine destoryObject];
    self.engine = nil;
}

- (IBAction)swapBtnClick:(id)sender
{
    _isFontVideo = !_isFontVideo;
    if (_isFontVideo) {
        _torchBtn.hidden = YES;
    }else{
        _torchBtn.hidden = NO;
    }
    [_engine swapFrontAndBackCameras];
}

- (IBAction)torchBtnClick:(id)sender
{
    _torchType = !_torchType;
    [_engine openDeviceTorch:_torchType];
}

- (IBAction)onlyVideoBtnClick:(id)sender
{
    _onlyVideo = !_onlyVideo;
    if (_onlyVideo)
    {
        [_engine pauseAudioCapture];
        [UIAlertView popupAlertByDelegate:nil title:@"开始静音" message:nil cancel:@"知道了" others:nil];
    }
    else
    {
        [_engine startAudioCapture];
        [UIAlertView popupAlertByDelegate:nil title:@"结束静音" message:nil cancel:@"知道了" others:nil];
    }
}

- (IBAction)startPlayer
{
    if (!_isStart)
    {
        [_hud show:YES];
        _engine.videoResolution = _videoResolution;
        _engine.bitRate = self.bitrate;
        //[_engine startLiveWithId:_roomIdText.text withUrl:OpenPushServerUrl token:OpenToken];
        [_engine startLiveWithId:_roomId token:OpenToken];

    }else{
        _bitRateLabel.text = @"";
        [_hud hide:YES];
        [_startAndStopBtn setTitle:@"开始直播" forState:UIControlStateNormal];
        [_engine disconnect];//停止向服务器推流
    }
    _isStart = !_isStart;
}

#pragma mark - Private Method

-(void)initDatas
{
    _isStart = NO;
    _torchType = NO;
    _onlyVideo = NO;
    _isFontVideo = NO;
    _videoResolution = kGeneralVideoResolution;
}

- (void)initViews
{
    //阻止iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self registerLiveNotification];
    _hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:_hud];
}

- (void)initCameraEngine
{
    DeviceOrgiation deviceOrgiation;
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        deviceOrgiation = kDevicePortrait;
    }else{
        deviceOrgiation = kDeviceLandSpaceRight;
    }
    self.engine = [[CameraEngineRtmp alloc] initWithOrgiation:deviceOrgiation];
    self.engine.videoResolution = _videoResolution;
    self.engine.displayView.frame = _perView.bounds;
    self.engine.delegate = self;
    [self.perView insertSubview:_engine.displayView atIndex:0];
    
    //视频初始化
    [_engine initVideo];
    //音频初始化
    [_engine initAudio];
    //会话流启动
    [_engine initSession];
    //开始视频采集
    [_engine startVideoCapture];
}

//注册通知
- (void)registerLiveNotification
{
    [self.view addObserver:self forKeyPath:kViewFramePath options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - CameraEngineDelegate

-(void)firstCaptureImage:(UIImage *)image
{
    VHLog(@"第一张图片");
}

-(void)publishStatus:(LiveStatus)liveStatus withContent:(NSString *)content
{
    void (^resetStartPaly)(NSString * msg) = ^(NSString * msg){
        _isStart = YES;
        _bitRateLabel.text = @"";
        [_startAndStopBtn setTitle:@"开始直播" forState:UIControlStateNormal];
        if (APPDELEGATE.isNetworkReachable) {
            [UIAlertView popupAlertByDelegate:nil title:msg message:nil];
        }else{
             [UIAlertView popupAlertByDelegate:nil title:@"没有可以使用的网络" message:nil];
        }
        
    };
    
    switch (liveStatus) {
        case kLiveStatusUploadSpeed:
        {
            _bitRateLabel.text = [NSString stringWithFormat:@"%@ kb/s",content];
        }
            break;
        case kLiveStatusPushConnectSucceed:
        {
            [_hud hide:YES];
            [_startAndStopBtn setTitle:@"停止直播" forState:UIControlStateNormal];
        }
            break;
        case kLiveStatusSendError:
        {
            [_hud hide:YES];
            resetStartPaly(@"网断啦！不能再带你直播带你飞了");
        }
            break;
        case kLiveStatusPushConnectError:
        {
            [_hud hide:YES];
            resetStartPaly(@"服务器任性...连接失败");
        }
            break;
        case kLiveStatusParamError:
        {
            [_hud hide:YES];
            resetStartPaly(@"参数错误");
        }
            break;
        case kLiveStatusGetUrlError:
        {
            [_hud hide:YES];
            [MBHUDHelper showWarningWithText:@"获取服务器地址报错！"];
        }
            break;
        default:
            break;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //初始化CameraEngine
    [self initCameraEngine];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //允许iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self.view removeObserver:self forKeyPath:kViewFramePath];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
     VHLog(@"%@ dealloc",[[self class]description]);
}

#pragma mark - ObserveValueForKeyPath
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:kViewFramePath]){
        CGRect frame = [[change objectForKey:NSKeyValueChangeNewKey]CGRectValue]; 
        self.engine.displayView.frame = frame;
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

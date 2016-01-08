//
//  CameraEngine.h
//  Encoder Demo
//
//  Created by Geraint Davies on 19/02/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "OpenCONSTS.h"


@protocol CameraEngineRtmpDelegate <NSObject>
/**
 *  采集到第一帧的回调
 *
 *  @param image 第一帧的图片
 */
-(void)firstCaptureImage:(UIImage*)image;
/**
 *  发起直播时的状态
 *
 *  @param liveStatus 直播状态
 */
-(void)publishStatus:(LiveStatus)liveStatus withContent:(NSString*)content;

@end

@interface CameraEngineRtmp : NSObject
{
    
}
/**
 *  推流连接的超时时间，单位为毫秒 默认2000
 */
@property (nonatomic,assign)int publishConnectTimeout;
/**
 *  推流断开重连的次数 默认为 1
 */
@property (nonatomic,assign)int publishConnectTimes;
/**
 *  用来显示摄像头拍摄内容的View
 */
@property(nonatomic,strong,readonly)UIView * displayView;
/**
 *  代理
 */
@property(nonatomic,assign)id <CameraEngineRtmpDelegate> delegate;
/**
 *  视频分辨率 默认值是kGeneralViodeResolution 640*480
 */
@property(nonatomic,assign)VideoResolution videoResolution;
/**
 *  码率设置
 */
@property(nonatomic,assign)NSInteger bitRate;
/**
 *  设置静音
 */
@property(assign)BOOL isMute;

//采集设备初始化
- (id)initWithOrgiation:(DeviceOrgiation)orgiation;

//初始化视频
- (void)initVideo;

//初始化音频
- (void)initAudio;

//初始化会话流
- (void)initSession;

//开始视频采集
- (void)startVideoCapture;

//停止视频采集 插拔耳机或者切换摄像头后调用，先调用该方法 再调用- (void)startVideoCapture;
- (void)stopVideoCapture;

//开启音频采集;
- (void)startAudioCapture;

//暂停音频采集
- (void)pauseAudioCapture;

//停止音频采集
- (void)stopAudioCapture;

/**
 *  开始发起直播 开始向后台推送视频流和音频流
 *
 *  @param liveId  活动Id
 *  @param url     服务器地址
 *  @param token   token
 */
- (void)startLiveWithId:(NSString*)liveId withUrl:(NSString*)url token:(NSString*)token;

/**
 *  开始发起直播 开始向后台推送视频流和音频流
 *
 *  @param liveId 活动Id
 *  @param token  token
 */
- (void)startLiveWithId:(NSString*)liveId token:(NSString*)token;

//仅给App使用
- (void)setRoomId:(NSString *)liveId
            token:(NSString *)token rtmpUrl:(NSString*)rtmpUrl;

//切换摄像头
- (void)swapFrontAndBackCameras;

//手动对焦
-(void)setFoucsFoint:(CGPoint)newPoint;

//根据手势可以调节摄像头近景远景(变焦)
-(void)startVideoRecording:(CGFloat)currentScale;

//设置直播方向
- (void)setCarmerPerViewFrame:(CGRect)rect orgiation:(DeviceOrgiation)orgiation;

//打开闪光灯  YES打开   NO不打开
- (void)openDeviceTorch:(BOOL)onOrOff;

//断网后重连
-(void)reconnect;

/**
 *  销毁初始化数据
 */
- (void)destoryObject;

/**
 *  断开推流的连接
 */
- (void)disconnect;

@end

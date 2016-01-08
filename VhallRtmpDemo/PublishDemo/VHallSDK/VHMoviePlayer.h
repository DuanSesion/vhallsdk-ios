//
//  VHMoviePlayer.h
//  MoviePlayer
//
//  Created by vhall on 15/6/18.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "OpenCONSTS.h"

@class VHMoviePlayer;

@protocol VHMoviePlayerDelegate <NSObject>

@optional
/**
 *  播放连接成功
 */
- (void)connectSucceed:(VHMoviePlayer*)moviePlayer info:(NSDictionary*)info;
/**
 *  缓冲开始回调
 */
- (void)bufferStart:(VHMoviePlayer*)moviePlayer info:(NSDictionary*)info;

/**
 *  缓冲结束回调
 */
-(void)bufferStop:(VHMoviePlayer*)moviePlayer info:(NSDictionary*)info;

/**
 *  下载速率的回调
 *
 *  @param moviePlayer
 *  @param info        下载速率信息 单位kbps
 */
- (void)downloadSpeed:(VHMoviePlayer*)moviePlayer info:(NSDictionary*)info;
/**
 *  网络状态的回调
 *
 *  @param moviePlayer
 *  @param info        网络状态信息  content的值越大表示网络越好
 */
- (void)netWorkStatus:(VHMoviePlayer*)moviePlayer info:(NSDictionary*)info;

/**
 *  播放时错误的回调
 *
 *  @param livePlayErrorType 直播错误类型
 */
- (void)playError:(LivePlayErrorType)livePlayErrorType;

@end

@interface VHMoviePlayer : NSObject
{
    
}
@property(nonatomic,assign)id <VHMoviePlayerDelegate> delegate;
@property(nonatomic,strong,readonly)UIView * moviePlayerView;
@property(nonatomic,assign)int timeout;   //RTMP链接的超时时间 默认2秒，单位为毫秒
@property(nonatomic,assign)int reConnectTimes; //RTMP 断开后的重连次数 默认 2次
@property(nonatomic,assign)int bufferTime; //RTMP 的缓冲时间 默认 2秒 单位为秒 必须>0 值越小延时越小
/**
 *  视频View的缩放比例 默认是自适应模式
 */
@property(nonatomic,assign)RTMPMovieScalingMode movieScalingMode;

/**
 *  初始化VHMoviePlayer对象
 *
 *  @param delegate
 *
 *  @return   返回VHMoviePlayer的一个实例
 */
- (instancetype)initWithDelegate:(id <VHMoviePlayerDelegate>)delegate;

/**
 *  开始播放视频
 *
 *  @param activityId  活动id
 *  @param url         服务器地址
 *  @param playUrlType 播放url的类型
 */
-(void)startPlay:(NSString*)activityId withUrl:(NSString*)url playUrlType:(PlayUrlType)playUrlType;
/**
 *  开始播放视频
 *
 *  @param activityId  活动id
 */
-(void)startPlay:(NSString*)activityId;

/**
 *  开始播放视频
 *
 *  @param rtmpUrl    rtmp地址
 */
-(void)startPlayWithRtmpUrl:(NSString *)rtmpUrl;

/**
 *  观看直播视频   (仅HLS可用)
 *
 *  @param activityId            活动id
 *  @param url                   直播服务器地址
 *  @param moviePlayerController MPMoviePlayerController 对象
 */
+(void)startPlay:(NSString*)activityId withUrl:(NSString*)url moviePlayer:(MPMoviePlayerController *)moviePlayerController;

/**
 *  观看回放视频   (仅HLS可用)
 *
 *  @param activityId            活动id
 *  @param moviePlayerController MPMoviePlayerController 对象
 */
+(void)startPlayback:(NSString*)activityId moviePlayer:(MPMoviePlayerController *)moviePlayerController;

/**
 *  设置静音
 *
 *  @param mute 是否静音
 */
- (void)setMute:(BOOL)mute;

/**
 *  停止播放
 */
-(void)stopPlay;

/**
 *  销毁播放器
 */
- (void)destroyMoivePlayer;

@end

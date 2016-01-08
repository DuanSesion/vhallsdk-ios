//
//  OpenCONSTS.h
//  VHMoviePlayer
//
//  Created by liwenlong on 15/10/14.
//  Copyright © 2015年 vhall. All rights reserved.
//

#ifndef OpenCONSTS_h
#define OpenCONSTS_h

//设置摄像头取景方向
typedef NS_ENUM(int,DeviceOrgiation)
{
    kDevicePortrait,
    kDeviceLandSpaceRight,
    kDeviceLandSpaceLeft
};

typedef NS_ENUM(int,VideoResolution)
{
    kLowVideoResolution = 0,       //低分边率       352*288
    kGeneralVideoResolution,       //普通分辨率     640*480
    kHVideoResolution,             //高分辨率       960*540  （暂时只支持HLS观看）
    kHDVideoResolution             //超高分辨率     1280*720
};

typedef NS_ENUM(int,LiveStatus)
{
    kLiveStatusBufferingStart = 0,   //播放缓冲开始
    kLiveStatusBufferingStop,        //播放缓冲结束
    kLiveStatusPushConnectSucceed,   //直播连接成功
    kLiveStatusPushConnectError,     //直播连接失败
    kLiveStatusCDNConnectSucceed,    //播放CDN连接成功
    kLiveStatusCDNConnectError,      //播放CDN连接失败
    kLiveStatusParamError,           //参数错误
    kLiveStatusRecvError,            //播放接受数据错误
    kLiveStatusSendError,            //直播发送数据错误
    kLiveStatusDownloadSpeed,        //播放下载速率
    kLiveStatusUploadSpeed,          //直播上传速率
    kLiveStatusNetWorkStatus,        //网络状态 值越大代表网络状态越好
    kLiveStatusGetUrlError,          //获取服务器地址失败
    kLiveStatusWidthAndHeight        //返回播放视频的宽和高
};

typedef NS_ENUM(int,PlayUrlType)
{
    kPlayUrlCDNType = 0,       //使用CDN线路播放
    kPlayUrlNoCDNType = 1,     //不使用CDN线路播放
    kPlayUrlM3U8Type = 2       //使用m3u8地址播放
};

typedef NS_ENUM(int,LivePlayErrorType)
{
    kLivePlayGetUrlError = kLiveStatusGetUrlError,        //获取服务器rtmpUrl错误
    kLivePlayParamError = kLiveStatusParamError,          //参数错误
    kLivePlayRecvError  = kLiveStatusRecvError,           //接受数据错误
    kLivePlayCDNConnectError = kLiveStatusCDNConnectError //CDN链接失败
};

//RTMP 播放器View的缩放状态
typedef NS_ENUM(int,RTMPMovieScalingMode)
{
    kRTMPMovieScalingModeNone,       // No scaling
    kRTMPMovieScalingModeAspectFit,  // Uniform scale until one dimension fits
    kRTMPMovieScalingModeAspectFill, // Uniform scale until the movie fills the visible bounds. One dimension may have clipped contents
};

#pragma mark - shaders

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

NSString *const fshShaderString = SHADER_STRING
(
 varying lowp vec2 TexCoordOut;
 
 uniform sampler2D SamplerY;
 uniform sampler2D SamplerU;
 uniform sampler2D SamplerV;
 
 void main(void)
{
    mediump vec3 yuv;
    lowp vec3 rgb;
    
    yuv.x = texture2D(SamplerY, TexCoordOut).r;
    yuv.y = texture2D(SamplerU, TexCoordOut).r - 0.5;
    yuv.z = texture2D(SamplerV, TexCoordOut).r - 0.5;
    
    rgb = mat3( 1,       1,         1,
               0,       -0.39465,  2.03211,
               1.13983, -0.58060,  0) * yuv;
    
    gl_FragColor = vec4(rgb, 1);
}
);

NSString *const vshShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec2 TexCoordIn;
 varying vec2 TexCoordOut;
 
 void main(void)
{
    gl_Position = position;
    TexCoordOut = TexCoordIn;
}
);

#endif /* OpenCONSTS_h */

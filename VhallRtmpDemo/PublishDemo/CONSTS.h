//
//  CONSTS.h
//  VhallRtmpDemo
//
//  Created by liwenlong on 15/10/10.
//  Copyright © 2015年 vhall. All rights reserved.
//

#ifndef CONSTS_h
#define CONSTS_h

#define ROOM_ID     @""

#define OpenToken   @""

#define OpenPushServerUrl @"http://open.vhall.com/config/pub-server"
#define WatchServerUrl    @"http://open.vhall.com/config/watch-server"


#if DEBUG  // 调试状态, 打开LOG功能
#define VHLog(...) NSLog(__VA_ARGS__)
#else // 发布状态, 关闭LOG功能
#define VHLog(...)
#endif


typedef NS_ENUM(int,WatchVideoType)
{
    kWatchVideoNone,
    kWatchVideoRTMP,
    kWatchVideoHLS,
    kWatchVideoPlayback
};


#define kViewFramePath         @"frame"

#pragma mark - iphone detection functions

#define APPDELEGATE [AppDelegate getAppDelegate]

#endif /* CONSTS_h */

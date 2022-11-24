//
//  KXKTVSDKValue.h
//  KXKTVSDK
//
//  Created by kx on 2022/3/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 采样率
 */
typedef NS_ENUM(UInt32, KXKTVSampleRate) {
    ///以伴奏的采样率为准
    SampleRateAuto = 0,
    ///44.1K的采样率
    SampleRate44100 = 44100,
    ///32k的采样率
    SampleRate32000 = 32000,
    ///24k的采样率
    SampleRate24000 = 24000,
    ///16k的采样率
    SampleRate16000 = 16000
};

/**
 * 声道
 */
typedef NS_ENUM(UInt32 , KXKTVChannel) {
    ///单声道
    ChannelMono = 1,
    ///立体声
    ChannelStereo = 2
};


/**
 * K歌状态定义
 */
typedef NS_ENUM(UInt32 , KXKTVPlayStatus) {
    ///关闭
    KXPlayStatusClose,
    ///打开
    KXPlayStatusOpen,
    ///已打开
    KXPlayStatusOpened,
    ///播放
    KXPlayStatusPlay,
    ///暂停
    KXPlayStatusPause,
};

/**
 * 异常状态码
 */
typedef NS_ENUM(NSInteger,KTVSDKErrorCode) {
    ///无麦克风权限
    RecordPermissionGranted = -100,
    ///KTV服务启动失败
    OpenRecPlayError = -101,
    ///无服务权限
    OptionPermissionGranted = -102,
    ///伴奏文件不存在
    AccomFileNotFound = -1,
    ///录音文件不存在
    RecFileNotFound = -2,
    ///导出新录音文件失败
    ExportRecError = -3,
    ///导出的新录音文件已存在
    ExportRecFileExist = -4,
    ///导唱文件不存在
    GuideFileNotFound = -5,
};

/**
 歌词显示样式
 */
typedef NS_ENUM(NSInteger,KTVSDKLrcShowMode) {
    KTVSDKLrcKTVMode = 0, //KTV双行模式
    KTVSDKLrcMultilineMode,//多行模式
};

NS_ASSUME_NONNULL_END

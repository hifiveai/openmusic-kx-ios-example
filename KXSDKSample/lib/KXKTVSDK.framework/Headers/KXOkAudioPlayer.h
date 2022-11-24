//
//  KXOkAudioPlayer.h
//  KXKTVSDK
//
//  Created by kx on 2022/3/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <KXKTVSDK/KXKTVSDKValue.h>
#import <KXKTVSDK/KTVSDKSongItem.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * K歌服务代理
 *
 * 回调K歌服务的状态、异常、演唱得分
 */
@protocol KXOkAudioPlayerDelegate <NSObject>

/**
 * K歌服务异常
 *
 * @param sender 事件触发者
 * @param error 异常信息
 *
 * @see errorCode定义:KTVSDKErrorCode
 * @see sender:KXOkAudioPlayer
 */
- (void)recPlayer:(id)sender didError:(NSError *)error;

/**
 * 伴奏播放完，自动结束K歌会回调此代理
 *
 * @param sender 事件触发者
 *
 * @see sender:KXOkAudioPlayer
 *
 */
- (void)recPlayerDidPlayEnd:(id)sender;

/**
 * K歌服务状态变化
 *
 * @param sender 事件触发者
 * @param status K歌状态
 *
 * @see 状态定义:KXKTVPlayStatus
 * @see sender:KXOkAudioPlayer
 *
 */
- (void)recPlayer:(id)sender didRecStatusChanged:(KXKTVPlayStatus)status;

/**
 * 演唱得分
 * 分数有变化时，会触发此回调
 *
 * @param sender 事件触发者
 * @param totalScore 总分(0-100)
 *
 * @see sender:KXOkAudioPlayer
 *
 */
- (void)recPlayer:(id)sender didCallbackTotalScore:(float)totalScore;

/**
 * 单句得分
 * 句子有得分时，会有此回调
 *
 * @param sender 事件触发者
 * @param singleScore 单句得分(0-100)
 *
 * @see sender:KXOkAudioPlayer
 *
 */
- (void)recPlayer:(id)sender didCallbackSingleScore:(float)singleScore;


/**
 * 实时回调录音的人声PCM
 *
 * @param sender 事件触发者
 * @param pcmData pcm数据
 *
 * @see sender:KXOkAudioPlayer
 * @warning ⚠️不要在此回调中做耗时任务
 *
 */
- (void)recPlayer:(id)sender didCallbackPCM:(NSData *)pcmData;

/**
 * 实时回调伴奏+人声的PCM
 *
 * @param sender 事件触发者
 * @param pcmData pcm数据
 *
 * @see sender:KXOkAudioPlayer
 * @warning ⚠️不要在此回调中做耗时任务
 */
- (void)recPlayer:(id)sender didCallbackMixPCM:(NSData *)pcmData;

@end


/**
 * K歌服务类
 *
 * 集成歌词展示、评分、歌曲演唱为一体的服务
 *
 * * 支持逐字歌词、逐行歌词、静态歌词
 *
 * * 支持演唱评分
 *
 * * 支持调节伴奏音量、伴奏升降Key、麦克风音量、美声音量(仅佩戴耳机时可用)，
 *
 * * 支持EQ调节
 *
 * * 支持耳机返听开关(仅佩戴耳机时可用)
 *
 * * 支持导唱开关(有导唱文件时可用)
 *
 */
@interface KXOkAudioPlayer : NSObject

/**
 * K歌服务代理
 *
 * 建议在openKTV之前设置
 * @see 回调定义:KXOkAudioPlayerDelegate
 * @see 开启K歌服务 openKTV:recOutPath:nowStart:
 */
@property (nonatomic,weak) id<KXOkAudioPlayerDelegate> delegate;

/**
 * @brief 采样率, 有读写权限
 *
 * 默认SampleRate44100
 *
 * @warning 警告:需要在openKTV之前调用
 * @see 支持的定义:KXKTVSampleRate
 * @see 开启K歌服务 openKTV:recOutPath:nowStart:
 */
@property (nonatomic,assign) KXKTVSampleRate sampleRate;
/**
 * @brief 声道数, 有读写权限
 *
 *  默认ChannelStereo
 *
 * @warning 警告:需要在openKTV之前调用
 * @see 支持的定义:KXKTVChannel
 * @see 开启K歌服务 openKTV:recOutPath:nowStart:
 */
@property (nonatomic,assign) KXKTVChannel channel;

/**
 * @brief 伴奏音量, 有读写权限.
 *
 *  取值范围(0.0~1.0)
 *
 */
@property (nonatomic,assign) float accompVolume;

/**
 * @brief 伴奏升降调, 有读写权限
 *
 * 取值范围(-5~5)
 */
@property (nonatomic,assign) int accompKeyValue;

/**
 * @brief 麦克风音量, 有读写权限
 *
 * 取值范围(0.0~1.0)
 */
@property (nonatomic,assign) float recordVolume;

/**
 * @brief 美声, 有读写权限
 *
 * 取值范围(0.0~1.0)
 *
 * @warning 警告:佩戴耳机的演唱时，才可以调整该值
 */
@property (nonatomic,assign) float reverbValue;
/**
 * @brief 音色效果
 *
 *  小于0浑厚，大于0清亮
 *  取值范围(-1.0~1.0)
 *
 * @warning 警告:佩戴耳机的演唱时，才可以调整该值
 */
@property (nonatomic,assign) float EQValue;

/**
 * @brief 耳返开关
 *
 * true:有耳返，false:无耳返 默认:true
 *
 * @warning 警告:佩戴耳机的演唱时，才可以调整该值
 *
 */
@property (nonatomic,assign) BOOL earBackOn;

/**
 * @brief 导唱音量
 *
 * 取值范围(0.0~1.0)，默认:0.0
 *
 */
@property (nonatomic,assign) float guideSingVolume;

/**
 * @brief 当前K歌状态
 *
 * @see 状态定义:KXKTVPlayStatus
 */
@property (nonatomic,readonly) KXKTVPlayStatus currKTVStatus;
/**
 * @brief K歌时长
 *
 * 时长(单位秒)
 */
@property (nonatomic,readonly) float currKTVPos;
/**
 * @brief K歌总时长
 *
 * 时长(单位秒)
 */
@property (nonatomic,readonly) float currKTVDuration;


/**
 * @brief 构造K歌服务类
 *
 * 通过该构造函数初始化采样率、声道、事件代理
 *
 * @param sampleRate 采样率,默认SampleRate44100
 * @param channel 声道，默认ChannelStereo
 * @param aDelegate 事件代理
 *
 * @see sampleRate定义:KXKTVSampleRate
 * @see channel定义:KXKTVChannel
 * @see delegate定义:KXOkAudioPlayerDelegate
 *
 * @return KXOkAudioPlayer实例
 */
- (id)initWithSampleRate:(KXKTVSampleRate)sampleRate
                 channel:(KXKTVChannel)channel
                delegate:(id<KXOkAudioPlayerDelegate>)aDelegate;


/**
 * @brief 设置用于展示音准线的视图
 *
 * 假如您需要显示音准线视图，可以进行设定
 *
 * @param view 音准线视图窗口(调用者需要自己初始化一个View，视图大小和位置由调用者初始化，SDK会铺满在该视图上进行呈现)
 *
 * @warning 需要在openKTV之前调用
 * @see 开启K歌服务 openKTV:recOutPath:nowStart:
 */
- (void)setTrackView:(nonnull UIView *)view;

/**
 * @brief 设置用于展示歌词的视图
 *
 * 假如您需要显示歌词视图，可以进行设定 (默认多行歌词显示样式)
 *
 * @param view 歌词视图窗口(调用者需要自己初始化一个View，视图大小和位置由调用者初始化，SDK会铺满在该视图上进行呈现)
 *
 * @warning 需要在openKTV之前调用
 * @see 开启K歌服务 openKTV:recOutPath:nowStart:
 */
- (void)setLrcView:(nonnull UIView *)view;
/**
 * @brief 设置用于展示歌词的视图
 *
 * 假如您需要显示歌词视图，可以进行设定
 *
 * @param view 歌词视图窗口(调用者需要自己初始化一个View，视图大小和位置由调用者初始化，SDK会铺满在该视图上进行呈现)
 * @param aMode 歌词显示样式
 *
 * @warning 需要在openKTV之前调用
 * @see 开启K歌服务 openKTV:recOutPath:nowStart:
 * @see aMode定义KTVSDKLrcShowMode
 */
- (void)setLrcView:(UIView *)view mode:(KTVSDKLrcShowMode)aMode;

/**
 * @brief 设置用于展示歌词的行间距
 *
 * 假如您需要显示歌词行间距高一些，可以进行设定
 *
 * @param height 歌词行间距
 *
 * @warning 需要在setLrcView之后调用
 * @see 设置歌词视图 setLrcView:
 */
- (void)setLrcLineSpaceHeight:(float)height;

/**
 * @brief 打开K歌服务
 *
 * 该函数的触发会有状态回调。启动K歌服务后，会即时保存录音文件。
 *
 * @param songId 伴奏ID
 * @param guideFilePath 导唱文件沙盒路径(没有导唱传nil)
 * @param accomFilePath 伴奏文件沙盒路径
 * @param lrcFilePath 歌词文件沙盒路径(没有歌词传nil)
 * @param toneFilePath 评分档文件沙盒路径(没有评分档传nil)
 * @param recOutPath 录音文件保存到沙盒的路径(文件路径需要有读写权限且不存在，否则会导致录音保存失败)
 * @param nowStart 开启K歌服务后，立即开始K歌。（true:立即开始，false:手动开始）
 *
 * @warning 不再使用K歌服务后，您需要调用closeKTV用于关闭K歌服务中的资源。
 * @warning recOutPath删除时需要通过KXKTVSDKManager类的clearAudioInfoWithRecPath函数进行删除
 * @see 关闭K歌服务 closeKTV
 * @see 删除录音文件 KXKTVSDKManager:clearAudioInfoWithRecPath
 */
- (void)openKTV:(nonnull NSString *)songId guideFilePath:(nullable NSString *)guideFilePath
  accomFilePath:(nonnull NSString *)accomFilePath lrcFilePath:(nullable NSString *)lrcFilePath
   toneFilePath:(nullable NSString *)toneFilePath recOutPath:(nonnull NSString *)recOutPath nowStart:(BOOL)nowStart DEPRECATED_MSG_ATTRIBUTE("该函数1.0版以后不再维护, 使用openKTV:guideFilePath:accomFilePath:kkLrcFilePath:recOutPath:nowStart取代");

/**
 * @brief KKLrc模式，打开K歌服务
 *
 * 该函数的触发会有状态回调。启动K歌服务后，会即时保存录音文件。
 *
 * @param songId 伴奏ID
 * @param guideFilePath 导唱文件沙盒路径(没有导唱传nil)
 * @param accomFilePath 伴奏文件沙盒路径
 * @param kkLrcFilePath 歌词文件沙盒路径(没有歌词传nil)
 * @param recOutPath 录音文件保存到沙盒的路径(文件路径需要有读写权限且不存在，否则会导致录音保存失败)
 * @param nowStart 开启K歌服务后，立即开始K歌。（true:立即开始，false:手动开始）
 *
 * @warning 不再使用K歌服务后，您需要调用closeKTV用于关闭K歌服务中的资源。
 * @warning recOutPath删除时需要通过KXKTVSDKManager类的clearAudioInfoWithRecPath函数进行删除
 * @see 关闭K歌服务 closeKTV
 * @see 删除录音文件 KXKTVSDKManager:clearAudioInfoWithRecPath
 */
- (void)openKTV:(nonnull NSString *)songId guideFilePath:(nullable NSString *)guideFilePath
  accomFilePath:(nonnull NSString *)accomFilePath kkLrcFilePath:(nullable NSString *)kkLrcFilePath
     recOutPath:(nonnull NSString *)recOutPath nowStart:(BOOL)nowStart DEPRECATED_MSG_ATTRIBUTE("该函数1.0.1版以后不再维护, 使用openKTV:recOutPath:nowStart取代");

/**
 * @brief 打开K歌服务
 *
 * 该函数的触发会有状态回调。启动K歌服务后，会即时保存录音文件。
 *
 * @param songInfo 伴奏信息
 * @param recOutPath 录音文件保存到沙盒的路径(文件路径需要有读写权限且不存在，否则会导致录音保存失败)
 * @param nowStart 开启K歌服务后，立即开始K歌。（true:立即开始，false:手动开始）
 *
 * @warning 不再使用K歌服务后，您需要调用closeKTV用于关闭K歌服务中的资源。
 * @warning recOutPath删除时需要通过KXKTVSDKManager类的clearAudioInfoWithRecPath函数进行删除
 * @see 伴奏资料 KTVSDKSongItem
 * @see 关闭K歌服务 closeKTV
 * @see 删除录音文件 KXKTVSDKManager:clearAudioInfoWithRecPath
 */
- (void)openKTV:(nonnull KTVSDKSongItem *)songInfo recOutPath:(nonnull NSString *)recOutPath nowStart:(BOOL)nowStart;



/**
 * @brief 开始K歌
 *
 * 该函数的触发会有状态回调。
 *
 * @warning 需要在openKTV之后调用.
 * @see 开启K歌服务 openKTV:recOutPath:nowStart:
 */
- (void)startKTV;

/**
 * @brief 暂停K歌
 *
 * 该函数的触发会有状态回调。
 *
 * @warning 需要在openKTV之后调用.
 * @see 开启K歌服务 openKTV:recOutPath:nowStart:
 */
- (void)pauseKTV;

/**
 * @brief 结束K歌
 *
 * 该函数的触发会有状态回调。
 *
 * @warning 不需要使用K歌服务后，需要调用该函数用于销毁K歌服务的资源占用。
 *
 */
- (void)closeKTV;



@end

NS_ASSUME_NONNULL_END

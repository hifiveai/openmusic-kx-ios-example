//
//  KXOkEditPlayer.h
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
 * 编辑服务代理
 *
 * 回调播放状态、异常
 */
@protocol KXOkEditPlayerDelegate <NSObject>

/**
 * 服务异常
 *
 * @param sender 事件触发者
 * @param error 异常信息
 * @see errorCode定义:KTVSDKErrorCode
 * @see sender:KXOkEditPlayer
 */
- (void)recPlayer:(id)sender didError:(NSError *)error;

/**
 * 伴奏播放完，自动结束会回调此代理
 *
 * @param sender 事件触发者
 * @see sender:KXOkEditPlayer
 */
- (void)recPlayerDidPlayEnd:(id)sender;

/**
 * 播放服务状态变化
 *
 * @param sender 事件触发者
 * @param status 状态
 * @see 状态定义:KXKTVPlayStatus
 * @see sender:KXOkEditPlayer
 */
- (void)recPlayer:(id)sender didRecStatusChanged:(KXKTVPlayStatus)status;

/**
 * 演唱得分
 * 分数有变化时，会触发此回调
 *
 * @param sender 事件触发者
 * @param totalScore 总分(0-100)
 *
 * @see sender:KXOkEditPlayer
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
 * @see sender:KXOkEditPlayer
 *
 */
- (void)recPlayer:(id)sender didCallbackSingleScore:(float)singleScore;


@end



/**
 * 作品播放编辑类
 *
 * 集成作品回放时时调音编辑服务为一体，可以将编辑过的作品文件另存新作品
 *
 * @warning 使用该服务前，必须结束KXOkAudioPlayer
 * @warning 不再使用该服务后，需要调用 -closeKTV 销毁资源占用
 */
@interface KXOkEditPlayer : NSObject

/**
 * 编辑服务代理
 *
 * 建议在openKTV之前设置
 * @see 回调定义:KXOkEditPlayerDelegate
 * @see 打开编辑服务 openKTV:recPath:nowStart:
 */
@property (nonatomic,weak) id<KXOkEditPlayerDelegate> delegate;

/**
 * 伴奏音量调整，有读写权限
 *
 * 取值范围(0.0~1.0)
 */
@property (nonatomic,assign) float accompVolume;

/**
 * 人声音量调整，有读写权限
 *
 * 取值范围(0.0~1.0)
 */
@property (nonatomic,assign) float recordVolume;
/**
 * 美声范围，有读写权限
 *
 * 取值范围 (0.0~1.0)
 *
 */
@property (nonatomic,assign) float reverbValue;
/**
 * 音色效果，有读写权限
 *
 * 小于0浑厚，大于0清亮
 *
 * 取值范围(-1.0~1.0)
 *
 */
@property (nonatomic,assign) float EQValue;

/**
 * 当前播放状态
 *
 * @see 状态定义:KXKTVPlayStatus
 */
@property (nonatomic,readonly) KXKTVPlayStatus currKTVStatus;
/**
 * 播放时长，有读写权限
 *
 * 时长(单位秒)
 *
 * @warning 可以通过设置该参数跳到指定时间播放
 */
@property (nonatomic,assign) float currKTVPos;

/**
 * 播放总时长
 *
 * 时长(单位秒)
 */
@property (nonatomic,readonly) float currKTVDuration;


/**
 * @brief 构造回放编辑服务类
 *
 * 通过该构造函数初始化事件代理
 *
 * @param aDelegate 事件代理
 *
 * @see delegate定义:KXOkEditPlayerDelegate
 *
 * @return KXOkEditPlayer实例
 */
- (id)initWithDelegate:(id<KXOkEditPlayerDelegate>)aDelegate;

/**
 * 设置用于展示音准线的视图
 *
 * @param view 音准线视图窗口(调用者需要自己初始化一个View，视图大小和位置由调用者初始化，SDK会铺满在该视图上进行呈现)
 * @warning 需要在openKTV之前调用
 * @see 打开编辑服务 openKTV:recPath:nowStart:
 */
- (void)setTrackView:(nonnull UIView *)view;

/**
 * 设置用于展示歌词的视图
 *
 * @param view 歌词视图窗口(调用者需要自己初始化一个View，视图大小和位置由调用者初始化，SDK会铺满在该视图上进行呈现)
 * @warning 需要在openKTV之前调用
 * @see 打开编辑服务 openKTV:recPath:nowStart:
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
 * @see 开启K歌服务 openKTV:recPath:nowStart:
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
 * 打开播放编辑服务
 *
 * @param songId 伴奏ID
 * @param accomFilePath 伴奏文件沙盒路径
 * @param lrcFilePath 歌词文件沙盒路径(没有歌词传nil)
 * @param toneFilePath 评分档文件沙盒路径(没有评分档传nil)
 * @param recPath 录音文件路径
 * @param nowStart 开启播放编辑服务后，立即开始播放编辑。（true:立即开始，false:手动开始）
 *
 * @warning 该函数的触发会有状态回调。
 * @see 关闭编辑服务 closeKTV
 */
- (void)openKTV:(nonnull NSString *)songId accomFilePath:(nonnull NSString *)accomFilePath
  lrcFilePath:(nullable NSString *)lrcFilePath toneFilePath:(nullable NSString *)toneFilePath
  recPath:(nonnull NSString *)recPath nowStart:(BOOL)nowStart DEPRECATED_MSG_ATTRIBUTE("该函数1.0版以后不再维护, 使用openKTV:accomFilePath:kkLrcFilePath:recPath:nowStart取代");

/**
 * KKLrc模式,打开播放编辑服务
 *
 * @param songId 伴奏ID
 * @param accomFilePath 伴奏文件沙盒路径
 * @param kkLrcFilePath 歌词文件沙盒路径(没有歌词传nil)
 * @param recPath 录音文件路径
 * @param nowStart 开启播放编辑服务后，立即开始播放编辑。（true:立即开始，false:手动开始）
 *
 * @warning 该函数的触发会有状态回调。
 * @see 关闭编辑服务 closeKTV
 */
- (void)openKTV:(nonnull NSString *)songId accomFilePath:(nonnull NSString *)accomFilePath
  kkLrcFilePath:(nullable NSString *)kkLrcFilePath recPath:(nonnull NSString *)recPath
       nowStart:(BOOL)nowStart DEPRECATED_MSG_ATTRIBUTE("该函数1.0.1版以后不再维护, 使用openKTV:recPath:nowStart取代");


/**
 * 打开播放编辑服务
 *
 * @param songInfo 歌曲资料
 * @param recPath 录音文件路径
 * @param nowStart 开启播放编辑服务后，立即开始播放编辑。（true:立即开始，false:手动开始）
 *
 * @warning 该函数的触发会有状态回调。
 * @see 关闭编辑服务 closeKTV
 * @see 歌曲资料 KTVSDKSongItem
 */
- (void)openKTV:(nonnull KTVSDKSongItem *)songInfo recPath:(nonnull NSString *)recPath nowStart:(BOOL)nowStart;

/**
 * 开始播放编辑
 *
 * @warning 该函数的触发会有状态回调。
 * @warning 需要在openKTV之后调用.
 * @see 打开编辑服务 openKTV:recPath:nowStart:
 */
- (void)startKTV;

/**
 * 暂停播放编辑
 *
 * @warning 该函数的触发会有状态回调。
 * @warning 需要在openKTV之后调用。
 * @see 打开编辑服务 openKTV:recPath:nowStart:
 */
- (void)pauseKTV;

/**
 * 结束播放编辑
 * @warning 该函数的触发会有状态回调。
 * @warning 不需要使用K歌服务后，需要调用该函数用于销毁内存中的缓存。
 */
- (void)closeKTV;


/**
 * 覆盖保存
 *
 * 覆盖保存时，内部会自动 -closeKTV
 * @param progressBlock 导出进度回调 (progress:取值范围 0.0~1.0)，SDK中会自动跳转到主线程
 * @param completeBlock 导出结果回调 (success:YES-导出成功，NO-导出失败，error:导出失败的情况下会有错误提示)
 *
 * @warning 需要在openKTV之后调用，才可以导出新文件
 * @see 打开编辑服务 openKTV:recPath:nowStart:
 */
- (void)coverSaveRecProgressBlock:(nullable void(^)(float progress))progressBlock
                    completeBlock:(nullable void(^)(BOOL success,NSError  * _Nullable error))completeBlock;


/**
 * 导出新的录音文件
 *
 * 导出录音时，内部会主动 -closeKTV
 *
 * @param recPath 新录音文件保存的沙盒地址(文件路径需要有读写权限且不存在，否则会导致录音保存失败)
 * @param progressBlock 导出进度回调 (progress:取值范围 0.0~1.0)，SDK中会自动跳转到主线程
 * @param completeBlock 导出结果回调 (success:YES-导出成功，NO-导出失败，error:导出失败的情况下会有错误提示)
 *
 * @warning 需要在openKTV之后调用，才可以导出新文件
 * @see 打开编辑服务 openKTV:recPath:nowStart:
 */
- (void)exportNewRecFile:(NSString *)recPath
           progressBlock:(nullable void(^)(float progress))progressBlock
           completeBlock:(nullable void(^)(BOOL success,NSError  * _Nullable error))completeBlock;



@end

NS_ASSUME_NONNULL_END

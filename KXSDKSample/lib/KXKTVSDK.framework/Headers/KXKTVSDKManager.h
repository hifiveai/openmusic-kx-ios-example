//
//  KXKTVSDKManager.h
//  KXKTVSDK
//
//  Created by kx on 2022/3/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * K歌SDK管理类
 *
 * 注意SDK暂不支持iPv6
 *
 * 用于初始化KTV引擎服务，管理SDK状态
 */
@interface KXKTVSDKManager : NSObject

+ (KXKTVSDKManager *)getInstance;

/**
 * 检查SDK状态是否处于可用状态
 *
 * @return true:可用 false:不可用
 */
- (BOOL)isCanUseEngine;

/**
 * 设置状态为Debug模式，控制台会有log打印
 *
 * @param debug true/false
 */
- (void)setDebugMode:(BOOL)debug;

/**
 * 清除缓存
 *
 * @param aPath 录音文件路径
 *
 * @warning 当您在删除录音信息的时候减少用户手机空间时，可以调用该函数用于清理该录音的缓存信息。
 */
- (void)clearAudioInfoWithRecPath:(nonnull NSString *)aPath;


/**
 * 设置设备UDID
 *
 * 默认取用 UIDevice的identifierForVendor
 * @param UDIDString 设备唯一标识符 (用于Log统计使用)
 */
- (void)setDeviceUDID:(NSString *)UDIDString;


/**
 * 设置当前IP地址
 *
 * @param ipAddress 当前IP地址 (用于Log统计使用)
 */
- (void)setCurIPAddress:(NSString *)ipAddress;

/**
 * 初始化KTV引擎
 *
 * @param appKey 客户号
 * @param block status 0:正常 -1:授权已失效
 */
- (void)initEngine:(nonnull NSString *)appKey
             block:(void(^)(int status))block;





@end

NS_ASSUME_NONNULL_END

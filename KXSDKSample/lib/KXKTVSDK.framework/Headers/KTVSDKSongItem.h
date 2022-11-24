//
//  KTVSDKSongItem.h
//  KXKTVSDK
//
//  Created by kx on 2022/7/14.
//

#import <Foundation/Foundation.h>

/**
 * 歌曲资料
 */
@interface KTVSDKSongItem : NSObject

/**
 * 歌曲ID
 */
@property (nonatomic,copy, nonnull) NSString *songId;//歌曲ID
/**
 * 歌曲类型 0:无评分 1:单句评分 2:精确评分
 */
@property (nonatomic,assign) int songKind;//歌曲类型 0:无评分 1:单句评分 2:精确评分
/**
 * 逐行歌词本地路径
 */
@property (nonatomic,copy, nullable) NSString *dynamicLyricPath;//逐行歌词本地路径
/**
 * 静态歌词本地路径
 */
@property (nonatomic,copy, nullable) NSString *staticLyricPath;//静态歌词本地路径
/**
 * kklrc文件本地路径
 */
@property (nonatomic,copy, nullable) NSString *scorePath;//kklrc文件本地路径
/**
 * 伴奏文件本地路径
 */
@property (nonatomic,copy,nonnull) NSString *accompanyPath;//
/**
 * 导唱文件本地路径
 */
@property (nonatomic,copy,nullable) NSString *guideFilePath;


/*片段开始时间 单位秒*/
@property (nonatomic,assign) int startSec;
/*片段结束时间 单位秒*/
@property (nonatomic,assign) int endSec;

/**
 * 歌曲信息构造器
 *
 * @return KTVSDKSongItem 实例
 */
+ (KTVSDKSongItem *_Nonnull)CreateKTVSDKSongItem:(NSString * _Nonnull)songId songKind:(int)songKind
                                dynamicLyricPath:(NSString * _Nullable)dynamicLyricPath staticLyricPath:(NSString * _Nullable)staticLyricPath
                                       scorePath:(NSString * _Nullable)scorePath
                                   accompanyPath:(NSString * _Nonnull)accompanyPath guideFilePath:(NSString * _Nullable)guideFilePath;

/**
 * 歌曲信息构造器 (片段模式可用)
 *
 * @return KTVSDKSongItem 实例
 */
+ (KTVSDKSongItem *_Nonnull)CreateKTVSDKSongItem:(NSString * _Nonnull)songId songKind:(int)songKind
                                dynamicLyricPath:(NSString * _Nullable)dynamicLyricPath
                                 staticLyricPath:(NSString * _Nullable)staticLyricPath
                                       scorePath:(NSString * _Nullable)scorePath
                                   accompanyPath:(NSString * _Nonnull)accompanyPath
                                   guideFilePath:(NSString * _Nullable)guideFilePath
                                        startSec:(int)startSec endSec:(int)endSec;


@end


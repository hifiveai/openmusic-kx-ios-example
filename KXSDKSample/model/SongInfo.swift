//
//  SongInfo.swift
//  KXSDKSample
//
//  Created by 李刚 on 2022/3/21.
//

import Foundation
//歌曲信息类
class SongInfo : NSObject {
    //歌曲ID
    var songId:String = ""
    //歌曲名
    var name:String = ""
    //歌手名
    var singer:String = ""
    //导唱文件Url
    var guideUrl:String = ""
    //伴奏文件Url
    var musicUrl:String = ""
    // 动态歌词Url
    var dynamicLyricUrl:String = ""
    // 静态歌词Url
    var staticLyricUrl:String = ""
    // 评分文件Url
    var scoreUrl:String = ""
    
    //导唱文件的本地缓存路径(绝对路径)
    var guidePath:String = ""
    //伴奏文件的本地缓存路径(绝对路径)
    var musicPath:String = ""
    //歌词文件的本地缓存路径(绝对路径)
    // 动态歌词Url
    var dynamicLyricPath:String = ""
    // 静态歌词Url
    var staticLyricPath:String = ""
    // 评分文件Url
    var scorePath:String = ""
    //录音文件名(录音文件的完全路径在使用时拼接)
    var recordPath:String = ""
    //演唱最终得分
    var score:Float = 0
    //单句最低分
    var minScore:Float = 0
    //单句最高分
    var maxScore:Float = 0
    //演唱完成度(百分比，演唱完成度=演唱时长/歌曲时长*100)
    var progress:Float = 0
    //歌曲时长
    var duration:Int = 0
    //歌曲类型：2-逐字评分，1-单句评分，0-无评分(默认)
    var type = 0
    
    //歌曲文件版本
    var partDuration:Int = 0 //片段时长(秒)
    var startSec:Int = 0 //片段开始时间 (秒)
    var endSec:Int = 0 //片段结束时间 (秒)
    
    var notFoundLyric:Bool {
        get {
            return scoreUrl.isEmpty && staticLyricUrl.isEmpty && dynamicLyricUrl.isEmpty
        }
    }
    
    //根据不同的歌曲类型，确定歌曲的资源文件路径
    func initFilePath()
    {
        if self.type == 2 {
            
            //逐字评分歌曲的歌词文件、伴奏文件内置在APP中，直接从APP中获取
            //逐字评分歌曲的歌词文件路径
            self.scorePath = Utils.shared.resourcePath(String(format:"%@.lrc" , self.songId))
            //逐字评分歌曲的伴奏文件路径
            self.musicPath = Utils.shared.resourcePath(String(format:"%@.mp3" , self.songId))
            
        } else {
            
            if self.partDuration == 0 {
                //逐句评分、无评分歌曲的导唱文件、伴奏文件、歌词文件、评分文件，都从HIFIVE服务器获取
                //逐句评分/无评分歌曲的歌词缓存路径
                self.scorePath = Utils.shared.cachedFilePath(String(format:"%@_score.lrc" , self.songId))
                self.dynamicLyricPath =  Utils.shared.cachedFilePath(String(format:"%@_dynamic.lrc" , self.songId))
                self.staticLyricPath = Utils.shared.cachedFilePath(String(format:"%@_static.lrc" , self.songId))
                //逐句评分/无评分歌曲的伴奏文件路径
                self.musicPath = Utils.shared.cachedFilePath(String(format:"%@.mp3" , self.songId))
                //逐句评分/无评分歌曲的导唱文件路径
                self.guidePath = Utils.shared.cachedFilePath(String(format:"LeadSing_%@.mp3" , self.songId))
            } else {
                //逐句评分、无评分歌曲的导唱文件、伴奏文件、歌词文件、评分文件，都从HIFIVE服务器获取
                //逐句评分/无评分歌曲的歌词缓存路径
                self.scorePath = Utils.shared.cachedFilePath(String(format:"%@_%d_score.lrc" , self.songId,self.partDuration))
                self.dynamicLyricPath =  Utils.shared.cachedFilePath(String(format:"%@_%d_dynamic.lrc" , self.songId,self.partDuration))
                self.staticLyricPath = Utils.shared.cachedFilePath(String(format:"%@_%d_static.lrc" , self.songId,self.partDuration))
                //逐句评分/无评分歌曲的伴奏文件路径
                self.musicPath = Utils.shared.cachedFilePath(String(format:"%@_%d.mp3" , self.songId,self.partDuration))
                //逐句评分/无评分歌曲的导唱文件路径
                self.guidePath = Utils.shared.cachedFilePath(String(format:"LeadSing_%@_%d.mp3" , self.songId,self.partDuration))
            }
            
        }
    }
    
    
    convenience init(song:SongInfo) {
        self.init()
        
        self.songId = song.songId
        self.name = song.name
        self.singer = song.singer
        self.guideUrl = song.guideUrl
        self.musicUrl = song.musicUrl
        self.dynamicLyricUrl = song.dynamicLyricUrl
        self.staticLyricUrl = song.staticLyricUrl
        self.scoreUrl = song.scoreUrl
        
        self.guidePath = song.guidePath
        self.musicPath = song.musicPath
        self.dynamicLyricPath = song.dynamicLyricPath
        self.staticLyricUrl = song.staticLyricPath
        self.scorePath = song.scorePath
        self.recordPath = song.recordPath
        
        self.score = song.score
        self.minScore = song.minScore
        self.maxScore = song.maxScore
        self.progress = song.progress
        self.duration = song.duration
        self.type = song.type
        
        self.partDuration = song.partDuration
        self.startSec = song.startSec
        self.endSec = song.endSec
    }
}

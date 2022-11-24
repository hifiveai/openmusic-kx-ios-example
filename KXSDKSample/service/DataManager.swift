//
//  DataManager.swift
//  KXSDKSample
//
//  Created by 李刚 on 2022/4/22.
//

import UIKit
import CoreMedia
import KXKTVSDK
import HFOpenApi
//歌曲信息获取完成回调
typealias HttpCallback = ([SongInfo]?, Error?) -> Void

//数据管理类
class DataManager: NSObject, HFOpenApiErrorProtocol {

    static let shared = DataManager()
    //下载任务队列
    private var taskDic = [String:DownloadTask]()
    //当前的下载任务
    private var currTask: DownloadTask?
    //内置的歌曲列表名
    private let songList = "song_list.json"
    //作品列表
    var myWorks = [SongInfo]()
    
    private override init() {
        super.init()
        DispatchQueue.global().async {
            if let arr = self.loadWorks() {
                self.myWorks = arr
            }
        }
    }
    
    
    //HFOpenApiErrorProtocol
    func onSendRequestErrorCode(_ errorCode: HFAPISDK_CODE, info: [AnyHashable : Any]!) {
        print("HFOpenApiManager onSendRequestErrorCode code:\(errorCode), info:\(String(describing: info))")
    }
    
    func onServerErrorCode(_ errorCode: Int32, info: [AnyHashable : Any]!) {
        print("HFOpenApiManager onServerErrorCode code:\(errorCode), info:\(String(describing: info))")
    }
    
    func convert2KTVSDKItem(_ song:SongInfo) -> KTVSDKSongItem
    {
        return KTVSDKSongItem.createKTVSDKSongItem(song.songId, songKind: Int32(song.type), dynamicLyricPath: song.dynamicLyricPath, staticLyricPath: song.staticLyricPath, scorePath: song.scorePath, accompanyPath: song.musicPath, guideFilePath: song.guidePath,startSec: Int32(song.startSec),endSec: Int32(song.endSec))
    }

    
    //歌曲类型描述
    func songTypeString(_ type:Int) -> String {
        switch type {
        case 2:
            return "(逐字评分)"
        case 1:
            return "(单句评分)"
        default:
            return "(无评分)"
        }
    }
    
    //第一次启动后使用，避免出现APP无法访问网络的情况
    func checkNetwork() {
        let key = UserDefaults.standard.string(forKey: "KXSDKSample")
        if key == nil{
            self.httpGet("http://www.baidu.com") { _, err in
                if err == nil {
                    UserDefaults.standard.set("KXSDKSample", forKey: "KXSDKSample")
                }
            }
        }
    }
    
    //检查文件是否已缓存到手机设备
    func fileCached(_ path:String) -> Bool {
        if path.isEmpty {
            return false
        }
        if FileManager.default.fileExists(atPath: path) {
            return true
        }
        return false
    }
    
    func songCached(_ song:SongInfo) -> Bool {
        return fileCached(song.staticLyricPath) || fileCached(song.dynamicLyricPath) || fileCached(song.scorePath)
    }
    
    //作品是否已存在
    func hasWork(_ songId:String, recordPath:String) -> Bool {
        if self.myWorks.count > 0 {
            for work in myWorks {
                if work.songId == songId && work.recordPath == recordPath {
                    return true
                }
            }
        }
        return false
    }
    
    //加载伴奏列表
    func loadSongList(block:@escaping HttpCallback) {
        DispatchQueue.global().async {
            let listPath:String = Bundle.main.path(forResource: self.songList, ofType: "") ?? ""
            if(FileManager.default.fileExists(atPath: listPath)){
                let data = Data(path: listPath)
                self.parseData(data: data, err: nil, block: block)
            }else{
                block(nil, NSError(domain: "HTTP data error", code: 601, userInfo: [NSLocalizedDescriptionKey:"HTTP data error!"]))
            }
        }
    }
    //解析伴奏列表数据
    private func parseData(data:Data?, err:Error?, block:@escaping HttpCallback){
        if err != nil {
            DispatchQueue.main.async {
                block(nil, err)
            }
        }else {
            if data != nil {
                if let songList = self.parseSongList(data!) {
                    block(songList, nil)
                }else{
                    block(nil, NSError(domain: "HTTP parse error", code: 600, userInfo: [NSLocalizedDescriptionKey:"Parse HTML Error!"]))
                }
            }else{
                block(nil, NSError(domain: "HTTP data error", code: 601, userInfo: [NSLocalizedDescriptionKey:"HTTP data error!"]))
            }
        }
    }
    //简单的Http请求
    private func httpGet(_ url:String, block:@escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: url) else {
            return block(nil, NSError(domain: "URL error", code: 600, userInfo: [NSLocalizedDescriptionKey:"Url is nil!"]))
        }
        let urlRequest = URLRequest(url: url)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.requestCachePolicy = .reloadIgnoringLocalCacheData

        let session = URLSession(configuration: config)
        
        
        session.dataTask(with: urlRequest){
            (data, _, error) in
            if error != nil {
                block(nil, error)
            }else{
                block(data, nil)
            }
        }.resume()
    }
    
    //解析伴奏列表
    private func parseSongList(_ aData:Data?) -> [SongInfo]? {
        guard let data = aData else { return nil }
        var songList = [SongInfo]()
        do {
            let json = try JSONSerialization.jsonObject(with: data, options:[.mutableContainers,.mutableLeaves])
            if let jsArray = json as? [Any] {
                for item in jsArray {
                    if let json = item as? [String:Any] {
                        let song = SongInfo()
                        song.songId = json["song_id"] as! String
                        song.name = json["song_name"] as! String
                        song.singer = json["singer"] as! String
                        song.type = json["type"] as! Int
                        
                        song.initFilePath()
                        
                        songList.append(song)
                    }
                }
            }
        } catch {
            return nil
        }
        return songList
    }
    
    
    //加载作品列表
    private func loadWorks() -> [SongInfo]? {
        let worksPath = Utils.shared.worksFilePath
        if FileManager.default.fileExists(atPath: worksPath) {
            let data = Data(path: worksPath)
            do {
                let obj = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                print(obj)
                if let arr = obj as? [[String:AnyObject]] {
                    var songArray = [SongInfo]()
                    for item in arr {
                        let song = SongInfo()
                        song.songId = item["songId"] as! String
                        song.name = item["name"] as! String
                        song.recordPath = item["recordPath"] as! String
                        
                        if let singerName = item["singer"] as? String {
                            song.singer = singerName
                        }
                        if let score = item["score"] as? Float {
                            song.score = score
                        }
                        if let score = item["minScore"] as? Float {
                            song.minScore = score
                        }
                        if let score = item["maxScore"] as? Float {
                            song.maxScore = score
                        }
                        if let score = item["progress"] as? Float {
                            song.progress = score
                        }
                        if let dur = item["duration"] as? Int {
                            song.duration = dur
                        }
                        if let type = item["type"] as? Int {
                            song.type = type
                        }else{
                            song.type = 0
                        }
                        
                        //歌曲文件版本
                        if let partDuraton = item["partDuraton"] as? Int {
                            song.partDuration = partDuraton
                        } else {
                            song.partDuration = 0
                        }
                        if let startSec = item["startSec"] as? Int {
                            song.startSec = startSec
                        } else {
                            song.startSec = 0
                        }
                        if let endSec = item["endSec"] as? Int {
                            song.endSec = endSec
                        } else {
                            song.endSec = 0
                        }
                        
                        song.initFilePath()
                        
                        songArray.append(song)
                    }
                    return songArray
                }
            } catch {
            }
        }
        return nil
    }
    //增加作品
    func addWork(_ song:SongInfo) {
        if self.myWorks.count > 0 {
            self.myWorks.insert(song, at: 0)
        }else{
            self.myWorks.append(song)
        }
        self.saveWorks()
    }
    //删除作品
    func delWork(_ song:SongInfo, block:@escaping (() -> ())){
        if self.myWorks.count > 0 {
            DispatchQueue.global().async {
                for index in self.myWorks.indices {
                    let work = self.myWorks[index]
                    if work.songId == song.songId && work.recordPath == song.recordPath {
                        let path = Utils.shared.cachedFilePath(song.recordPath)
                        //删除作品文件
                        KXKTVSDKManager.getInstance().clearAudioInfo(withRecPath: path)
                        //从作品列表中删除
                        self.myWorks.remove(at: index)
                        break
                    }
                }
                self.saveWorks()
                DispatchQueue.main.async {
                    block()
                }
            }
        }else{
            block()
        }
    }
    
    //保存作品列表
    private func saveWorks(){
        let works = self.myWorks
        var arr = [[String:Any]]()
        for song in works {
            var dic = [String:Any]()
            dic["songId"] = song.songId
            dic["name"] = song.name
            if song.singer.count > 0 {
                dic["singer"] = song.singer
            }
            dic["name"] = song.name
            dic["type"] = NSNumber(value: song.type)
            dic["recordPath"] = song.recordPath
            dic["score"] = NSNumber(value: song.score)
            dic["minScore"] = NSNumber(value: song.minScore)
            dic["maxScore"] = NSNumber(value: song.maxScore)
            dic["progress"] = NSNumber(value: song.progress)
            dic["duration"] = NSNumber(value: song.duration)
            dic["partDuration"] = NSNumber(value: song.partDuration)
            dic["startSec"] = NSNumber(value: song.startSec)
            dic["endSec"] = NSNumber(value: song.endSec)
            arr.append(dic)
        }
        let worksPath = Utils.shared.worksFilePath
        do {
            
            let data = try JSONSerialization.data(withJSONObject: arr, options: .prettyPrinted)
            if FileManager.default.fileExists(atPath: worksPath) {
                try FileManager.default.removeItem(atPath: worksPath)
            }
            try data.write(to: URL(fileURLWithPath: worksPath))
            
        } catch {
            print("saveWorks error!")
        }
    }
    
    private func parseSongInfo(_ dataDic:[String:Any] , singType:Int, block:@escaping (Int, String?, String?,String?,String?,String?,Int,Int,Int, Error?) -> ()) {
        //静态歌词Url
        var _staticLyricUrl:String? = nil
        //动态歌词Url
        var _dynamicLyricUrl:String? = nil
        //评分歌词Url
        var _scoreLyricUrl:String? = nil
        //伴奏文件Url
        var _musicUrl:String? = nil
        //导唱文件Url
        var _guideUrl:String? = nil
        
        //片段时间
        var _partDuration:Int = 0
        var _startSec:Int = 0
        var _endSec:Int = 0

        //songKind=0 无评分
        var songKind = 0
        if let kind = dataDic["songKind"] as? Int {
            songKind = kind
        }
    
        if let _url = dataDic["scoreUrl"] as? String {
            _scoreLyricUrl = _url
        }
        if let _url = dataDic["dynamicLyricUrl"] as? String {
            _dynamicLyricUrl = _url
        }
        if let _url = dataDic["staticLyricUrl"] as? String {
            _staticLyricUrl = _url
        }

        if let subArr = dataDic["subVersions"] as? [[String:Any]] {
            for itemDic in subArr {
                let name = itemDic["versionName"] as? String
                
                if singType == 0 {
                    //伴奏url
                    if name != nil && name!.hasPrefix("伴奏_") {
                        if let path = itemDic["path"] as? String {
                            _musicUrl = path
                        }
                    }
                    //导唱url
                    if name != nil && name!.hasPrefix("左右声道_"){
                        if let path = itemDic["path"] as? String {
                            _guideUrl = path
                        }
                    }
                } else if singType == 1 {
                    //伴奏url
                    if name != nil && name!.hasPrefix("30s伴奏_") {
                        if let path = itemDic["path"] as? String {
                            _musicUrl = path
                        }
                        _partDuration = 30
                        _startSec = itemDic["startTime"] as! Int
                        _endSec = itemDic["endTime"] as! Int
                    }
                    //导唱url
                    if name != nil && name!.hasPrefix("30s左右声道_"){
                        if let path = itemDic["path"] as? String {
                            _guideUrl = path
                        }
                    }
                } else if singType == 2 {
                    //伴奏url
                    if name != nil && name!.hasPrefix("60s伴奏_") {
                        if let path = itemDic["path"] as? String {
                            _musicUrl = path
                        }
                        _partDuration = 60
                        _startSec = itemDic["startTime"] as! Int
                        _endSec = itemDic["endTime"] as! Int
                    }
                    //导唱url
                    if name != nil && name!.hasPrefix("60s左右声道_"){
                        if let path = itemDic["path"] as? String {
                            _guideUrl = path
                        }
                    }
                }
            }
        }
        block(songKind, _staticLyricUrl, _dynamicLyricUrl, _scoreLyricUrl, _musicUrl, _guideUrl, _partDuration,_startSec,_endSec, nil)
    }
    
    /*
     加载伴奏信息
     songInfo 歌曲信息
     singType 0:唱整首 1:唱30s 2:唱60s
    */
    func loadSongInfo(_ songInfo:SongInfo, singType:Int, block:@escaping (Int, String?,String?,String?, String?,String?,Int,Int,Int, Error?) -> ()) {
        HFOpenApiManager.shared().delegate = self
        HFOpenApiManager.shared().kHQListen(withMusicId: songInfo.songId, audioFormat: "mp3", audioRate: "320", success: ({ res in
                print("kHQListen success:\(res ?? "")")
                if let dataDic = res as? [String:Any] {
                    self.parseSongInfo(dataDic , singType:singType, block: block)
                    return
                }
                block(0, nil,nil,nil,nil,nil,0,0,0, NSError(domain: "HTTP data error", code: 601, userInfo: [NSLocalizedDescriptionKey:"HTTP data error!"]))
            }), fail: ({ err in
                print("kHQListen fail:\(err?.localizedDescription ?? "")")
                block(0, nil,nil,nil,nil,nil,0,0,0, err)
            })
        )
    }
    //移除下载任务
    func removeDownloadTask(_ songId:String) {
        self.taskDic.removeValue(forKey: songId)
    }
    //下载歌曲
    func downloadSong(_ song:SongInfo, block:@escaping ((Float, DownloadStatus, Error?) -> ())) {
        DispatchQueue.global().async {
            if let task = self.taskDic[song.songId]{
                //如果歌曲已经添加到下载队列中
                if let tempTask = self.currTask {
                    //如果当前任务不为空
                    if song.songId == tempTask.song.songId {
                        //如果歌曲为当前任务歌曲
                        if tempTask.status != DownloadStatus.paused {
                            //如果当前任务正在下载，则暂停下载
                            tempTask.cancel()
                        }else{
                            //如果当前任务未下载，则开始下载
                            tempTask.start()
                        }
                    }else{
                        //如果歌曲不是当前任务歌曲
                        //暂停当前任务
                        tempTask.cancel()
                        //下载歌曲
                        task.start()
                        self.currTask = task
                    }
                        
                }else{
                    //如果当前任务为空
                    //下载歌曲
                    task.start()
                    self.currTask = task
                }
            }else{
                //下载歌曲
                self.downloadNewSong(song, block: block)
            }
        }
    }
    //下载歌曲
    private func downloadNewSong(_ song:SongInfo, block:@escaping ((Float, DownloadStatus, Error?) -> ())) {
        let task = DownloadTask(song: song, block: block)
        task.block = block
        self.taskDic[song.songId] = task
        self.currTask = task
        task.start()
    }
    
    
}


//下载状态：0--none,1--下载中，2--下载暂停，3--下载完成
enum DownloadStatus {
    //下载状态：none,下载中，下载暂停，下载完成
    case none, downloading, paused, completed
}

enum DownloadOrder: Int {
    case none, guide, accomp, staticLrc, dynamicLrc, scoreLrc, completed
}

//下载任务类
class DownloadTask:NSObject {
    var song:SongInfo!
    //下载状态：0--none,1--下载中，2--下载暂停，3--下载完成
    var status = DownloadStatus.none
    var block:((Float, DownloadStatus, Error?) -> ())
    private var task:DownloadTool?
    
    private var order:DownloadOrder = .guide
    private var progressOffset:Float = 0.0
    
    init(song:SongInfo, block:@escaping ((Float, DownloadStatus, Error?) -> ())) {
        self.song = song
        self.block = block
        self.order = .none
        super.init()
    }
    //暂停下载
    func cancel(){
        self.status = .paused
        self.task?.cancel()
        self.block(0.0, self.status, nil)
    }
    
    func start() {
        if self.order == .none {
            self.order = .guide
        }
        self.status = .downloading
        if let task = self.task {
            task.start()
        }else{
            self.downloadSong()
        }
    }
    
    
    //下载歌曲资源文件
    private func downloadSong() {
        
        switch self.order {
        case .guide:
            if !self.song.guideUrl.isEmpty {
                self.downloadFile( self.song.guideUrl, path:  self.song.guidePath) { (progress, err) in
                    if(progress >= 1.0){
                        Utils.shared.log("\(self.song.name)(类型:\(self.song.type) 导唱下载完成！")
                        self.downloadAccomp()
                    }else{
                        self.block(progress * 0.49, self.status, err)
                    }
                }
            }else{
                self.downloadAccomp()
            }
            break
        case .accomp:
            self.downloadFile( self.song.musicUrl, path:  self.song.musicPath) { (progress, err) in
                if(progress >= 1.0){
                    Utils.shared.log("\(self.song.name)(类型:\(self.song.type) 伴奏下载完成！")
                    self.downloadStaticLrc()
                }else{
                    self.block(progress * 0.49 + self.progressOffset, self.status, err)
                }
            }
            break
        case .staticLrc:
            self.downloadFile( self.song.staticLyricUrl, path:  self.song.staticLyricPath) { (progress, err) in
                if(progress >= 1.0){
                    Utils.shared.log("\(self.song.name)(类型:\(self.song.type) 静态歌词下载完成！")
                    self.downloadDynamicLrc()
                }else{
                    self.block(0.98, self.status, err)
                }
            }
            break
        case .dynamicLrc:
            self.downloadFile( self.song.dynamicLyricUrl, path:  self.song.dynamicLyricPath) { (progress, err) in
                if(progress >= 1.0){
                    Utils.shared.log("\(self.song.name)(类型:\(self.song.type) 动态歌词下载完成！")
                    self.downloadScoreLrc()
                }else{
                    self.block(0.98, self.status, err)
                }
            }
            break
        case .scoreLrc:
            self.downloadFile( self.song.scoreUrl, path:  self.song.scorePath) { (progress, err) in
                if(progress >= 1.0){
                    Utils.shared.log("\(self.song.name)(类型:\(self.song.type) 评分歌词下载完成！")
                    self.block(1.0, self.status, nil)
                    self.order = .completed
                }else{
                    self.block(0.99, self.status, err)
                }
            }
            break
        case .completed:
            self.block(1.0, self.status, nil)
            break
        default:
            break
        }
    }
    
    private func downloadAccomp(){
        self.progressOffset = 0.49
        self.order = .accomp
        self.downloadSong()
    }
    
    private func downloadStaticLrc(){
        self.progressOffset = 0.98
        if self.song.staticLyricUrl.isEmpty {
            self.order = .dynamicLrc
        }else{
            self.order = .staticLrc
        }
        self.downloadSong()
    }
    
    private func downloadDynamicLrc(){
        self.progressOffset = 0.98
        if self.song.dynamicLyricUrl.isEmpty {
            self.order = .scoreLrc
        }else{
            self.order = .dynamicLrc
        }
        self.downloadSong()
    }
    
    private func downloadScoreLrc(){
        self.progressOffset = 0.99
        if self.song.scoreUrl.isEmpty {
            self.order = .completed
        }else{
            self.order = .scoreLrc
        }
        self.downloadSong()
    }
    
    
    
    //下载文件
    private func downloadFile(_ url:String, path:String, block:@escaping ((Float, Error?) -> ())) {
        let newTask = DownloadTool()
        newTask.downUrl = url
        newTask.savePath = path
        Utils.shared.log("url:\(url), path:\(path)")
        
        newTask.progressBlock = { (progress, err) in
            block(progress, err)
        }
        newTask.start()
        if self.status == .paused {
            newTask.cancel()
            self.block(0.0, self.status, nil)
        }
        self.task = newTask
    }
    
}


class DownloadTool: NSObject, URLSessionDownloadDelegate {
    //文件资源地址
    var downUrl:String = ""
    //保存路径
    var savePath:String = ""
    
    //下载进度回调
    var progressBlock: ((Float, Error?) -> ())?
    
    var currentSession:URLSession?
    var downloadTask:URLSessionDownloadTask?
    
    var downloadData:Data = Data()//下载的数据
    
    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        currentSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    //MARK:启动断点续传下载请求
    func start() {
        if downloadData.count > 0 {
            self.downloadTask = currentSession?.downloadTask(withResumeData: downloadData)
            self.downloadTask?.resume()
        } else {
            if let Url = URL(string: self.downUrl) {
                let request = URLRequest(url: Url)
                self.downloadTask = currentSession?.downloadTask(with: request)
                self.downloadTask?.resume()
            }
        }
    }
    
    //MARK:取消断点续传下载请求
    func cancel() {
        self.downloadTask?.cancel(byProducingResumeData: { resumeData in
            if resumeData != nil {
                self.downloadData = resumeData!
            }
        })
    }
    
    
    
         
    //下载代理方法，下载结束
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //保存文件
        if !savePath.isEmpty {
            //location位置转换
            let locationPath = location.path
            //移除旧文件
            if FileManager.default.fileExists(atPath: savePath) {
                do {
                    try FileManager.default.removeItem(atPath: savePath)
                } catch {
                    print(error)
                }
            }
            //生成新文件
            do {
                try FileManager.default.moveItem(atPath: locationPath, toPath: savePath)
                if let onProgress = self.progressBlock {
                    onProgress(1.0, nil)
                }
            } catch {
                print(error)
                if let onProgress = self.progressBlock {
                    onProgress(0.0, error)
                }
            }
        }
    }

    //下载代理方法，监听下载进度
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        //获取进度
        let written = (Float)(totalBytesWritten)
        let total = (Float)(totalBytesExpectedToWrite)
        let pro = written/total
        if let onProgress = self.progressBlock {
            if pro >= 0.99 {
                onProgress(0.99, nil)
            }else{
                onProgress(pro, nil)
            }
        }
    }

    //下载代理方法，下载偏移
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
    }
}

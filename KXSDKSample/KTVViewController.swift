//
//  KTVViewController.swift
//  KXSDKSample
//  演唱页
//  Created by 李刚 on 2022/3/23.
//

import UIKit
import KXKTVSDK
import AVFoundation

class KTVViewController: UIViewController , KXOkAudioPlayerDelegate, RecordEditViewControllerDelegate, KTVBottomViewDelegate, TuningSettingsViewDelegate{
    
    //是否正在演唱
    private var isPlaying = false
    //歌曲是否演唱完成
    private var isDone = false
    //是否插入耳机
    private var isHeadsetPluggedIn = false
    //刷新演唱时间Timer
    private var timer:Timer?
    //KXSDK 录歌工具
    private var kxPlayer:KXOkAudioPlayer?
    //顶部信息View
    private var titleView:KTVTitleView?
    
    private var guideVolumeBgView:UIView?
    
    private var guideVolumeSlider:UISlider?
    
    //单句评分
    private var singleScoreLabel:UILabel?
    //总评分
    private var totalScoreLabel:UILabel?
    //底部按钮操作区View
    private var bottomView:KTVBottomView?
    //逐字评分的音轨区View
    private var trackView:UIImageView?
    //歌词区View
    private var lyricView:UIView?
    //单句评分区得分柱View
    private var singleScoreView:UIScrollView?
    //调音板View
    private var settingsView:TuningSettingsView?
    //演唱结果View
    private var resultView:RecordResultView?
    //等待加载数据消息框
    private var waittingView:WaittingView?
    //当前演唱的歌曲
    private var songInfo:SongInfo
    private var delegate:RecordEditViewControllerDelegate
    //单句评分行标记
    private var lrcLineIndex = 0
    //单句评分区得分柱数组
    private var scoreViewArray:[ScoreBarView] = [ScoreBarView]()
    //单句最低评分
    private var minScore:Float = 200
    //单句最高评分
    private var maxScore:Float = 0
    //总评分
    private var totalScore:Float = 0
    
    //是否有导唱
    private var hasGuide = false
    
    private var guideVolume:Float = 0
    
    
    //保存实时数据
    private var recWavFile:WavWriter? = nil
    private var mixRecWavFile:WavWriter? = nil
    
    
    init(songInfo:SongInfo, delegate:RecordEditViewControllerDelegate){
        self.songInfo = songInfo
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isHeadsetPluggedIn = Utils.shared.headsetIsPluggedIn()
        //监听耳机插/拨出事件
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChangeListenerCallback(notification:)), name: AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance())
        self.view.backgroundColor = UIColor.black
        let bgImg = UIImageView(frame: self.view.bounds)
        bgImg.contentMode = .scaleAspectFill
        bgImg.image = UIImage(named: "ktv_bg")
        self.view.addSubview(bgImg)
        
        hasGuide = DataManager.shared.fileCached(songInfo.guidePath)
        
        //Title
        self.titleView = KTVTitleView(ktvTitle: self.songInfo.name, playback: false, backBlock: {
            self.kxPlayer?.closeKTV()
            self.dismiss(animated: true, completion: nil)
        })
        self.view.addSubview(self.titleView!)
        
        
        var h = self.titleView!.frame.maxY + 32
        var lyric_y = h
        //音轨View
        if songInfo.type == 2  {
            trackView = UIImageView(frame: CGRect(x: 0, y: h, width: self.view.bounds.width, height: 112))
            trackView!.backgroundColor = UIColor.rgba(r: 0, g: 0, b: 0, a: 0.2)
            self.view.addSubview(trackView!)
            h += trackView!.bounds.height + 10
            
            let trackBgImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 114, height: trackView!.bounds.height))
            trackBgImg.image = UIImage(named: "track_bg")
            trackBgImg.contentMode = .scaleAspectFill
            trackView!.addSubview(trackBgImg)
            lyric_y = trackView!.frame.maxY + 10
        }
        
        //底部操作按钮
        self.bottomView = KTVBottomView(false, delegate: self)
        var bFrame = self.bottomView!.frame
        bFrame.origin.y = self.view.bounds.height - bFrame.height - 20 - kSafeAreaBottomH
        self.bottomView!.frame = bFrame
        self.view.addSubview(self.bottomView!)
        h += bFrame.height
        
        
        //检查是否需要开启导唱功能
        if !hasGuide {
            self.bottomView!.disableGuide()
        }
        self.guideVolumeBgView = UIView(frame: CGRect(x: 20, y: bFrame.minY - 62, width:self.view.bounds.width - 40, height: 62))
        self.view.addSubview(self.guideVolumeBgView!)
        
        h += self.guideVolumeBgView!.frame.height
        
        if hasGuide {
            //单句得分Label
            let guideVolumeLbl = UILabel(frame: CGRect(x: 0, y: 20, width:60, height: 22))
            guideVolumeLbl.textColor = UIColor.white
            guideVolumeLbl.font = UIFont.systemFont(ofSize: 13)
            guideVolumeLbl.text = "导唱音量"
            guideVolumeLbl.textAlignment = .center
            self.guideVolumeBgView?.addSubview(guideVolumeLbl)
            
            self.guideVolumeSlider = UISlider(frame: CGRect(x: guideVolumeLbl.frame.maxX + 20, y: 20, width:self.guideVolumeBgView!.bounds.width - guideVolumeLbl.frame.maxX - 40, height: 22))
            self.guideVolumeSlider!.minimumValue = 0
            self.guideVolumeSlider!.maximumValue = 1.0
            self.guideVolumeSlider!.value = 0
            self.guideVolumeSlider!.isContinuous = false
            self.guideVolumeSlider!.setThumbImage(UIImage(named: "slider_track"), for: .normal)
            self.guideVolumeSlider!.contentMode = .scaleAspectFit
            self.guideVolumeSlider!.minimumTrackTintColor = UIColor.rgb(r: 242, g: 50, b: 81)
            self.guideVolumeSlider!.maximumTrackTintColor = UIColor.rgb(r: 165, g: 165, b: 165)
            self.guideVolumeSlider!.addTarget(self, action: #selector(sliderValueChanged(_:_:)), for: .valueChanged)
            self.guideVolumeBgView?.addSubview(self.guideVolumeSlider!)
        }
        
        self.guideVolumeBgView!.isHidden = true
    
        if songInfo.type > 0 {
            //单句得分图形
            self.singleScoreView = UIScrollView(frame: CGRect(x: 20, y: self.guideVolumeBgView!.frame.maxY - 140, width: self.view.bounds.width - 40, height: 68))
            self.singleScoreView!.contentSize = CGSize(width: 1200, height: 68)
            self.singleScoreView!.showsVerticalScrollIndicator = false
            self.singleScoreView!.showsHorizontalScrollIndicator = false
            self.singleScoreView!.isScrollEnabled = false
            for i in 0...100 {
                let cellView = ScoreBarView(posX: CGFloat(i * 12))
                self.scoreViewArray.append(cellView)
                self.singleScoreView!.addSubview(cellView)
            }
            bFrame = self.singleScoreView!.frame
//            bFrame.origin.y = self.bottomView!.frame.minY - bFrame.height - 32
            self.view.addSubview(self.singleScoreView!)
            self.singleScoreView!.frame = bFrame
            h += (bFrame.height + 32)
            
            //单句得分/总分Label
            let scoreView = UIView(frame: CGRect(x: 20, y: bFrame.minY - 42, width: self.view.bounds.width - 40, height: 22))
            self.view.addSubview(scoreView)
            h += 42
            
            //单句得分Label
            self.singleScoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 22))
            self.singleScoreLabel!.textColor = UIColor.white
            self.singleScoreLabel!.font = UIFont.systemFont(ofSize: 13)
            self.singleScoreLabel!.textAlignment = .left
            updateSingleScore(-1)
            scoreView.addSubview(self.singleScoreLabel!)
            //总分Label
            self.totalScoreLabel = UILabel(frame: CGRect(x: scoreView.bounds.width - 120, y: 0, width: 120, height: 22))
            self.totalScoreLabel!.textColor = UIColor.white
            self.totalScoreLabel!.font = UIFont.systemFont(ofSize: 13)
            self.totalScoreLabel!.textAlignment = .right
            updateTotalScore(-1)
            scoreView.addSubview(self.totalScoreLabel!)
        }
        
        
        //歌词View
        h = self.view.bounds.height - h - kSafeAreaBottomH - 20
        lyricView = UIView(frame: CGRect(x: 0, y: lyric_y, width: self.view.bounds.width, height: h))
        self.view.addSubview(lyricView!)
        
        
        //等待加载数据消息框
        self.waittingView = WaittingView()
        self.view.addSubview(self.waittingView!)
        self.waittingView!.start(text: "数据加载中...")
        self.initPlayer()
    }
    
    //初始化录歌工具
    private func initPlayer(){
        
        songInfo.recordPath = Utils.shared.recordFileName(songInfo.songId)
        self.kxPlayer = KXOkAudioPlayer(sampleRate: .SampleRateAuto, channel: .ChannelStereo, delegate: self)
        if songInfo.type == 2 { //逐字歌词以双行效果展示
            self.kxPlayer?.setLrcView(lyricView!, mode: .ktvMode)
        } else {
            self.kxPlayer?.setLrcView(lyricView!)
        }
        if let view = self.trackView {
            self.kxPlayer?.setTrackView(view)
        }
        self.isPlaying = true
        self.bottomView!.setIsPlaying(self.isPlaying)
        self.startTimer()
        DispatchQueue.global().async {
            let recordPath = Utils.shared.cachedFilePath(self.songInfo.recordPath)
            let item = DataManager.shared.convert2KTVSDKItem(self.songInfo)
            self.kxPlayer?.openKTV(item, recOutPath: recordPath, nowStart: true)
            
            //记录实时录音数据，保存临时文件
            let tmpFilePath = Utils.shared.cachedFilePath("pcmData.wav")
            let tmpMixFilePath = Utils.shared.cachedFilePath("mixPCMData.wav")
            do {
                try FileManager.default.removeItem(atPath: tmpFilePath)
                try FileManager.default.removeItem(atPath: tmpMixFilePath)
            } catch {
                
            }
            self.recWavFile = WavWriter()
            self.recWavFile?.open(tmpFilePath, samprate: self.kxPlayer!.sampleRate.rawValue, channels: self.kxPlayer!.channel.rawValue)
            
            self.mixRecWavFile = WavWriter()
            self.mixRecWavFile?.open(tmpMixFilePath, samprate: self.kxPlayer!.sampleRate.rawValue, channels: self.kxPlayer!.channel.rawValue)
        }
    }
    
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.cancelTimer()
        self.kxPlayer?.closeKTV()
    }
    
    //启动【刷新演唱时间】定时器
    private func startTimer() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updatePlayerTime), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.common)
        }
    }
    //停止【刷新演唱时间】定时器
    private func cancelTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    //刷新演唱时间
    @objc func updatePlayerTime() {
        if let player = self.kxPlayer  {
            self.titleView?.updateTime(player.currKTVPos, duration: player.currKTVDuration)
        }else{
            self.titleView?.updateTime(0, duration: 0)
        }
    }
    //更新最新的单句得分
    private func updateSingleScore(_ score:Int32){
        if score >= 0 {
            self.singleScoreLabel?.text = "单句得分：\(score)"
        }else{
            self.singleScoreLabel?.text = "单句得分：--"
        }
    }
    //更新总分
    private func updateTotalScore(_ score:Int32){
        if score >= 0 {
            self.totalScoreLabel?.text = "总分：\(score)"
        }else{
            self.totalScoreLabel?.text = "总分：--"
        }
    }
    //增加新的单句得分柱View
    private func addNewSingleScore(_ score:Float) {
        if let view = self.singleScoreView {
            let currIndex = lrcLineIndex
            if currIndex >= scoreViewArray.count {
                let cellView = ScoreBarView(posX: CGFloat(currIndex * 12))
                self.scoreViewArray.append(cellView)
                self.singleScoreView!.addSubview(cellView)
                if(self.singleScoreView!.contentSize.width <= cellView.frame.maxX ){
                    self.singleScoreView!.contentSize = CGSize(width: cellView.frame.maxX + 24.0, height: self.singleScoreView!.contentSize.height)
                }
            }
            scoreViewArray[currIndex].setScore(score)
            let vWidth = CGFloat(currIndex + 1) * 12.0
            if(vWidth > view.bounds.width) {
                view.setContentOffset(CGPoint(x: vWidth - view.bounds.width + 12.0, y: 0), animated: true)
            }
            lrcLineIndex = currIndex + 1
        }
        
    }
    
    //KXOkAudioPlayerDelegate 录音工具回调
    //录音工具回调--错误
    func recPlayer(_ sender: Any, didError error: Error) {
        self.waittingView?.stop()
        Utils.alert(error.localizedDescription, vc: self)
    }
    //录音工具回调--歌曲演唱结束
    func recPlayerDidPlayEnd(_ sender: Any) {
        self.isDone = true
        self.isPlaying = false
        self.bottomView!.setIsPlaying(false)
        self.doFinished()
    }
    //录音工具回调--状态改变
    func recPlayer(_ sender: Any, didRecStatusChanged status: KXKTVPlayStatus) {
        if status.rawValue >= 2 && !self.waittingView!.isHidden {
            self.waittingView?.stop()
        }
    }
    //录音工具回调--单句评分
    func recPlayer(_ sender: Any, didCallbackSingleScore singleScore: Float) {
        Utils.shared.log("didCallbackSingleScore:\(singleScore)")
        if self.minScore > singleScore {
            self.minScore = singleScore
        }
        if self.maxScore < singleScore {
            self.maxScore = singleScore
        }
        self.updateSingleScore(Int32(singleScore))
        self.addNewSingleScore(singleScore)
    }
    //录音工具回调--总分
    func recPlayer(_ sender: Any, didCallbackTotalScore totalScore: Float) {
        Utils.shared.log("didCallbackTotalScore:\(totalScore)")
        self.totalScore = totalScore
        self.updateTotalScore(Int32(totalScore))
    }
    
    func recPlayer(_ sender: Any, didCallbackPCM pcmData: Data) {
        //记录实时录音数据，保存临时文件
        self.recWavFile?.write(pcmData)
    }
    
    func recPlayer(_ sender: Any, didCallbackMixPCM pcmData: Data) {
        //记录实时的伴奏+人声数据，保存临时文件
        self.mixRecWavFile?.write(pcmData)
    }
    
    //监听耳机插/拨出事件
    @objc func audioRouteChangeListenerCallback(notification:NSNotification) {
            guard let userInfo = notification.userInfo,
                let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                    return
            }
            switch reason {
            case .newDeviceAvailable:
                //插入耳机
                self.isHeadsetPluggedIn = true
                break
            case .oldDeviceUnavailable:
                //拔出耳机
                self.isHeadsetPluggedIn = false
                break
            default: ()
            }
            //调音板更新
            DispatchQueue.main.async {
                self.settingsView?.audioRouteChanged(plugIn: self.isHeadsetPluggedIn)
            }
        }
    
    //RecordEditViewControllerDelegate
    func onRecordEditCompleted(_ vc: UIViewController, againSong: SongInfo?) {
        vc.dismiss(animated: false, completion: nil)
        if againSong != nil {
            self.onAgain()
        }else{
            self.delegate.onRecordEditCompleted(self, againSong: nil)
        }
    }
    
    //KTVBottomViewDelegate
    // 显示调音板
    func onSetting() {
        print("KTVViewController onSetting()")
        guard let player = self.kxPlayer else {
            return
        }
        self.settingsView = TuningSettingsView(playback: false, delegate: self)
        self.settingsView!.setValue(player.accompVolume, for: .accompVolume)
        self.settingsView!.setValue(Float(player.accompKeyValue), for: .accompKeyValue)
        self.settingsView!.setValue(player.recordVolume, for: .recordVolume)
        self.settingsView!.setValue(player.reverbValue, for: .reverbValue)
        self.settingsView!.setValue(player.eqValue, for: .eqValue)
        self.settingsView!.audioRouteChanged(plugIn: isHeadsetPluggedIn)
        self.view.addSubview(self.settingsView!)
    }
    // 重唱
    func onAgain() {
        print("KTVViewController onAgain()")
        self.isDone = false
        self.kxPlayer?.closeKTV()
        self.kxPlayer = nil
        self.trackView?.removeAllSubviews()
        self.lyricView!.removeAllSubviews()
        self.lrcLineIndex = 0
        self.bottomView?.resetGuide()
        self.singleScoreView?.setContentOffset(CGPoint.zero, animated: false)
        for subview in self.scoreViewArray {
            subview.setScore(0)
        }
        updateTotalScore(-1)
        updateSingleScore(-1)
        self.waittingView?.start()
        initPlayer()
    }
    // 播放
    func onPlay() {
        print("KTVViewController onPlay()")
        if(isDone) {
            self.onAgain()
        }else{
            self.kxPlayer?.startKTV()
        }
    }
    // 暂停
    func onPause() {
        print("KTVViewController onPause()")
        self.kxPlayer?.pauseKTV()
    }
    // 导唱(仅录歌时可用)
    func onGuide()  -> Bool {
        if hasGuide {
            guard let view = self.guideVolumeBgView else { return false}
            view.isHidden = !view.isHidden
            if !view.isHidden {
                if guideVolume == 0 {
                    guideVolume = self.kxPlayer?.accompVolume ?? 0.0
                }
                self.guideVolumeSlider!.value = guideVolume
                self.kxPlayer?.guideSingVolume = guideVolume
            }else{
                self.kxPlayer?.guideSingVolume = 0.0
            }
            return !view.isHidden
        }
        return false
    }
    // 完成(仅录歌时可用, 跳转到作品回放编辑页)
    func onCompleted() {
        print("KTVViewController onCompleted()")
        doFinished()
    }
    // 录歌完成
    private func doFinished() {
        guard let player = self.kxPlayer else { return }
        var progress:Float = 1.0
        if(!isDone) {
            isDone = true
            player.pauseKTV()
            progress = player.currKTVPos / player.currKTVDuration
            player.closeKTV()
            
            //结束保存
            self.recWavFile?.finishWrite()
            self.mixRecWavFile?.finishWrite()
        }
        var min = self.minScore
        if(min == 200){
            min = 0
        }
        self.songInfo.score = self.totalScore
        self.songInfo.minScore = self.minScore
        self.songInfo.maxScore = self.maxScore
        self.songInfo.progress = progress
        self.songInfo.duration = Int(player.currKTVDuration)
        
        if self.songInfo.type == 0 {
            self.resultView = RecordResultView(progress: progress){
                self.resultView!.removeFromSuperview()
                let vc = RecordEditViewController(songInfo: self.songInfo, delegate: self)
                vc.setScore(min: min, max: self.maxScore, total: self.totalScore, progress: progress)
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            }
        }else {
            self.resultView = RecordResultView(minScore: min, maxScore: self.maxScore, totalScore: self.totalScore, progress: progress) {
                self.resultView!.removeFromSuperview()
                let vc = RecordEditViewController(songInfo: self.songInfo, delegate: self)
                vc.setScore(min: min, max: self.maxScore, total: self.totalScore, progress: progress)
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            }
        }
        self.view.addSubview(self.resultView!)
    }
    
    // 编辑(仅回放编辑时可用)
    func onEdit() {
        
    }
    // 保存(仅回放编辑时可用)
    func onSave(){
        
    }
    
    //TuningSettingsViewDelegate
    // 调音板
    func onVolumeChanged(type:TuningSettingType, value:Float) {
        switch type {
        case .accompVolume:
            self.kxPlayer?.accompVolume = value
            break
        case .accompKeyValue:
            self.kxPlayer?.accompKeyValue = Int32(value)
            break
        case .recordVolume:
            self.kxPlayer?.recordVolume = value
            break
        case .reverbValue:
            self.kxPlayer?.reverbValue = value
            break
        case .eqValue:
            self.kxPlayer?.eqValue = value
            break
        }
    }
    
    func onTuningSettingViewClose() {
        self.settingsView?.removeFromSuperview()
        self.settingsView = nil
    }
    
    
    @objc func sliderValueChanged(_ slider:UISlider, _ event:UIEvent) {
        print("sliderValueChanged")
        guard let player = self.kxPlayer else {
            return
        }
        let touch = event.allTouches?.first
        switch touch?.phase {
        case .ended:
            guideVolume = slider.value
            player.guideSingVolume = guideVolume
            break
        default:
            break
        }
    }
    
    
}


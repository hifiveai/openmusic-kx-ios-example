//
//  RecordEditViewController.swift
//  KXSDKSample
//
//  Created by 李刚 on 2022/3/30.
//

import UIKit
import KXKTVSDK
import AVFoundation

protocol RecordEditViewControllerDelegate:NSObjectProtocol {
    func onRecordEditCompleted(_ vc:UIViewController, againSong:SongInfo?)
}

class RecordEditViewController: UIViewController, KXOkEditPlayerDelegate,KTVBottomViewDelegate, TuningSettingsViewDelegate {
    
    
    private var isPlaying = false
    private var isDone = false
    private var isHeadsetPluggedIn = false
    private var timer:Timer?
    private var kxPlayer:KXOkEditPlayer?
    
    private var titleView:KTVTitleView?
    
    
    private var singleScoreLabel:UILabel?
    private var totalScoreLabel:UILabel?
    
    private var bottomView:KTVBottomView?
    private var timeSlider:UISlider?
    private var trackView:UIImageView?
    private var lyricView:UIView?
    private var singleScoreView:UIScrollView?
    private var settingsView:TuningSettingsView?
    
    private var resultView:RecordResultView?
    private var waittingView:WaittingView?

    
    
    private var songInfo:SongInfo
    private var delegate:RecordEditViewControllerDelegate
    
    private var lrcLineIndex = 0
    private var scoreViewArray:[ScoreBarView] = [ScoreBarView]()
    
    
    private var minScore:Float = 0
    private var maxScore:Float = 0
    private var totalScore:Float = 0
    private var progress:Float = 0
    private var newScore:Float = 0
    
    private var sliderDragged = false
    
    private var recordChanged = false
    private var newRecord = true
    
    
    
    init(songInfo:SongInfo, delegate:RecordEditViewControllerDelegate){
        self.delegate = delegate
        self.songInfo = songInfo
        super.init(nibName: nil, bundle: nil)
        if DataManager.shared.hasWork(self.songInfo.songId, recordPath: self.songInfo.recordPath) {
            newRecord = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setScore(min:Float, max:Float, total:Float, progress:Float){
        self.progress = progress
        self.minScore = min
        self.maxScore = max
        self.totalScore = total
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isHeadsetPluggedIn = Utils.shared.headsetIsPluggedIn()
        //监听耳机插/拨出事件
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChangeListenerCallback(notification:)), name: AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance())
        
        let bgImg = UIImageView(frame: self.view.bounds)
        bgImg.contentMode = .scaleAspectFill
        bgImg.image = UIImage(named: "ktv_bg")
        self.view.addSubview(bgImg)
        
        //Title
        self.titleView = KTVTitleView(playbackTitle: self.songInfo.name, backBlock: {
            self.doBack()
        }, scoreBlock:{
            self.showScore()
        })
        self.view.addSubview(self.titleView!)
        
        
        var h = self.titleView!.frame.maxY + 32
        var lyric_y = h
        //音轨View
        if songInfo.type == 2  {
            trackView = UIImageView(frame: CGRect(x: 0, y: h, width: self.view.bounds.width, height: 112))
            trackView!.backgroundColor = UIColor.rgba(r: 0, g: 0, b: 0, a: 0.2)
            self.view.addSubview(trackView!)
            h += trackView!.bounds.height
            
            let trackBgImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 114, height: trackView!.bounds.height))
            trackBgImg.image = UIImage(named: "track_bg")
            trackBgImg.contentMode = .scaleAspectFill
            trackView!.addSubview(trackBgImg)
            lyric_y = trackView!.frame.maxY
        }
        
        
        //底部操作按钮
        self.bottomView = KTVBottomView(true, delegate: self)
        var bFrame = self.bottomView!.frame
        bFrame.origin.y = self.view.bounds.height - bFrame.height - 20 - kSafeAreaBottomH
        self.bottomView!.frame = bFrame
        self.view.addSubview(self.bottomView!)
        h += (bFrame.height + 20)
        
        
        self.timeSlider = UISlider(frame: CGRect(x: 20, y: bFrame.minY - 42, width:self.view.bounds.width - 40, height: 22))
        self.timeSlider!.minimumValue = 0
        self.timeSlider!.maximumValue = 100
        self.timeSlider!.value = 0
        self.timeSlider!.isContinuous = false
        self.timeSlider!.setThumbImage(UIImage(named: "slider_track"), for: .normal)
        self.timeSlider!.contentMode = .scaleAspectFit
        self.timeSlider!.minimumTrackTintColor = UIColor.rgb(r: 242, g: 50, b: 81)
        self.timeSlider!.maximumTrackTintColor = UIColor.rgb(r: 165, g: 165, b: 165)
        self.timeSlider!.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        self.timeSlider!.addTarget(self, action: #selector(sliderTouchUp(_:)), for: .touchUpInside)
        self.timeSlider!.addTarget(self, action: #selector(sliderValueChanged(_:_:)), for: .valueChanged)
        self.view.addSubview(self.timeSlider!)
        self.timeSlider!.isEnabled = false
        h += (self.timeSlider!.frame.height + 20)
        
        if songInfo.type > 0 {
            //单句得分图形
            self.singleScoreView = UIScrollView(frame: CGRect(x: 20, y: self.timeSlider!.frame.minY - 88, width: self.view.bounds.width - 40, height: 68))
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
            bFrame.origin.y = self.timeSlider!.frame.minY - bFrame.height - 32
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
        
        
        self.waittingView = WaittingView()
        self.view.addSubview(self.waittingView!)
        self.waittingView!.start(text: "数据加载中...")
        self.initPlayer()
    }
    
    private func initPlayer(){
        self.kxPlayer = KXOkEditPlayer(delegate: self)
        if songInfo.type == 2 { //逐字歌词以双行效果展示
            self.kxPlayer?.setLrcView(lyricView!, mode: .ktvMode)
        } else {
            self.kxPlayer?.setLrcView(lyricView!)
        }
        let recordPath = Utils.shared.cachedFilePath(songInfo.recordPath)
        if let view = self.trackView {
            self.kxPlayer!.setTrackView(view)
        }
        self.isDone = false
        self.isPlaying = true
        self.bottomView!.setIsPlaying(self.isPlaying)
        self.startTimer()
        DispatchQueue.global().async {
            let item = DataManager.shared.convert2KTVSDKItem(self.songInfo)
            self.kxPlayer?.openKTV(item, recPath: recordPath, nowStart: true)
        }
    }
    //点击返回按钮
    private func doBack(){
        self.onPause()
        self.isPlaying = false
        self.bottomView!.setIsPlaying(self.isPlaying)
        if newRecord {
            let alert = UIAlertController(title: "温馨提示", message: "您的作品还未保存！", preferredStyle: .alert)
            let save = UIAlertAction(title: "保存", style: .default) { _ in
                self.doSave(false)
            }
            alert.addAction(save)
            let ok = UIAlertAction(title: "不保存", style: .default) { _ in
                self.kxPlayer?.closeKTV()
                self.cancelTimer()
                self.delegate.onRecordEditCompleted(self, againSong: nil)
            }
            alert.addAction(ok)
            let cancel = UIAlertAction(title: "取消", style: .cancel)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }else if recordChanged {
            self.showSaveMenus()
        }else{
            self.kxPlayer?.closeKTV()
            self.cancelTimer()
            self.delegate.onRecordEditCompleted(self, againSong: nil)
        }
    }
    
    private func showScore(){
        if self.songInfo.type == 0 {
            self.resultView = RecordResultView(progress: progress){
                self.resultView!.removeFromSuperview()
                self.resultView = nil
            }
        }else {
            self.resultView = RecordResultView(minScore: self.minScore, maxScore: self.maxScore, totalScore: self.totalScore, progress: self.progress) {
                self.resultView!.removeFromSuperview()
                self.resultView = nil
            }
        }
        self.view.addSubview(self.resultView!)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.cancelTimer()
        self.kxPlayer?.closeKTV()
    }
    
    @objc func sliderTouchDown(_ sender:UISlider) {
        print("sliderTouchDown")
        self.sliderDragged = true
    }
    
    @objc func sliderTouchUp(_ slider:UISlider) {
        print("sliderTouchUp")
        self.resetScoreView()
        if let player = kxPlayer {
            player.currKTVPos = player.currKTVDuration * slider.value / 100.0
        }
        self.sliderDragged = false
    }
    
    @objc func sliderValueChanged(_ slider:UISlider, _ event:UIEvent) {
        print("sliderValueChanged")
        guard let player = self.kxPlayer else {
            return
        }
        let touch = event.allTouches?.first
        switch touch?.phase {
        case .began:
            break
        case .ended:
            self.resetScoreView()
            player.currKTVPos = player.currKTVDuration * slider.value / 100.0
            self.sliderDragged = false
            break
        default:
            break
        }
    }
    
    //启动【刷新演唱时间】定时器
    private func startTimer() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatePlayerTime), userInfo: nil, repeats: true)
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
            if !self.sliderDragged {
                self.timeSlider?.value =  player.currKTVPos * 100.0 / player.currKTVDuration
            }
        }else{
            self.titleView?.updateTime(0, duration: 0)
            if !self.sliderDragged {
                self.timeSlider?.value = 0.0
            }
        }
    }
    
    private func updateSingleScore(_ score:Int32){
        if score >= 0 {
            self.singleScoreLabel?.text = "单句得分：\(score)"
        }else{
            self.singleScoreLabel?.text = "单句得分：--"
        }
    }
    
    private func updateTotalScore(_ score:Float){
        if score >= 0 {
            self.totalScoreLabel?.text = String(format: "总分：%d", Int(score))
        }else{
            self.totalScoreLabel?.text = "总分：--"
        }
    }
    
    
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
            DispatchQueue.main.async {
                self.settingsView?.audioRouteChanged(plugIn: self.isHeadsetPluggedIn)
            }
        }
    
    //KTVBottomViewDelegate
    // 调音
    func onSetting() {
        print("RecordEditViewController onSetting()")
        guard let player = self.kxPlayer else {
            return
        }
        self.settingsView = TuningSettingsView(playback: true, delegate: self)
        self.settingsView!.setValue(player.accompVolume, for: .accompVolume)
        self.settingsView!.setValue(player.recordVolume, for: .recordVolume)
        self.settingsView!.setValue(player.reverbValue, for: .reverbValue)
        self.settingsView!.setValue(player.eqValue, for: .eqValue)
        self.settingsView!.audioRouteChanged(plugIn: isHeadsetPluggedIn)
        self.view.addSubview(self.settingsView!)
    }
    
    private func resetScoreView(){
        self.lrcLineIndex = 0
        self.singleScoreView?.setContentOffset(CGPoint.zero, animated: false)
        for subview in self.scoreViewArray {
            subview.setScore(0)
        }
    }
    
    // 重唱
    func onAgain() {
        print("RecordEditViewController onAgain()")
        self.isDone = false
        self.kxPlayer?.closeKTV()
        self.kxPlayer = nil
        self.trackView?.removeAllSubviews()
        self.lyricView!.removeAllSubviews()
        self.resetScoreView()
        updateTotalScore(-1)
        updateSingleScore(-1)
        let song = SongInfo(song: self.songInfo)
        song.recordPath = Utils.shared.resourcePath(song.songId)
        self.delegate.onRecordEditCompleted(self, againSong: song)
    }
    // 播放
    func onPlay() {
        print("RecordEditViewController onPlay()")
        if(isDone) {
            self.trackView?.removeAllSubviews()
            self.lyricView!.removeAllSubviews()
            self.resetScoreView()
            updateTotalScore(-1)
            updateSingleScore(-1)
            self.initPlayer()
        }else{
            self.kxPlayer?.startKTV()
        }
    }
    // 暂停
    func onPause() {
        print("RecordEditViewController onPause()")
        self.kxPlayer?.pauseKTV()
        
    }
    // 导唱(仅录歌时可用)
    func onGuide() -> Bool {
        return false
    }
    // 完成(仅录歌时可用, 跳转到作品回放编辑页)
    func onCompleted() {
        
    }
    
    // 编辑(仅回放编辑时可用)
    func onEdit() {
        let alert = UIAlertController(title: "温馨提示", message: "暂不提供此功能，敬请期待！", preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    // 保存(仅回放编辑时可用)
    func onSave(){
        if newRecord {
            self.doSave(false)
        }else{
            self.showSaveMenus()
        }
    }
    // 显示保存选项
    private func showSaveMenus(){
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let overrideRecord = UIAlertAction(title: "覆盖当前作品", style: .default) { _ in
            self.doSave(false)
        }
        sheet.addAction(overrideRecord)
        let createNewRecord = UIAlertAction(title: "保存为新作品", style: .default) { _ in
            self.doSave(true)
        }
        sheet.addAction(createNewRecord)
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel))
        self.present(sheet, animated: true, completion: nil)
    }
    
    // 保存录音文件
    private func doSave(_ createNew:Bool){
        self.cancelTimer()
        self.waittingView!.start(text: "正在保存...")
        let newSong = SongInfo(song: self.songInfo)
        newSong.minScore = self.minScore
        newSong.maxScore = self.maxScore
        newSong.progress = self.kxPlayer!.currKTVPos / Float(newSong.duration)
        if createNew {
            newSong.recordPath = Utils.shared.recordFileName(newSong.songId)
        }
        let newRecordPath = Utils.shared.cachedFilePath(newSong.recordPath)
        if createNew {
            self.kxPlayer?.exportNewRecFile(newRecordPath, progressBlock: nil){ (success, err) in
                self.saveResult(success, newWork: true, err: err)
            }
        }else {
            self.kxPlayer?.coverSaveRecProgressBlock(nil) {(success, err) in
                self.saveResult(success, newWork: self.newRecord, err: err)
            }
        }
    }
    
    private func saveResult(_ success:Bool,newWork:Bool, err:Error?){
        DispatchQueue.main.async {
            self.waittingView!.stop()
            if success {
                if newWork {
                    DataManager.shared.addWork(self.songInfo)
                }
                self.recordChanged = false
                self.newRecord = false
                let alert = UIAlertController(title: "温馨提示", message: "保存作品成功！", preferredStyle: .alert)
                let ok = UIAlertAction(title: "确定", style: .default) { _ in
                    self.delegate.onRecordEditCompleted(self, againSong: nil)
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)

            } else {
                self.recordChanged = false
                self.newRecord = false
                let errStr:String = err?.localizedDescription ?? "保存作品失败！"
                self.showError(errStr)
            }
        }
    }
    
    //TuningSettingsViewDelegate
    func onVolumeChanged(type:TuningSettingType, value:Float) {
        switch type {
        case .accompVolume:
            recordChanged = true
            self.kxPlayer?.accompVolume = value
            break
        case .recordVolume:
            recordChanged = true
            self.kxPlayer?.recordVolume = value
            break
        case .reverbValue:
            recordChanged = true
            self.kxPlayer?.reverbValue = value
            break
        case .eqValue:
            recordChanged = true
            self.kxPlayer?.eqValue = value
            break
        default:
            break
        }
    }
    
    func onTuningSettingViewClose() {
        self.settingsView?.removeFromSuperview()
        self.settingsView = nil
    }
    
    private func showError(_ errStr:String) {
        DispatchQueue.main.async {
            Utils.alert(errStr, vc: self)
        }
    }
    
//    //KXOkEditPlayerDelegate
    func recPlayer(_ sender: Any, didError error: Error) {
        self.isDone = true
        self.timeSlider!.isEnabled = false
        self.waittingView?.stop()
        self.isPlaying = false
        self.cancelTimer()
        self.bottomView!.setIsPlaying(self.isPlaying)
        self.showError(error.localizedDescription)
    }

    func recPlayerDidPlayEnd(_ sender: Any) {
        self.isDone = true
        self.isPlaying = false
        self.cancelTimer()
        self.titleView?.updateTime(0, duration: 0)
        self.bottomView!.setIsPlaying(self.isPlaying)
        self.timeSlider?.value = 0.0
        self.timeSlider!.isEnabled = false
    }

    func recPlayer(_ sender: Any, didRecStatusChanged status: KXKTVPlayStatus) {
        if status.rawValue >= 2 && !self.waittingView!.isHidden {
            self.waittingView?.stop()
        }
        self.timeSlider!.isEnabled = status.rawValue == 3
    }

    func recPlayer(_ sender: Any, didCallbackSingleScore singleScore: Float) {
        self.updateSingleScore(Int32(singleScore))
        self.addNewSingleScore(singleScore)
    }
    
    func recPlayer(_ sender: Any, didCallbackTotalScore totalScore: Float) {
        self.updateTotalScore(totalScore)
    }

}

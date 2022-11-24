//
//  KTVBottomView.swift
//  KXSDKSample
//  演唱/回放页底部View
//  Created by 李刚 on 2022/4/12.
//

import UIKit

protocol KTVBottomViewDelegate:NSObjectProtocol {
    // 调音
    func onSetting()
    // 重唱
    func onAgain()
    // 播放
    func onPlay()
    // 暂停
    func onPause()
    // 导唱(仅录歌时可用)
    func onGuide() -> Bool
    // 完成(仅录歌时可用)
    func onCompleted()
    // 编辑(仅回放编辑时可用)
    func onEdit()
    // 保存(仅回放编辑时可用)
    func onSave()
}

//演唱/回放页底部View
class KTVBottomView: UIView {

    private var guideEnable = true
    private var playBtn:UIButton?
    private var guideBtn:IconButton?
    private var delegate:KTVBottomViewDelegate
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ isPlayback:Bool, delegate:KTVBottomViewDelegate){
        self.delegate = delegate
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 54))
        initPlayBtn()
        if isPlayback {
            self.initPlaybackSubviews()
        }else{
            self.initRecordSubviews()
        }
    }
    
    func setIsPlaying(_ isPlaying:Bool) {
        print("setIsPlaying:\(isPlaying)")
        self.playBtn!.isSelected = isPlaying
    }
    
    func resetGuide(){
        if(guideEnable) {
            self.guideBtn?.updateStatus(iconName: "guide", labelColor: UIColor.white)
        }
    }
    
    func disableGuide(){
        guideEnable = false
        self.guideBtn?.updateStatus(iconName: "guide_u", labelColor: UIColor.rgb(r: 164, g: 164, b: 164))
    }
    
    private func initPlayBtn(){
        self.playBtn = UIButton(type: .custom)
        self.playBtn!.frame = CGRect(x: 0, y: 0, width: self.bounds.height, height: self.bounds.height)
        self.playBtn!.center = self.center
        self.playBtn!.setImage(UIImage(named: "play"), for: .normal)
        self.playBtn!.setImage(UIImage(named: "pause"), for: .selected)
        self.playBtn!.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        self.addSubview(self.playBtn!)
    }
    
    private func initRecordSubviews() {
        let settingBtn = IconButton(title: "调音", iconName: "tuning_setting") {
            self.delegate.onSetting()
        }
        var frame = settingBtn.frame
        frame.origin.x = self.playBtn!.frame.minX - 30 - frame.width
        frame.origin.y = self.playBtn!.frame.maxY - frame.height
        settingBtn.frame = frame
        self.addSubview(settingBtn)
        
        guideBtn = IconButton(title: "导唱", iconName: "guide") {
            if self.guideEnable {
                if self.delegate.onGuide() {
                    self.guideBtn!.updateStatus(iconName: "guide_f", labelColor: UIColor.rgb(r: 249, g: 84, b: 111))
                }else{
                    self.guideBtn!.updateStatus(iconName: "guide", labelColor: UIColor.white)
                }
            }
        }
        
        var gFrame = guideBtn!.frame
        gFrame.origin.x = frame.minX - 30 - gFrame.width
        gFrame.origin.y = frame.minY
        guideBtn!.frame = gFrame
        self.addSubview(guideBtn!)
        
        let againBtn = IconButton(title: "重唱", iconName: "repeat") {
            self.delegate.onAgain()
        }
        frame = againBtn.frame
        frame.origin.x = self.playBtn!.frame.maxX + 30
        frame.origin.y = gFrame.minY
        againBtn.frame = frame
        self.addSubview(againBtn)
        
        let completeBtn = IconButton(title: "完成", iconName: "completed") {
            self.delegate.onCompleted()
        }
        gFrame = completeBtn.frame
        gFrame.origin.x = frame.maxX + 30
        gFrame.origin.y = frame.minY
        completeBtn.frame = gFrame
        self.addSubview(completeBtn)
    }
    
    private func initPlaybackSubviews() {
        let settingBtn = IconButton(title: "调音", iconName: "tuning_setting") {
            self.delegate.onSetting()
        }
        var frame = settingBtn.frame
        frame.origin.x = self.playBtn!.frame.minX - 30 - frame.width
        frame.origin.y = self.playBtn!.frame.maxY - frame.height
        settingBtn.frame = frame
        self.addSubview(settingBtn)
        
        let editBtn = IconButton(title: "编辑", iconName: "edit") {
            self.delegate.onEdit()
        }
        
        var gFrame = editBtn.frame
        gFrame.origin.x = frame.minX - 30 - gFrame.width
        gFrame.origin.y = frame.minY
        editBtn.frame = gFrame
        self.addSubview(editBtn)
        
        let againBtn = IconButton(title: "重唱", iconName: "repeat") {
            self.delegate.onAgain()
        }
        frame = againBtn.frame
        frame.origin.x = self.playBtn!.frame.maxX + 30
        frame.origin.y = gFrame.minY
        againBtn.frame = frame
        self.addSubview(againBtn)
        
        let saveBtn = IconButton(title: "保存", iconName: "save") {
            self.delegate.onSave()
        }
        gFrame = saveBtn.frame
        gFrame.origin.x = frame.maxX + 30
        gFrame.origin.y = frame.minY
        saveBtn.frame = gFrame
        self.addSubview(saveBtn)
    }
    
    @objc private func playAction() {
        let isSelected = self.playBtn!.isSelected
        self.playBtn!.isSelected = !isSelected
        if isSelected {
            self.delegate.onPause()
        }else{
            self.delegate.onPlay()
        }
    }

}

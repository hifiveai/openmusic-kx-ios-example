//
//  KTVTitleView.swift
//  KXSDKSample
//  演唱/回放页底部View
//  Created by 李刚 on 2022/4/11.
//

import UIKit

typealias ActionBlock = () -> Void

//自定义按钮(ICON + label)
class IconButton:UIView {
    private var actionBlock:ActionBlock
    private var imgView:UIImageView?
    private var label:UILabel?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(title:String, iconName:String, block:@escaping ActionBlock) {
        self.actionBlock = block
        super.init(frame: CGRect(x: 0, y: 0, width: 34, height: 43))
        let btn = UIButton(type: .custom)
        btn.frame = self.bounds
        btn.addTarget(self, action: #selector(touchedAction), for: .touchUpInside)
        self.addSubview(btn)
        
        imgView = UIImageView(image: UIImage(named: iconName))
        imgView!.frame = CGRect(x: 5, y: 0, width: 24, height: 24)
        imgView!.contentMode = .scaleAspectFit
        self.addSubview(imgView!)
        
        label = UILabel()
        label!.text = title
        label!.lineBreakMode = .byClipping
        label!.font = UIFont.systemFont(ofSize: 12)
        label!.textColor = UIColor.white
        label!.textAlignment = .center
        label!.frame = CGRect(x: 0, y: 29, width: self.bounds.width, height: 14)
        self.addSubview(label!)
    }
    
    func updateStatus(iconName:String, labelColor:UIColor){
        imgView!.image = UIImage(named: iconName)
        label!.textColor = labelColor
    }
    
    @objc private func touchedAction() {
        self.actionBlock()
    }
}

//演唱/回放页顶部View
class KTVTitleView: UIView {

    private var titleLabel:UILabel?
    private var timeLabel:UILabel?
    private var backBlock: ActionBlock?
    private var scoreBlock: ActionBlock?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(ktvTitle songName:String,playback:Bool, backBlock:@escaping ActionBlock) {
        super.init(frame:CGRect(x: 0, y: UIApplication.shared.statusBarFrame.size.height, width: UIScreen.main.bounds.width, height: 66.0))
        self.backBlock = backBlock
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.addSubview(backBtn)
        
        let backImg = UIImageView(image: UIImage(named: "back"))
        backImg.frame = CGRect(x: 20, y: 10, width: 24, height: 24)
        backImg.contentMode = .scaleAspectFit
        self.addSubview(backImg)
        
        self.titleLabel = UILabel(frame: CGRect(x: 60, y: 0, width: self.bounds.width - 120, height: 44))
        self.titleLabel!.text = songName
        self.titleLabel!.textAlignment = .center
        self.titleLabel!.numberOfLines = 1
        self.titleLabel!.font = UIFont.boldSystemFont(ofSize: 20)
        self.titleLabel!.textColor = UIColor.white
        self.addSubview(self.titleLabel!)
        self.timeLabel = UILabel(frame:CGRect(x: (self.bounds.width - 70) / 2 + 4, y: self.bounds.height - 12, width: 70, height: 12))
        self.timeLabel!.textAlignment = .center
        self.timeLabel!.numberOfLines = 1
        self.timeLabel!.font = UIFont.boldSystemFont(ofSize:10)
        self.timeLabel!.textColor = UIColor.init(white: 1.0, alpha: 0.36)
        self.addSubview(self.timeLabel!)
        self.updateTime(0, duration: 0)
        
        initIcon(playback)
    }
    
    convenience init(playbackTitle songName:String, backBlock:@escaping ActionBlock, scoreBlock:@escaping ActionBlock) {
        self.init(ktvTitle: songName,playback:true, backBlock: backBlock)
        self.scoreBlock = scoreBlock
        let scoreBtn = IconButton(title: "成绩", iconName: "score") {
            self.scoreAction()
        }
        self.addSubview(scoreBtn)
        var frame = scoreBtn.frame
        frame.origin.x = self.bounds.width - 60
        frame.origin.y = (self.bounds.height - scoreBtn.bounds.height)/2
        scoreBtn.frame = frame
    }
    
    private func initIcon(_ playback:Bool){
        var imgStr = "status_record"
        if playback {
            imgStr = "status_play"
        }
        let img = UIImage(named: imgStr)
        let icon = UIImageView(image: img)
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: self.timeLabel!.frame.origin.x - 8, y: self.bounds.height - 10, width: 8, height: 8)
        self.addSubview(icon)
    }
    
    
    
    func updateTime(_ currTime:Float, duration:Float) {
        self.timeLabel!.text = Utils.shared.formatTime(currTime) + "|" + Utils.shared.formatTime(duration)
    }
    
    @objc private func backAction() {
        guard let block = self.backBlock else { return }
        block()
    }
    
    @objc private func scoreAction() {
        guard let block = self.scoreBlock else { return }
        block()
    }
    
    
}

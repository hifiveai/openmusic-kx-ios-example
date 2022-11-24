//
//  SongWithSingerItemViewCell.swift
//  KXSDKSample
//  歌曲/作品列表顶View
//  Created by 李刚 on 2022/5/6.
//

import UIKit

protocol SongItemBtnDelegate:NSObjectProtocol {
    func onTouchedItemBtn(_ isDel:Bool)
}


protocol SongItemViewCellDelegate:NSObjectProtocol {
    func onItemAction(_ song:SongInfo, isPlayback:Bool)
    func onDelItem(_ song:SongInfo)
    func onError(_ song:SongInfo, errInfo:String)
}

let completedColor = UIColor.rgb(r: 242, g: 78, b: 105)
//列表项按钮View
class SongItemBtn: UIView {
    
    private var btnLabel:UILabel?
    private var progressView:UIView?
    private var label:String = "演唱"
    
    var delegate:SongItemBtnDelegate?
    
    private var isDel = false
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        let h_h = self.bounds.height / 2
        self.backgroundColor = UIColor.white
        self.layer.masksToBounds = true
        self.layer.cornerRadius = h_h
        
        
        self.progressView = UIView(frame: self.bounds)
        self.progressView!.backgroundColor = completedColor
        self.progressView!.layer.masksToBounds = true
        self.progressView!.layer.cornerRadius = h_h
        self.addSubview(self.progressView!)
        
        self.btnLabel = UILabel(frame: CGRect(x: 2, y: 0, width: self.bounds.width - 4, height: self.bounds.height))
        self.btnLabel!.text = self.label
        self.btnLabel!.font = UIFont.systemFont(ofSize: 13)
        self.btnLabel!.textColor = completedColor
        self.btnLabel!.textAlignment = .center
        self.btnLabel!.numberOfLines = 1
        self.btnLabel!.adjustsFontSizeToFitWidth = true
        self.addSubview(self.btnLabel!)
        
        let btn = UIButton(type: .custom)
        btn.frame = self.bounds
        btn.backgroundColor = UIColor.clear
        btn.addTarget(self, action: #selector(touched), for: .touchUpInside)
        self.addSubview(btn)
    }
    
    func setCompletion(_ complete:Bool){
        self.progressView!.isHidden = !complete
        self.btnLabel!.textColor = complete ? UIColor.white : completedColor
        if(complete) {
            self.progressView!.frame = self.bounds
            self.btnLabel!.text = self.label
            self.btnLabel!.font = UIFont.systemFont(ofSize: 13)
        }
    }
    
    
    func setLabel(_ text:String){
        self.label = text
        self.btnLabel!.text = self.label
        self.btnLabel!.font = UIFont.systemFont(ofSize: 13)
    }
    
    func setLabel(_ text:String, color:UIColor){
        setLabel(text)
        self.btnLabel!.textColor = color
    }
    
    func setDel(enable:Bool) {
        if enable {
            self.isDel = true
            self.setLabel("删除", color: UIColor.darkGray)
            self.progressView!.isHidden = true
            self.backgroundColor = UIColor.lightGray
        }
    }
    
    func setProgress(_ progress:Float){
        guard let pView = self.progressView else { return }
        var frame = pView.frame
        frame.size.width = self.bounds.width * CGFloat(progress)
        pView.frame = frame
        self.btnLabel!.text = "" + Utils.shared.percentString(NSNumber(value:progress))
        self.btnLabel!.font = UIFont.systemFont(ofSize: 10)
        self.btnLabel!.textColor = UIColor.black
    }
    
    @objc func touched(){
        if let delegate = self.delegate {
            delegate.onTouchedItemBtn(self.isDel)
        }
    }
}



class SongWithSingerItemViewCell: UITableViewCell ,SongItemBtnDelegate{
    
    @IBOutlet var songNameLabel:UILabel!
    @IBOutlet var singerLabel:UILabel!
    @IBOutlet var typeLabel:UILabel!
    @IBOutlet var songImageView:UIImageView!
    @IBOutlet var btnBgView:UIView!
    @IBOutlet var delBtnView:UIView!
    @IBOutlet var btnTop:NSLayoutConstraint!
    
    
    private var btnDefTop:CGFloat = 0.0
    
    private var songInfo:SongInfo?
    var delegate:SongItemViewCellDelegate?
    private var isPlaybackCell = false
    
    private var itemBtn:SongItemBtn?
    private var delBtn:SongItemBtn?
    private var index:Int = -1
//    private var downloading = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.downloading = false
        btnDefTop = self.btnTop.constant
        
        songImageView.contentMode = .scaleAspectFit
        
        itemBtn = SongItemBtn(frame: self.btnBgView.bounds)
        itemBtn!.delegate = self
        self.btnBgView.addSubview(itemBtn!)
        
        delBtn = SongItemBtn(frame: self.delBtnView.bounds)
        delBtn!.delegate = self
        delBtn!.setDel(enable: true)
        self.delBtnView.addSubview(delBtn!)
        self.delBtnView.isHidden = true
    }
    

    
    func setSongInfo(_ info:SongInfo){
        self.songInfo = info
        self.itemBtn!.setCompletion(true)
    }
    
    func setIsPlaybackCell(_ isPlayback:Bool) {
        self.isPlaybackCell = isPlayback
        if isPlayback {
            self.delBtnView.isHidden = false
            self.btnTop.constant = btnDefTop
            self.itemBtn!.setLabel("回放", color: UIColor.white)
            self.itemBtn!.setCompletion(true)
            if self.songInfo!.score > 0 {
                self.typeLabel.text = String(format: "(%.0f分)", self.songInfo!.score)
                self.typeLabel.textColor = UIColor.rgb(r: 242, g: 78, b: 105)
                self.typeLabel.isHidden = false
            }else{
                self.typeLabel.isHidden = true
            }
        }else{
            self.delBtnView.isHidden = true
            self.btnTop.constant = 33//(self.bounds.height - self.btnBgView.bounds.height) / 2
            self.typeLabel.isHidden = false
            self.itemBtn!.setLabel("演唱")
            self.typeLabel.text = DataManager.shared.songTypeString(self.songInfo!.type)
            self.typeLabel.textColor = UIColor.init(white: 1.0, alpha: 0.65)
        }
        self.needsUpdateConstraints()
    }
    
    func setIndex(_ index:Int){
        self.index = index
        let v = index % 10
        let imgName = String(format: "%d.jpg", v)
        let listPath:String = Bundle.main.path(forResource: imgName, ofType: "") ?? ""
        if FileManager.default.fileExists(atPath: listPath) {
            songImageView.image = UIImage(contentsOfFile: listPath)
        }else{
            let v = index % 5 + 1
            songImageView.image = UIImage(named: String(format: "song_img_%d", v))
        }
        
    }
    
    private func doDownloadSong(_ song:SongInfo, delegate:SongItemViewCellDelegate) {
        
        //缓存伴奏数据
        DataManager.shared.downloadSong(song) { progress, status, err in
            DispatchQueue.main.async {
                if err == nil {
                    if status == .paused {
                        self.itemBtn?.setLabel("演唱", color: completedColor)
                    }else if status == .completed || progress >= 1.0 {
                        self.itemBtn?.setCompletion(true)
                        if let song = self.songInfo {
                            DataManager.shared.removeDownloadTask(song.songId)
                        }
                        delegate.onItemAction(song, isPlayback: self.isPlaybackCell)
                        
                    }else if progress >= 0.0 {
                        self.itemBtn?.setProgress(progress)
                    }
                }else{
                    delegate.onError(song, errInfo: "下载歌曲资源失败！请稍后再试...")
                }
            }
        }
    }
    
    //SongItemBtnDelegate
    func onTouchedItemBtn(_ isDel:Bool) {
        guard let song = self.songInfo, let delegate = self.delegate else { return }
        if isDel {
            delegate.onDelItem(song)
        }else{
            if self.isPlaybackCell || song.type == 2{
                //回放Cell
                delegate.onItemAction(song, isPlayback: self.isPlaybackCell)
            }else{
                //演唱Cell
                let actionSheet = UIAlertController(title: "选择演唱模式", message: nil, preferredStyle: .actionSheet)
                actionSheet.addAction(UIAlertAction(title: "唱整首", style: .default, handler: { action in
                    self.goKTV(singType: 0)
                }))
                actionSheet.addAction(UIAlertAction(title: "唱30s", style: .default, handler: { action in
                    self.goKTV(singType: 1)
                }))
                actionSheet.addAction(UIAlertAction(title: "唱60s", style: .default, handler: { action in
                    self.goKTV(singType: 2)
                }))
                actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler:nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(actionSheet, animated: true)
            }
        }
        
    }
    
    /**
     去下载歌曲文件
     singType 0:唱整首 1:唱30s 2:唱60s
     */
    func goKTV(singType:Int) {
        
        guard let song = self.songInfo, let delegate = self.delegate else { return }
        
        DataManager.shared.loadSongInfo(self.songInfo!,singType: singType) { type, staticLyricUrl, dynamicLyricUrl, scoreUrl, musicUrl, guideUrl, partDuration,startSec, endSec, err in
            if err == nil {
                
                self.songInfo!.type = type
                if let url = staticLyricUrl {
                    self.songInfo!.staticLyricUrl = url
                }
                if let url = dynamicLyricUrl {
                    self.songInfo!.dynamicLyricUrl = url
                }
                if let url = scoreUrl {
                    self.songInfo!.scoreUrl = url
                }
                
                if let url = musicUrl {
                    self.songInfo!.musicUrl = url
                }
                if let url = guideUrl {
                    self.songInfo!.guideUrl = url
                }
                var success = true
                var errStr = ""
                //获取到的歌曲信息中至少要有歌词、伴奏文件，否则将停止演唱并弹出错误信息
                if (self.songInfo!.notFoundLyric) {
                    success = false
                    errStr = "无歌词文件！"
                }
                if (self.songInfo!.musicUrl.count <= 0) {
                    success = false
                    if errStr.count > 0 {
                        errStr = "无伴奏、歌词文件！"
                    }else{
                        errStr = "无伴奏文件！"
                    }
                }
                
                self.songInfo?.partDuration = partDuration
                self.songInfo?.startSec = startSec
                self.songInfo?.endSec = endSec
                
                //重新初始化文件路径
                self.songInfo?.initFilePath()
                
                if success {
                    if (DataManager.shared.songCached(song)) {
                        DispatchQueue.main.async {
                            delegate.onItemAction(song, isPlayback: self.isPlaybackCell)
                        }
                    }else{
                        self.doDownloadSong(song, delegate: delegate)
                    }
                }else{
                    DispatchQueue.main.async {
                        delegate.onError(song, errInfo: errStr)
                    }
                }
                
            }else{
                DispatchQueue.main.async {
                    delegate.onError(song, errInfo: "获取数据失败！")
                }
            }
        }
    }
    
}

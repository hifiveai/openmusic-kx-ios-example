//
//  ViewController.swift
//  KXSDKSample
//  伴奏/作品列表
//  Created by 李刚 on 2022/3/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SongItemViewCellDelegate, TabViewDelegate, RecordEditViewControllerDelegate {
    private let cellId = "SongWithSingerItemViewCell"
    
    @IBOutlet var topView:UIView!
    @IBOutlet var tableView:UITableView!
    //伴奏列表数据
    private var dataArray:[SongInfo] = [SongInfo]()
    //作品列表数据
    private var worksArray:[SongInfo] = [SongInfo]()
    
    //等待加载数据消息框
    private var waittingView:WaittingView?
    //是否第一次加载
    private var isFirst = true
    private var tabView:TabView?
    //当前选择的标签， 伴奏--0 / 作品--1
    private var currTabIndex:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        let bgImg = UIImageView(frame: self.view.bounds)
        bgImg.contentMode = .scaleAspectFill
        bgImg.image = UIImage(named: "ktv_bg")
        self.view.addSubview(bgImg)
        self.view.sendSubviewToBack(bgImg)
        
        self.checkRecordSession()
        self.tableView.isHidden = true
        self.worksArray = DataManager.shared.myWorks
        self.waittingView = WaittingView()
        self.view.addSubview(self.waittingView!)
        self.waittingView!.start(text: "数据加载中...")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currTabIndex == 1 {
            self.tabView?.setCurrTab(at: self.currTabIndex)
            self.worksArray = DataManager.shared.myWorks
            self.tableView!.reloadData()
        }
    }
    
    
    //设置全局底部安全区高度
    private func setGlobalConstant()  {
        //ios11，动态设置属性值
        if #available(iOS 11.0, *) {
            let safeAreaFram = self.view.safeAreaLayoutGuide.layoutFrame
            //底部安全区
            kSafeAreaBottomH = UIScreen.main.bounds.height - safeAreaFram.size.height - safeAreaFram.origin.y
        }else if UIScreen.main.bounds.width >= 375.0 && UIScreen.main.bounds.height >= 812.0 {
            //ios11以下iPhoneX等设备
            kSafeAreaBottomH = 20.0
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DataManager.shared.checkNetwork()
        if isFirst {
            isFirst = false
            setGlobalConstant()
            let nib = UINib(nibName: cellId, bundle: nil)
            self.tableView.register(nib, forCellReuseIdentifier: cellId)
            
            self.tableView.backgroundColor = UIColor.clear
            self.tableView.separatorStyle = .none
            self.tableView.tableFooterView = UIView(frame: CGRect.zero)
            
            tabView = TabView(dellegate: self)
            self.topView.addSubview(tabView!)
            
            DataManager.shared.loadSongList { array, error in
                DispatchQueue.main.async {
                    self.waittingView?.stop()
                    if let err = error {
                            Utils.alert(err.localizedDescription, vc: self)
                    }else{
                        self.dataArray = array!
                        self.tableView.reloadData()
                    }
                    self.tableView.isHidden = false
                }
            }
            
            
            
        }
    }
    
    //检查麦克风权限
    private func checkRecordSession() {
        let permissionStatus = AVAudioSession.sharedInstance().recordPermission
        if permissionStatus == AVAudioSession.RecordPermission.undetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                //此处可以判断权限状态来做出相应的操作，如改变按钮状态
                if !granted{
                        self.alertRecordPermission()
                }
            }
        }else if permissionStatus == AVAudioSession.RecordPermission.denied {
            self.alertRecordPermission()
        }
    }
    
    //无权限提示框
    private func alertRecordPermission() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "温馨提示", message: "您的麦克风未开启,请前往隐私设置界面开启", preferredStyle: .alert)
            let ok = UIAlertAction(title: "确定", style: .destructive) { (UIAlertAction) in
                let url = URL(string: UIApplication.openSettingsURLString)
                if  UIApplication.shared.canOpenURL(url!) {
                            if #available(iOS 10, *) {
                                UIApplication.shared.open(url!, options: [:],completionHandler: {(success) in})
                            } else {
                                UIApplication.shared.openURL(url!)
                            }
                }
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //UITableViewDelegate, UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = dataArray.count
        if currTabIndex == 1 {
            count = worksArray.count
        }
        if count == 0 {
            tableView.separatorStyle = .none
        }else{
            tableView.separatorStyle = .singleLineEtched
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? SongWithSingerItemViewCell else { fatalError("The dequeued cell is not an instance of SongWithSingerItemViewCell.")
        }
        cell.backgroundColor = UIColor.clear
        let index = indexPath.row
        cell.setIndex(index)
        cell.delegate = self
        if currTabIndex == 0 {
            cell.songNameLabel.text = dataArray[index].name
            cell.singerLabel.text = dataArray[index].singer
            cell.setSongInfo(dataArray[index])
            cell.setIsPlaybackCell(false)
        }else{
            cell.songNameLabel.text = worksArray[index].name
            cell.singerLabel.text = worksArray[index].singer
            cell.setSongInfo(worksArray[index])
            cell.setIsPlaybackCell(true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tableView didSelectRowAt:\(indexPath.row)")
    }
    
    //SongItemViewCellDelegate
    // K歌 / 回放作品
    func onItemAction(_ song:SongInfo, isPlayback: Bool) {
        if isPlayback {
            let vc = RecordEditViewController(songInfo: song, delegate: self)
            vc.setScore(min: song.minScore, max: song.maxScore, total: song.score, progress: song.progress)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        } else {
            let vc = KTVViewController(songInfo: song, delegate:self)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    // 删除作品
    func onDelItem(_ song:SongInfo) {
        let alert = UIAlertController(title: "温馨提示", message: "确定要删除此作品吗？", preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .destructive) { _ in
            self.waittingView?.start(text: "删除中...")
            DataManager.shared.delWork(song) {
                self.worksArray = DataManager.shared.myWorks
                self.tableView!.reloadData()
                self.waittingView?.stop()
            }
        }
        alert.addAction(ok)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    // 获取伴奏信息或者下载伴奏资源出错
    func onError(_ song:SongInfo, errInfo:String) {
        DispatchQueue.main.async {
            Utils.alert(errInfo, vc: self)
        }
    }
    
    //TabViewDelegate
    // 切换 伴奏/作品 列表
    func onTouchTab(at index:Int) {
        if(index != self.currTabIndex){
            self.currTabIndex = index
            if index == 1 {
                self.worksArray = DataManager.shared.myWorks
            }
            self.tableView!.reloadData()
        }
    }
    
    //RecordEditViewControllerDelegate
    // 作品回放返回处理
    func onRecordEditCompleted(_ vc: UIViewController, againSong: SongInfo?) {
        vc.dismiss(animated: true, completion: nil)
        if let song = againSong {
            let ktvVc = KTVViewController(songInfo: song, delegate: self)
            ktvVc.modalPresentationStyle = .overFullScreen
            self.present(ktvVc, animated: true, completion: nil)
        }else{
            self.currTabIndex = 1
            self.tabView!.setCurrTab(at: self.currTabIndex)
            self.worksArray = DataManager.shared.myWorks
            self.tableView!.reloadData()
        }
    }
}


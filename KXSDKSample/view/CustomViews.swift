//
//  CustomViews.swift
//  KXSDKSample
//  一些自定义View
//  Created by 李刚 on 2022/5/12.
//

import UIKit


protocol TabViewDelegate:NSObjectProtocol {
    func onTouchTab(at index:Int)
}


//单句得分单条柱形View
class ScoreBarView: UIView {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(posX:CGFloat) {
        super.init(frame: CGRect(x: posX, y: 0, width: 12, height: 68))
        self.addBg()
    }
    
    private func addBg(){
        let bgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 68))
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 5
        self.addSubview(bgView)
    }
    
    func setScore(_ score:Float) {
        var s:CGFloat = CGFloat(score)
        if(s > 100.0) {
            s = 100.0
        }
        if(s > 0) {
            let h:CGFloat = CGFloat(self.bounds.height * s / 100.0)
            let scoreView = UIView(frame: CGRect(x: 1, y: self.bounds.height - h, width: 8, height: h))
            scoreView.backgroundColor = UIColor.rgb(r: 251, g: 59, b: 94)
            scoreView.layer.masksToBounds = true
            scoreView.layer.cornerRadius = 4
            if s < 70.0 {
                scoreView.alpha = 0.6
            } else {
                scoreView.alpha = 1
            }
            self.addSubview(scoreView)
        }else{
            self.removeAllSubviews()
            self.addBg()
        }
    }
}

//等待框View
class WaittingView:UIView {
    
    private var activeView:UIActivityIndicatorView?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.backgroundColor = UIColor.clear
        let btn = UIButton(type: .custom)
        btn.frame = self.bounds
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        self.addSubview(btn)
    }
    
    func start(){
        if activeView == nil {
            let w:CGFloat = 100
            activeView = UIActivityIndicatorView(frame: CGRect(x: (self.bounds.width - w)/2, y: self.bounds.height/2 - w - UIApplication.shared.statusBarFrame.size.height, width: w, height: w))
            activeView!.style = .whiteLarge
            activeView!.backgroundColor = UIColor.rgba(r: 0, g: 0, b: 0, a: 0.62)
            activeView!.layer.masksToBounds = true
            activeView!.layer.cornerRadius = 10
            self.addSubview(activeView!)
            activeView!.startAnimating()
        }
        self.isHidden = false
    }
    
    
    func start(text:String){
        if activeView == nil {
            let w:CGFloat = 120
            let bgView = UIView(frame: CGRect(x: (self.bounds.width - w)/2, y: self.bounds.height/2 - w - UIApplication.shared.statusBarFrame.size.height, width: w, height: w))
            bgView.backgroundColor = UIColor.rgba(r: 0, g: 0, b: 0, a: 0.62)
            bgView.layer.masksToBounds = true
            bgView.layer.cornerRadius = 10
            self.addSubview(bgView)
            
            activeView = UIActivityIndicatorView(frame: CGRect(x: (self.bounds.width - w)/2, y: self.bounds.height/2 - w - UIApplication.shared.statusBarFrame.size.height, width: w, height: w / 4 * 3))
            activeView!.style = .whiteLarge
            activeView!.backgroundColor = UIColor.clear
            self.addSubview(activeView!)
            activeView!.startAnimating()
            
            let label = UILabel(frame: CGRect(x: activeView!.frame.minX + 8, y: activeView!.frame.maxX + 30, width: w - 16, height: 16))
            label.text = text
            label.textColor = UIColor.lightGray
            label.font = UIFont.boldSystemFont(ofSize: 12)
            label.textAlignment = .center
            label.numberOfLines = 1
            self.addSubview(label)
        }
        self.isHidden = false
    }
    
    func stop(){
        activeView?.stopAnimating()
        activeView?.removeFromSuperview()
        activeView = nil
        self.isHidden = true
    }
    
    func close(){
        activeView?.stopAnimating()
        activeView?.removeFromSuperview()
        activeView = nil
        self.removeFromSuperview()
    }
    
    @objc private func btnAction() {
    }
}

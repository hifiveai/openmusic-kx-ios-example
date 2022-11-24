//
//  TabView.swift
//  KXSDKSample
//  首页伴奏/作品类型标签View
//  Created by 李刚 on 2022/5/12.
//

import UIKit

//标签顶View
class TabItemView:UIView{
    
    var delegate:TabViewDelegate?
    private var index:Int
    private var label:UILabel?
    private var lineView:UIView?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame:CGRect, name:String, index:Int) {
        self.index = index
        super.init(frame:frame)
        let btn = UIButton(type: .custom)
        btn.frame = self.bounds
        btn.addTarget(self, action: #selector(touchedBtn), for: .touchUpInside)
        self.addSubview(btn)
        self.label = UILabel(frame:CGRect(x: 0, y: 20, width: self.bounds.width, height: 20))
        self.label!.textColor = UIColor.white
        self.label!.font = UIFont.systemFont(ofSize: 16)
        self.label!.text = name
        self.label!.textAlignment = .center
        self.addSubview(self.label!)
    
        let line_w:CGFloat = 20
        self.lineView = UIView(frame: CGRect(x: (self.bounds.width - line_w) / 2, y: self.label!.frame.maxY + 2, width: line_w, height: 2))
        self.lineView!.backgroundColor = UIColor.rgb(r: 251, g: 59, b: 94)
        self.lineView!.layer.masksToBounds = true
        self.lineView!.layer.cornerRadius = 1
        self.addSubview(self.lineView!)
        self.lineView!.isHidden = true
    }
    
    func setFocus(_ focus:Bool){
        if focus {
            self.label!.textColor = UIColor.rgb(r: 251, g: 59, b: 94)
            self.label!.font = UIFont.boldSystemFont(ofSize: 16)
            self.lineView!.isHidden = false
        }else{
            self.lineView!.isHidden = true
            self.label!.textColor = UIColor.white
            self.label!.font = UIFont.systemFont(ofSize: 16)
        }
    }
    
    @objc private func touchedBtn() {
        self.delegate?.onTouchTab(at: self.index)
    }
}

//首页伴奏/作品类型标签View
class TabView :UIView, TabViewDelegate{
    
    var delegate:TabViewDelegate
    private var leftTab:TabItemView?
    private var rightTab:TabItemView?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(dellegate:TabViewDelegate) {
        self.delegate = dellegate
        let w:CGFloat = 170
        super.init(frame: CGRect(x: (UIScreen.main.bounds.width - w) / 2, y:0, width: w, height: 60))
        leftTab = TabItemView(frame: CGRect(x: 0, y: 0, width: 60, height: self.bounds.height), name: "伴奏", index: 0)
        leftTab!.delegate = self
        self.addSubview(leftTab!)
        leftTab!.setFocus(true)
        
        rightTab = TabItemView(frame: CGRect(x: leftTab!.frame.maxX + 50, y: 0, width: 60, height: self.bounds.height), name: "作品", index: 1)
        rightTab!.delegate = self
        self.addSubview(rightTab!)
    }
    
    func onTouchTab(at index:Int) {
        self.setCurrTab(at: index)
        self.delegate.onTouchTab(at: index)
    }
    
    func setCurrTab(at index:Int) {
        leftTab!.setFocus(index == 0)
        rightTab!.setFocus(index == 1)
    }
    
}

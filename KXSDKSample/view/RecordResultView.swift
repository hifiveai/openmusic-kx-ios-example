//
//  RecordResultView.swift
//  KXSDKSample
//  演唱结果View
//  Created by 李刚 on 2022/5/12.
//

import UIKit


class ResultScoreLine: UIView {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame:CGRect, title:String, score:Float, startColor:UIColor, endColor:UIColor, percent:Bool){
        super.init(frame: frame)
        let h_h = self.bounds.height / 2
        self.backgroundColor = UIColor.rgba(r: 73, g: 72, b: 72, a: 0.26)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = h_h
        
        let lineView = UIView(frame:CGRect(x: 0, y: 0, width: self.bounds.width * CGFloat(score) / 100 , height: self.bounds.height))
        lineView.layer.masksToBounds = true
        lineView.layer.cornerRadius = h_h
        self.addSubview(lineView)
        
        let titleLbl = UILabel()
        titleLbl.textColor = UIColor.white
        titleLbl.text = title
        titleLbl.font = UIFont.systemFont(ofSize: 11)
        titleLbl.textAlignment = .center
        titleLbl.sizeToFit()
        titleLbl.frame = CGRect(x: h_h, y: 0, width: titleLbl.bounds.width, height: self.bounds.height)
        self.addSubview(titleLbl)
    
        let scoreLbl = UILabel()
        scoreLbl.textColor = UIColor.white
        if percent {
            scoreLbl.text = Utils.shared.percentString(NSNumber(value: score))
        }else{
            scoreLbl.text = "\(Int(score))"
        }
        scoreLbl.font = UIFont.systemFont(ofSize: 11)
        scoreLbl.textAlignment = .center
        scoreLbl.sizeToFit()
        scoreLbl.frame = CGRect(x: self.bounds.width - h_h - scoreLbl.bounds.width, y: 0, width: scoreLbl.bounds.width, height: self.bounds.height)
        self.addSubview(scoreLbl)
        
        let limit_w = titleLbl.bounds.width + scoreLbl.bounds.width + self.bounds.height
        if lineView.bounds.width >= limit_w {
            var sFrame = scoreLbl.frame
            sFrame.origin.x = lineView.bounds.width - sFrame.width - h_h
            scoreLbl.frame = sFrame
        }else{
            lineView.frame = CGRect(x: 0, y: 0, width: limit_w, height: self.bounds.height)
            scoreLbl.frame = CGRect(x: titleLbl.frame.maxX, y: 0, width: scoreLbl.bounds.width, height: self.bounds.height)
        }
        self.gradientColor(lineView, startColor: startColor, endColor: endColor)
    }
    
    private func gradientColor(_ view:UIView, startColor:UIColor, endColor:UIColor) {
        let g_layer = CAGradientLayer()
        g_layer.colors = [startColor.cgColor, endColor.cgColor]
        g_layer.locations = [0, 1]
        g_layer.startPoint = CGPoint(x: 0, y: 0)
        g_layer.endPoint = CGPoint(x: 1, y: 0)
        g_layer.frame = view.layer.bounds
        g_layer.masksToBounds = true
        g_layer.cornerRadius = view.bounds.height / 2
        view.layer.insertSublayer(g_layer, at: 0)
        view.setNeedsLayout()
    }
}

class RecordResultView:UIView {
    
    private var block:ActionBlock
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(minScore:Float, maxScore:Float, totalScore:Float, progress:Float, closeBlock:@escaping ActionBlock) {
        self.block = closeBlock
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.backgroundColor = UIColor.rgba(r: 0, g: 0, b: 0, a: 0.61)
        
        let bgView = UIView(frame: CGRect(x: 30, y: 0, width: self.bounds.width - 60, height: 230))
        bgView.backgroundColor = UIColor.rgb(r: 87, g: 37, b: 45)
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 18
        bgView.center = self.center
        self.addSubview(bgView)
        
        let titleLbl = UILabel()
        titleLbl.text = "演唱得分"
        titleLbl.textColor = UIColor.white
        titleLbl.font = UIFont.boldSystemFont(ofSize: 14)
        titleLbl.textAlignment = .center
        bgView.addSubview(titleLbl)
        titleLbl.sizeToFit()
        titleLbl.frame = CGRect(x: (bgView.bounds.width - titleLbl.frame.width) / 2 , y: 25, width: titleLbl.bounds.width, height: titleLbl.bounds.height)
        
        let scoreLbl = UILabel()
        scoreLbl.text = "\(Int(totalScore))"
        scoreLbl.textColor = UIColor.white
        scoreLbl.font = UIFont.boldSystemFont(ofSize: 28)
        scoreLbl.textAlignment = .center
        bgView.addSubview(scoreLbl)
        scoreLbl.sizeToFit()
        scoreLbl.frame = CGRect(x: (bgView.bounds.width - scoreLbl.frame.width) / 2 , y: titleLbl.frame.maxY + 8, width: scoreLbl.bounds.width, height: scoreLbl.bounds.height)
        let line_w:CGFloat = bgView.bounds.width - 68
        let line_h:CGFloat = 20
        
        let maxScoreLine = ResultScoreLine(frame: CGRect(x: 34, y: scoreLbl.frame.maxY + 25, width: line_w, height: line_h), title: "最高单句得分：", score: maxScore, startColor:UIColor.rgb(r: 250, g: 69, b: 102), endColor: UIColor.rgb(r: 247, g: 112, b: 137), percent: false)
        bgView.addSubview(maxScoreLine)
        
        let minScoreLine = ResultScoreLine(frame: CGRect(x: 34, y: maxScoreLine.frame.maxY + 12, width: line_w, height: line_h), title: "最低单句得分：", score: minScore, startColor:UIColor.rgb(r: 60, g: 97, b: 232), endColor: UIColor.rgb(r: 96, g: 193, b: 249), percent: false)
        bgView.addSubview(minScoreLine)
        
        
        let progressLine = ResultScoreLine(frame: CGRect(x: 34, y: minScoreLine.frame.maxY + 12, width: line_w, height: line_h), title: "完成度：", score: progress, startColor: UIColor.rgb(r: 123, g: 49, b: 230), endColor:UIColor.rgb(r: 173, g: 118, b: 251), percent: true)
        bgView.addSubview(progressLine)
        
        var frame = bgView.frame
        frame.size.height = progressLine.frame.maxY + 20
        frame.origin.y = (self.bounds.height - frame.height - 50) / 2
        bgView.frame = frame
        
        let btn_w = 34.0
        let closeBtn = UIButton(type: .custom)
        closeBtn.frame = CGRect(x: (self.bounds.width - btn_w) / 2.0, y: bgView.frame.maxY + 16.0, width: btn_w, height: btn_w)
        closeBtn.setImage(UIImage(named: "close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.addSubview(closeBtn)
    }
    
    
    
    init(progress:Float, closeBlock:@escaping ActionBlock) {
        self.block = closeBlock
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.backgroundColor = UIColor.rgba(r: 0, g: 0, b: 0, a: 0.61)
        
        let bgView = UIView(frame: CGRect(x: 30, y: 0, width: self.bounds.width - 60, height: 230))
        bgView.backgroundColor = UIColor.rgb(r: 87, g: 37, b: 45)
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 18
        bgView.center = self.center
        self.addSubview(bgView)
        
        let titleLbl = UILabel()
        titleLbl.text = "演唱完成"
        titleLbl.textColor = UIColor.white
        titleLbl.font = UIFont.boldSystemFont(ofSize: 28)
        titleLbl.textAlignment = .center
        bgView.addSubview(titleLbl)
        titleLbl.sizeToFit()
        titleLbl.frame = CGRect(x: (bgView.bounds.width - titleLbl.frame.width) / 2 , y: 30, width: titleLbl.bounds.width, height: titleLbl.bounds.height)
        
        
        let line_w:CGFloat = bgView.bounds.width - 68
        let line_h:CGFloat = 20
        
        let progressLine = ResultScoreLine(frame: CGRect(x: 34, y: titleLbl.frame.maxY + 30, width: line_w, height: line_h), title: "完成度：", score: progress, startColor: UIColor.rgb(r: 123, g: 49, b: 230), endColor:UIColor.rgb(r: 173, g: 118, b: 251) , percent: true)
        bgView.addSubview(progressLine)
        
        var frame = bgView.frame
        frame.size.height = progressLine.frame.maxY + 30
        frame.origin.y = (self.bounds.height - frame.height - 50) / 2
        bgView.frame = frame
        
        let btn_w = 34.0
        let closeBtn = UIButton(type: .custom)
        closeBtn.frame = CGRect(x: (self.bounds.width - btn_w) / 2.0, y: bgView.frame.maxY + 16.0, width: btn_w, height: btn_w)
        closeBtn.setImage(UIImage(named: "close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.addSubview(closeBtn)
    }
    
    @objc private func close() {
        self.block()
    }
}

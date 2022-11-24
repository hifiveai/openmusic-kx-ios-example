//
//  TuningSettingsView.swift
//  KXSDKSample
//  调音面板View
//  Created by 李刚 on 2022/4/18.
//

import UIKit

typealias TuningValueChangedBlock = (Float) -> Void


enum TuningSettingType:String {
    case accompVolume = "伴奏", accompKeyValue = "音调", recordVolume = "人声", reverbValue = "美声", eqValue = "音色"
}


class TuningSettingsCell:UIView {
    
    private var type:TuningSettingType
    private var block:TuningValueChangedBlock
    private var slider:UISlider?
    private var valueLabel:UILabel?
    private var tipsLabel:UILabel?
    private var valueLabelView:UIView?
    private var keyLabel:UILabel?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(type:TuningSettingType, min:Float, max:Float, y:CGFloat, width:CGFloat, block:@escaping TuningValueChangedBlock){
        self.type = type
        self.block = block
        super.init(frame: CGRect(x: 16, y: y, width: width, height: 44))
        
        let titleLbl = UILabel()
        titleLbl.text = type.rawValue
        titleLbl.font = UIFont.systemFont(ofSize: 13)
        titleLbl.textColor = UIColor.white
        self.addSubview(titleLbl)
        titleLbl.sizeToFit()
        titleLbl.frame = CGRect(x: 0, y: (self.bounds.height - titleLbl.bounds.height) / 2, width: titleLbl.bounds.width, height: titleLbl.bounds.height)
        
        valueLabel = UILabel()
        valueLabel!.text = Utils.shared.percentString(NSNumber(value:0.0))
        valueLabel!.font = UIFont.systemFont(ofSize: 11)
        valueLabel!.textColor = UIColor.white
        valueLabel!.textAlignment = .right
        self.addSubview(valueLabel!)
        valueLabel!.sizeToFit()
        valueLabel!.frame = CGRect(x: self.bounds.width - 32, y: (self.bounds.height - valueLabel!.bounds.height) / 2, width: 32, height: valueLabel!.bounds.height)
        
        let sliderW = (type == .accompKeyValue || type == .eqValue) ? (valueLabel!.frame.maxX - 8 - titleLbl.frame.maxX) : (valueLabel!.frame.minX - 8 - titleLbl.frame.maxX)
        
        slider = UISlider(frame: CGRect(x: titleLbl.frame.maxX + 8, y: 11, width:sliderW, height: 22))
        slider!.minimumValue = min
        slider!.maximumValue = max
        slider!.value = 0
        slider!.isContinuous = false
        slider!.setThumbImage(UIImage(named: "slider_track"), for: .normal)
        slider!.contentMode = .scaleAspectFit
        slider!.minimumTrackTintColor = UIColor.rgb(r: 242, g: 50, b: 81)
        slider!.maximumTrackTintColor = UIColor.rgb(r: 165, g: 165, b: 165)
        slider!.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        self.addSubview(slider!)
        
        let tipsW = valueLabel!.frame.maxX - 8 - titleLbl.frame.maxX
        tipsLabel = UILabel(frame: CGRect(x: slider!.frame.minX, y: slider!.frame.minY, width: tipsW, height: slider!.frame.height))
        tipsLabel!.text = type.rawValue + "已关闭，如需开启请插入耳机"
        tipsLabel!.font = UIFont.systemFont(ofSize: 11)
        tipsLabel!.textColor = UIColor.rgba(r: 255, g: 255, b: 255, a: 0.6)
        tipsLabel!.textAlignment = .center
        self.addSubview(tipsLabel!)
        tipsLabel!.isHidden = true
        if(type == .accompKeyValue || type == .eqValue){
            //音调：-5 ~ 5
            //音色：深厚 ~ 清亮(-1 ~ 1) 50 ~ 50
            valueLabelView = UIView(frame:CGRect(x: slider!.frame.minX, y: 0, width: slider!.bounds.width, height: 12))
            self.addSubview(valueLabelView!)
            let l_text = type == .accompKeyValue ? String.localizedStringWithFormat("%.0f", min) : "深厚"
            let lLbl = self.createValueLabel(text: l_text, posType: 0)
            valueLabelView!.addSubview(lLbl)
            let valStr = String.localizedStringWithFormat("%.0f", (max + min) / 2)
            self.keyLabel = self.createValueLabel(text: valStr, posType: 1)
            valueLabelView!.addSubview(self.keyLabel!)
            let r_text = type == .accompKeyValue ? String.localizedStringWithFormat("%.0f", max) : "清亮"
            let rLbl = self.createValueLabel(text: r_text, posType: 2)
            valueLabelView!.addSubview(rLbl)
            valueLabel!.isHidden = true
        }
    }
    
    
    private func createValueLabel(text:String, posType:Int) -> UILabel {
        let width = self.valueLabelView!.bounds.width
        let lLbl = UILabel()
        lLbl.text = text
        lLbl.textColor = UIColor.white
        lLbl.font = UIFont.systemFont(ofSize: 10)
        lLbl.sizeToFit()
        if posType == 0 {
            lLbl.frame = CGRect(x: 0, y: 0, width: lLbl.bounds.width, height: lLbl.bounds.height)
        } else if posType == 1 {
            lLbl.frame = CGRect(x: (width - 20) / 2, y: 0, width: 20, height: lLbl.bounds.height)
            lLbl.textAlignment = .center
        }else if posType == 2 {
            lLbl.frame = CGRect(x: width - lLbl.bounds.width, y: 0, width: lLbl.bounds.width, height: lLbl.bounds.height)
        }
        return lLbl
    }
    
    private func updateValueLabel(_ value:Float) {
        switch self.type {
        case .accompKeyValue, .eqValue:
            self.keyLabel?.text = String.localizedStringWithFormat("%.0f", value)
            break
        default:
            valueLabel!.text = Utils.shared.percentString(NSNumber(value:value))
            break
        }
    }
    
    func setOn(_ isOn:Bool){
        
        slider!.isHidden = !isOn
        if type == .reverbValue {
            valueLabelView?.isHidden = !isOn
            valueLabel!.isHidden = !isOn
        }else if type == .eqValue{
            valueLabelView?.isHidden = !isOn
        }else{
            valueLabel!.isHidden = !isOn
        }
        tipsLabel!.isHidden = isOn
    }
    
    func setValue(_ value:Float){
        if tipsLabel!.isHidden {
            self.updateValueLabel(value)
            slider!.setValue(value, animated: true)
        }
    }
    
    
    @objc func sliderValueChanged() {
        guard let slider = self.slider else {
            return
        }
        var _value = slider.value
        switch self.type {
        case .accompKeyValue:
            let temp = Int(_value * 10)
            self.updateValueLabel(Float(temp))
            _value = Float(temp) / 10.0
            slider.value = _value
            break
        case  .eqValue:
            let temp = Int(_value * 50)
            self.updateValueLabel(Float(abs(temp)))
            _value = Float(temp) / 50.0
            slider.value = _value
            break;
        default:
            self.updateValueLabel(_value)
            break
        }
        self.block(_value)
    }
}

protocol TuningSettingsViewDelegate:NSObjectProtocol {
    func onVolumeChanged(type:TuningSettingType, value:Float)
    func onTuningSettingViewClose()
}

class TuningSettingsView: UIView {

    var delegate:TuningSettingsViewDelegate
    
    private var accompCell:TuningSettingsCell?
    private var accompKeyCell:TuningSettingsCell?
    private var recordCell:TuningSettingsCell?
    private var reverbCell:TuningSettingsCell?
    private var eqCell:TuningSettingsCell?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(playback:Bool, delegate:TuningSettingsViewDelegate){
        self.delegate = delegate
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        self.backgroundColor = UIColor.rgba(r: 0, g: 0, b: 0, a: 0.45)
        
        
        let btn = UIButton(type: .custom)
        btn.frame = self.bounds
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.addSubview(btn)
        
        let bgView = UIView(frame: CGRect(x: 30, y: 0, width: UIScreen.main.bounds.width - 60, height: UIScreen.main.bounds.height))
        bgView.backgroundColor = UIColor.black
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 16
        bgView.layer.borderColor = UIColor.rgba(r: 242, g: 78, b: 105, a: 0.3).cgColor
        bgView.layer.borderWidth = 1
        self.addSubview(bgView)
        
        var y:CGFloat = 16
        let w:CGFloat = bgView.bounds.width - 32
        accompCell = TuningSettingsCell(type: .accompVolume, min: 0.0, max: 1.0,y: y, width: w, block: { value in
            self.delegate.onVolumeChanged(type: .accompVolume, value: value)
        })
        bgView.addSubview(accompCell!)
        y += accompCell!.bounds.height
        
        recordCell = TuningSettingsCell(type: .recordVolume, min: 0.0, max: 1.0,y: y, width: w, block: { value in
            self.delegate.onVolumeChanged(type: .recordVolume, value: value)
        })
        bgView.addSubview(recordCell!)
        y += recordCell!.bounds.height
        
        
        reverbCell = TuningSettingsCell(type: .reverbValue, min: 0.0, max: 1.0,y: y, width: w, block: { value in
            self.delegate.onVolumeChanged(type: .reverbValue, value: value)
        })
        bgView.addSubview(reverbCell!)
        y += reverbCell!.bounds.height
        
        if !playback {
            accompKeyCell = TuningSettingsCell(type: .accompKeyValue, min: -5.0, max: 5.0,y: y, width: w, block: { value in
                self.delegate.onVolumeChanged(type: .accompKeyValue, value: value)
            })
            bgView.addSubview(accompKeyCell!)
            y += accompKeyCell!.bounds.height
        }
        
        
        eqCell = TuningSettingsCell(type: .eqValue, min: -1.0, max: 1.0,y: y, width: w, block: { value in
            self.delegate.onVolumeChanged(type: .eqValue, value: value)
        })
        bgView.addSubview(eqCell!)
        y += eqCell!.bounds.height
        
        y += 16
        let h = y
        y = (UIScreen.main.bounds.height - h) / 2
        
        let _frame = CGRect(x: bgView.frame.minX, y: y, width: bgView.bounds.width, height: h)
        bgView.frame = _frame
        
    }
    
    func setValue(_ value:Float, for type:TuningSettingType) {
        switch type {
        case .accompVolume:
            self.accompCell?.setValue(value)
            break
        case .accompKeyValue:
            self.accompKeyCell?.setValue(value)
            break
        case .recordVolume:
            self.recordCell?.setValue(value)
            break
        case .reverbValue:
            self.reverbCell?.setValue(value)
            break
        case .eqValue:
            self.eqCell?.setValue(value)
            break
        }
    }
    
    func audioRouteChanged(plugIn:Bool){
        
        self.reverbCell?.setOn(plugIn)
        self.eqCell?.setOn(plugIn)
    }
    
    @objc private func close(){
        self.delegate.onTuningSettingViewClose()
    }
}

class ProgressView: UIView {
    
    private var progress:UIProgressView?
    private var progressLbl:UILabel?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(){
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.backgroundColor = UIColor.rgba(r: 33, g: 33, b: 33, a: 0.2)
        let btn = UIButton(type: .custom)
        btn.frame = self.bounds
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        self.addSubview(btn)
        
        progress = UIProgressView(progressViewStyle: UIProgressView.Style.default)
        progress!.frame = CGRect(x: 35, y: self.bounds.height / 2 - 30, width: self.bounds.width - 70, height: 30)
        progress!.trackTintColor = UIColor.gray
        progress!.progressTintColor = UIColor.rgb(r: 242, g: 50, b: 81)
        progress!.progress = 0
        
        self.addSubview(progress!)
        progressLbl = UILabel()
        progressLbl!.text = Utils.shared.percentString(NSNumber(value: 0))
        progressLbl!.textColor = UIColor.init(white: 0.8, alpha: 0.8)
        progressLbl!.font = UIFont.systemFont(ofSize: 12)
        progressLbl?.center = CGPoint(x: progress!.center.x, y: progress!.frame.minX - progressLbl!.bounds.height)
        self.addSubview(progressLbl!)
    }
    
    @objc private func btnAction() {
    }
    
    func setProgress(_ progress:Float, text:String) {
        self.progress!.progress = progress
        self.progressLbl!.text = text + Utils.shared.percentString(NSNumber(value: progress))
    }
}

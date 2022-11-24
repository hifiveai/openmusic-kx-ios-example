//
//  Utils.swift
//  KXSDKSample
//
//  Created by 李刚 on 2022/3/22.
//

import Foundation
import AVFoundation
import UIKit
import CommonCrypto

 //工具类
class Utils: NSObject {
    static let shared = Utils()
    //根路径
    private var rootPath:String!
    //作品记录文件路径
    private let _worksPath:String = String(format: "%@/Documents/my_works", NSHomeDirectory())
    
    //作品记录文件路径
    var worksFilePath:String {
        get {
            return _worksPath
        }
    }
    
    private override init() {
        super.init()
        rootPath = self.shareFileRoot()
    }
    //获取项目路径
    private func shareFileRoot() ->String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    //获取下载路径
    func cachedFilePath(_ fileName:String) -> String {
        return String(format: "%@/Documents/%@", NSHomeDirectory(),fileName)
    }
    
    //作品文件名
    func recordFileName(_ songId:String) ->String {
        return String(format: "%@_%@.wav", songId, currDateTimeStr())
    }
    //内置资源文件路径
    func resourcePath(_ name:String) -> String{
        return Bundle.main.path(forResource: name, ofType: "") ?? ""
    }
    
    
    
    func log(_ log:String) {
        print(log)
    }
    
    //耳机是否插入，如果已插入返回true，否则返回false
    func headsetIsPluggedIn() -> Bool {
        let route = AVAudioSession.sharedInstance().currentRoute
        for desc in route.outputs {
            if desc.portType == .headphones {
                return true
            }
        }
        return false
    }
    
    func currDateTimeStr() -> String{
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd_hhmmss"
        return df.string(from: Date())
    }
    
    //时间转换为String(00:00)，time单位:秒
    func formatTime(_ time:Float) -> String {
        let date  =  Date.init(timeIntervalSince1970: TimeInterval(time))
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        return formatter.string(from: date)
    }
    //数字转换为百分数字符串
    func percentString(_ num:NSNumber) -> String {
        let res = NumberFormatter.localizedString(from: num, number: .percent)
        return res
    }
    
    //错误提示框
    static func alert(_ errStr:String, vc:UIViewController) {
        let alert = UIAlertController(title: "出错啦！", message: errStr, preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alert.addAction(ok)
        vc.present(alert, animated: true, completion: nil)
    }
}
//HIFIVE API接口加密用
enum CryptoAlgorithm {
    /// 加密的枚举选项
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        case .SHA224:   result = kCCHmacAlgSHA224
        case .SHA256:   result = kCCHmacAlgSHA256
        case .SHA384:   result = kCCHmacAlgSHA384
        case .SHA512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}


extension String
{
    //路径拼接
    func appendingPathComponent(_ file:String) ->String{
        let nsStr = self as NSString
        return nsStr.appendingPathComponent(file)
    }
    
    /*
     *   func：加密方法
     *   参数1：加密方式； 参数2：加密的key
     */
    func hmacToBytes(algorithm: CryptoAlgorithm, key: String) -> Data {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        
        let digest = Data(bytes: result, count: digestLen)
        
        result.deallocate()
        
        return digest
    }
    
}

extension UIView
{
    //移除所有子View
    func removeAllSubviews() {
        for sub in self.subviews {
            sub.removeFromSuperview()
        }
    }
}

extension UIColor {
    static func rgb(r:Int, g:Int, b:Int) ->UIColor{
        self.rgba(r: r, g: g, b: b, a: 1.0)
    }
    static func rgba(r:Int, g:Int, b:Int, a:CGFloat) ->UIColor {
        var red = r
        if(red < 0 || red > 255){
            red = 255
        }
        var green = g
        if(green < 0 || green > 255){
            green = 255
        }
        var blue = b
        if(blue < 0 || blue > 255){
            blue = 255
        }
        var alp = a
        if(alp < 0 || alp > 1.0) {
            alp = 1.0
        }
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alp)
    }
}

extension Data {
    /// json->Data
    init?(json:Any) {
        if JSONSerialization.isValidJSONObject(json),let data = try? JSONSerialization.data(withJSONObject: json) {
            self.init(data)
        }else {
            return nil
        }
    }
    
    /// read data
    init?(path:String) {
        let url = URL(fileURLWithPath: path)
        do {
            try self.init(contentsOf: url, options: .alwaysMapped)
        }catch {
            return nil
        }
    }
    //转换为16进制字符
    func hexStr() -> String {
        var t = ""
        let ts = [UInt8](self)
        for i in 0..<ts.count {
            t.append(String(format: "%02X", arguments: [ts[i]]))
        }
        return t
    }
    //md5加密
    func md5() -> Data {
        let md5len = Int(CC_MD5_DIGEST_LENGTH)
        let unsafe = [UInt8](self)
        let mb = UnsafeMutablePointer<UInt8>.allocate(capacity: md5len)
        CC_MD5(unsafe, CC_LONG(unsafe.count), mb)
        mb.deallocate()
        let digest = Data(bytes: mb, count: md5len)
        return digest
    }
}

extension Date {

    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
}

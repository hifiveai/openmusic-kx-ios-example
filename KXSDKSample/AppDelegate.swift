//
//  AppDelegate.swift
//  KXSDKSample
//
//  Created by 李刚 on 2022/3/21.
//

import UIKit
import KXKTVSDK
import HFOpenApi

//tabbar底部安全区高度
var kSafeAreaBottomH : CGFloat = 0

//HIFIVE API AppId
let AppId = "3faeec81030444e98acf6af9ba32752a"
//HIFIVE API ServerCode
let ServerCode = "59b1aff189b3474398"

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        KXKTVSDKManager.getInstance().setDebugMode(true)
        KXKTVSDKManager.getInstance().initEngine(AppId) { state in
            print(String(format: "KXKTVSDKManager init state:%d", state))
        }
        HFOpenApiManager.shared().registerApp(withAppId: AppId, serverCode: ServerCode, clientId: "1", version: "V4.1.4") { res in
            print("HFOpenApiManager 注册成功！ res:\(res ?? "")")
        } fail: { err in
            if(err != nil) {
                print(String(format: "HFOpenApiManager 注册失败 err:%@", err!.localizedDescription))
            }else{
                print("HFOpenApiManager 注册失败！")
            }
        }
        return true
    }
    
    
    private func registerHFOpenApiUser() {
        HFOpenApiManager.shared().baseLogin(withNickname: "kxsample", gender: nil, birthday: nil, location: nil, education: nil, profession: nil, isOrganization: false, reserve: nil, favoriteSinger: nil, favoriteGenre: nil) { res in
            print(String(format: "HFOpenApiManager baseLogin 注册成功！ res:\(res ?? "")"))
        } fail: { err in
            if(err != nil) {
                print(String(format: "HFOpenApiManager baseLogin 注册失败 err:%@", err!.localizedDescription))
            }else{
                print("HFOpenApiManager baseLogin 注册失败！")
            }
        }
//        HFOpenApiManager.shared().baseLogin(withNickname: "kxsample", gender: nil, birthday: "1594639058", location: "30.779164,103.94547", education: "0", profession: "0", isOrganization: false, reserve: "{\"language\":\"Chinese\"}", favoriteSinger: "Queen,The Beatles", favoriteGenre: "7,8,10") { res in
//            print(String(format: "HFOpenApiManager baseLogin 注册成功！ res:\(res)"))
//        } fail: { err in
//            if(err != nil) {
//                print(String(format: "HFOpenApiManager baseLogin 注册失败 err:%@", err!.localizedDescription))
//            }else{
//                print("HFOpenApiManager baseLogin 注册失败！")
//            }
//        }

    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


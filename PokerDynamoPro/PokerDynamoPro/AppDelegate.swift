//
//  AppDelegate.swift
//  PokerDynamoPro
//
//  Created by jin fu on 2025/3/10.
//

import UIKit

var arrHistory: [Data] = []{
    didSet{
        UserDefaults.standard.setValue(arrHistory, forKey: "hist")
    }
}
var score: Int = 0{
    didSet{
        UserDefaults.standard.setValue(score, forKey: "score")
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let h = UserDefaults.standard.value(forKey: "hist")as? [Data]{
            arrHistory = h
        }
        
        if let s = UserDefaults.standard.value(forKey: "score")as? Int{
            score = s
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


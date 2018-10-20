//
//  AppDelegate.swift
//  ExampleRedBearChat
//
//  Created by Eric Larson on 9/26/17.
//  Copyright © 2017 Eric Larson. All rights reserved.
//

let kBleConnectNotification = "bleDidConnect"
let kBleDisconnectNotification = "bleDidDisconnect"
let kBleReceivedDataNotification = "bleReceievedData"

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BLEDelegate {
    
    var bleShield = BLE()
    
    // MARK: ====== BLE Delegates Functions ======
    func bleDidUpdateState() {
        // currently unused
    }
    
    func bleDidConnectToPeripheral() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kBleConnectNotification),
                                        object: self,
                                        userInfo:["name":self.bleShield.activePeripheral?.name! as Any])
    }
    
    func bleDidDisconnectFromPeripheral() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kBleDisconnectNotification), object: self)
    }
    
    func bleDidReceiveData(data: Data?) {
        if let dataSafe = data{
            print(dataSafe)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kBleReceivedDataNotification),
                                            object: self,
                                            userInfo:["data":dataSafe])
        }
    }
    
    // MARK: ====== App Delegate Functions ======
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.bleShield.delegate = self
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


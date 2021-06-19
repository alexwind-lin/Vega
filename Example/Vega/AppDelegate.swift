//
//  AppDelegate.swift
//  Vega
//
//  Created by leon503@163.com on 05/09/2021.
//  Copyright (c) 2021 leon503@163.com. All rights reserved.
//

import UIKit
import Vega

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        buildSimpleVega()
        requestHitoKoto()

        buildComplexVega()
        customExample()
        
        return true
    }
    
    private func buildSimpleVega() {
        Vega.builder().build()
    }
    
    private func buildComplexVega() {
        Vega.builder("FakeOne")
            .setBaseURL("https://hahahahahaha.com")
            .addRequestInterceptor(FakeRequestInterceptor())
            .addResponseInterceptor(FakeResponseInterceptor())
            .setHTTPClient(FakeHTTPClient())
            .setConverter(CustomDataConverter())
            .build()        
    }
    
    private func requestAppleRepositories() {
        GitHubAPI.appleRepositories.request { (result) in
            switch result {
            case .failure(let error):
                break
            case .success(let list):
                break
            }
        }
    }
    
    private func requestHitoKoto() {
        HitokotoAPI.hitokoto.request("d") { (result) in
            print(result)
        }
    }
    
    private func customExample() {
        let dict = [
            "hello": "world"
        ]
        FakeHitoKotoAPI.fakeHitoKoto.request(dict) { (result) in
            print(result)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


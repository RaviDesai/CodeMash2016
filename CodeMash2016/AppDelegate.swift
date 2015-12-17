//
//  AppDelegate.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/23/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import RSDRESTServices

protocol ApplicationMockLoginProtocol {
    var validLogin: LoginParameters? { get }
    func logoff()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ApplicationMockLoginProtocol {

    var window: UIWindow?
    var mockedRest: MockedRESTCalls?
    var site = LoginViewModel.site
    var validLogin: LoginParameters?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let arguments = NSProcessInfo.processInfo().arguments
        let mockData = arguments.contains("--mockdata") || true
        if (mockData) {
            let initialUsers = [
                User(id: NSUUID(), name: "One", password: "pass", emailAddress: EmailAddress(user: "one", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberOne")),
                User(id: NSUUID(), name: "Two", password: "pass", emailAddress: EmailAddress(user: "two", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberTwo")),
                User(id: NSUUID(), name: "Three", password: "pass", emailAddress: EmailAddress(user: "three", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberThree")),
                User(id: NSUUID(), name: "Four", password: "pass", emailAddress: EmailAddress(user: "four", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberFour")),
                User(id: NSUUID(), name: "Admin", password: "admin", emailAddress: EmailAddress(user: "ravidesai", host: "me.com", displayValue: nil), image: nil)
            ]
            
            let initialGames = [
                Game(id: NSUUID(), title: "Glorantha", owner: initialUsers[4], users: [initialUsers[0], initialUsers[1]]),
                Game(id: NSUUID(), title: "Darkmoon", owner: initialUsers[1], users: [initialUsers[2], initialUsers[3]])
            ]
            
            Client.sharedClient.setSite(self.site, authenticated: false)
            validLogin = LoginParameters(username: "Admin", password: "admin")
            self.mockedRest = MockedRESTCalls(site: self.site, initialUsers: initialUsers, initialGames: initialGames, initialMessages: [])
            self.mockedRest?.hijackAll()
        }
        
        let noanimations = arguments.contains("--noanimations")
        if (noanimations) {
            UIView.setAnimationsEnabled(false)
        }
        
        return true
    }

    func logoff() {
        self.mockedRest?.loginStore?.logoff()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


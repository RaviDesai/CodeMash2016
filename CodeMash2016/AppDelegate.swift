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
        let mockData = arguments.contains("--mockdata")
        if (mockData) {
            let initialUsers = [
                User(id: NSUUID(), name: "One", password: "pass", emailAddress: EmailAddress(user: "one", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberOne")),
                User(id: NSUUID(), name: "Two", password: "pass", emailAddress: EmailAddress(user: "two", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberTwo")),
                User(id: NSUUID(), name: "Three", password: "pass", emailAddress: EmailAddress(user: "three", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberThree")),
                User(id: NSUUID(), name: "Four", password: "pass", emailAddress: EmailAddress(user: "four", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberFour")),
                User(id: NSUUID(), name: "Admin", password: "admin", emailAddress: EmailAddress(user: "ravidesai", host: "me.com"), image: nil)
            ]
            
            let initialGames = [
                Game(id: NSUUID(), title: "Glorantha", owner: initialUsers[4].id!, users: [initialUsers[0].id!, initialUsers[1].id!]),
                Game(id: NSUUID(), title: "Darkmoon", owner: initialUsers[1].id!, users: [initialUsers[2].id!, initialUsers[3].id!])
            ]
            
            let initialMessages = [
                Message(id: NSUUID(), from: initialUsers[0].id!, to: nil, game: initialGames[0].id!, subject: "King of Sartar", message: "avoiding death at all costs", date: NSDate()),
                Message(id: NSUUID(), from: initialUsers[1].id!, to: nil, game: initialGames[0].id!, subject: "Re: King of Sartar", message: "death comes to all", date: NSDate())
            ]
            
            Client.sharedClient.setSite(self.site, authenticated: false)
            validLogin = LoginParameters(username: "Admin", password: "admin")
            self.mockedRest = MockedRESTCalls(site: self.site, initialUsers: initialUsers, initialGames: initialGames, initialMessages: initialMessages)
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
        Client.sharedClient.setSite(self.site, authenticated: false)
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


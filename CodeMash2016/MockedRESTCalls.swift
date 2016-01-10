//
//  File.swift
//  RSDTesting
//
//  Created by Ravi Desai on 10/25/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import RSDRESTServices
import RSDSerialization
import OHHTTPStubs

protocol UsersStore {
    var store: [User] { get }
}

protocol GamesStore {
    var store: [Game] { get }
}

protocol MessageStore {
    var store: [Message] { get }
}

class MockedRESTLogin {
    var host: String?
    var site: APISite
    var userStore: UsersStore
    var loggedInUser: User?
    var userLoginChange: (User?)->()
    
    private var authStub: OHHTTPStubsDescriptor?
    private var tokenStub: OHHTTPStubsDescriptor?
    private var postStub: OHHTTPStubsDescriptor?

    
    init(site: APISite, usersStore: UsersStore, userLoginChange: (User?)->()) {
        self.site = site
        self.userStore = usersStore
        self.loggedInUser = nil
        self.userLoginChange = userLoginChange
    }
    
    func logoff() {
        self.loggedInUser = nil
        userLoginChange(nil)
    }
    
    private static func sampleAuthenticateData(userId: NSUUID) -> NSData {
        let response = LoginResponse(success: true, message: userId.UUIDString, token: LoginToken(id: "wsignin1.0", token: "<crazyweirdxml></crazyweirdxml>")).convertToJSON()
        
        return try! NSJSONSerialization.dataWithJSONObject(response, options: NSJSONWritingOptions.PrettyPrinted)
    }
    
    private static func sampleAuthenticationTokenData() -> NSData {
        return "\"success\"".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }

    private func hijackLoginSequence(loginSite: APISite, usersStore: UsersStore) {
        self.host = loginSite.uri?.host
        
        self.authStub =
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != self.host) {
                return false
            }
            if (request.URL?.path != .Some("/api/authentication/authenticate")) {
                return false
            }
            if (request.HTTPMethod != "POST") {
                return false
            }
            let requestData = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData
            if (requestData == nil) {
                return false
            }
            
            return true
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
            if let requestData = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData {
                if let json = try? NSJSONSerialization.JSONObjectWithData(requestData, options: NSJSONReadingOptions.AllowFragments) {
                    if let login = LoginParameters.createFromJSON(json) {
                        if let foundUser = self.userStore.store.filter({ $0.name.lowercaseString == login.username.lowercaseString && $0.password == login.password }).first {
                            if let loggedInUserId = foundUser.id {
                                self.userLoginChange(foundUser)
                                let response = MockedRESTLogin.sampleAuthenticateData(loggedInUserId)
                                return OHHTTPStubsResponse(data: response, statusCode: 200, headers: ["Content-Type": "application/json"])
                            }
                        }
                    }
                }
            }
            return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 401, headers: nil)
        })
        
        self.tokenStub =
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != self.host) {
                return false
            }
            if (request.URL?.path != .Some("/api/authentication/authenticationtoken")) {
                return false
            }
            if (request.HTTPMethod != "POST") {
                return false
            }
            let contentType = request.allHTTPHeaderFields?["Content-Type"]
            if (contentType != .Some("application/x-www-form-urlencoded")) {
                return false
            }
            let requestData = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData
            if (requestData == nil) {
                return false
            }
            return true
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                let response = MockedRESTLogin.sampleAuthenticationTokenData()
                return OHHTTPStubsResponse(data: response, statusCode: 200, headers: ["Content-Type": "text/plain"])
        })
        
        self.postStub =
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != self.host) {
                return false
            }
            if (request.URL?.path != .Some("/api/PostLogin/PostLoginChecks")) {
                return false
            }
            if (request.HTTPMethod != "GET") {
                return false
            }
            
            return true
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                let expiryDate = NSDate(timeIntervalSinceNow: 2629743)
                let myhost: String = self.host ?? ""
                let cookieProperties: [String: AnyObject] = [NSHTTPCookieValue: "true", NSHTTPCookieName: "PassedPostLoginChecks", NSHTTPCookiePath: "/", NSHTTPCookieDomain: myhost, NSHTTPCookieOriginURL: myhost, NSHTTPCookieExpires: expiryDate]
                let cookie = NSHTTPCookie(properties: cookieProperties)
                let mockedCookies = [cookie!]
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(mockedCookies, forURL: loginSite.uri, mainDocumentURL: nil)
                
                let postedCheckData = "<!DOCTYPE html><html><body><p>weird html page</p></body></html>".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                return OHHTTPStubsResponse(data: postedCheckData, statusCode: 200, headers: ["Content-Type": "text/html"])
        })
        
    }

    func hijackAll() {
        self.hijackLoginSequence(self.site, usersStore: self.userStore)
    }
    
    func unhijackAll() {
        if let authStub = self.authStub {
            OHHTTPStubs.removeStub(authStub)
            self.authStub = nil
        }
        if let tokenStub = self.authStub {
            OHHTTPStubs.removeStub(tokenStub)
            self.tokenStub = nil
        }
        if let postStub = self.authStub {
            OHHTTPStubs.removeStub(postStub)
            self.postStub = nil
        }
    }
    
    deinit {
        unhijackAll()
    }
}

protocol StoreWithLoggedInUser {
    var loggedInUser: User? { get set }
}

class MockedUsersStore: MockedRESTStore<User>, UsersStore, StoreWithLoggedInUser {
    var loggedInUser: User?
    
    override init(scheme: String, host: String?, initialValues: [User]?) {
        super.init(scheme: scheme, host: host, initialValues: initialValues)
        self.authFilterForReading = {(user) in
            if let authuser = self.loggedInUser {
                return user.isAuthorizedForReading(authuser)
            }
            return true
        }
        self.authFilterForUpdating = {(user) in
            if let authuser = self.loggedInUser {
                return user.isAuthorizedForUpdating(authuser)
            }
            return true
        }
    }
}

class MockedGamesStore: MockedRESTStore<Game>, GamesStore, StoreWithLoggedInUser {
    private var getForUserStub: OHHTTPStubsDescriptor?
    var loggedInUser: User?

    override init(scheme: String, host: String?, initialValues: [Game]?) {
        super.init(scheme: scheme, host: host, initialValues: initialValues)
        self.authFilterForReading = {(game) in
            if let user = self.loggedInUser {
                return game.isAuthorizedForReading(user)
            }
            return true
        }
        self.authFilterForUpdating = {(game) in
            if let user = self.loggedInUser {
                return game.isAuthorizedForUpdating(user)
            }
            return true
        }
    }
    
    func hijackGetForUser() {
        if (getForUserStub != nil) {return}
        
        let queryPattern = "userId=(.+)$"
        let queryRegEx = try? NSRegularExpression(pattern: queryPattern, options: NSRegularExpressionOptions.CaseInsensitive)
        
        let parseUserIdFromQueryString = {(queryStringIn: String?) -> String? in
            guard let queryString = queryStringIn where queryString != "" else {
                return nil
            }
            var userString: String?
            if let matches = queryRegEx?.matchesInString(queryString, options: NSMatchingOptions(), range:NSMakeRange(0, queryString.characters.count)) {
                if (matches.count > 0) {
                    userString = queryString.substringWithRange(matches[0].rangeAtIndex(1))
                }
            }
            return userString

        }
        
        self.getForUserStub =
            OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
                if (request.URL?.host != self.host) {
                    return false
                }
                if (request.URL?.path != self.endpoint) {
                    return false
                }
                if (request.HTTPMethod != "GET") {
                    return false
                }
                
                return parseUserIdFromQueryString(request.URL?.query) != nil
            }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                guard let userString = parseUserIdFromQueryString(request.URL?.query) else {
                    return MockHTTPResponder<Game>.produceArrayResponse(nil, error: StoreError.NotFound)
                }
                
                let response = self.getAll().filter { $0.isAuthorizedForReading(userString) }.sort(<)
                return MockHTTPResponder<Game>.produceArrayResponse(response, error: nil)
            })
    }
    
    override func hijackAll() {
        super.hijackAll()
        hijackGetForUser()
        
    }
    
    override func unhijackAll() {
        super.unhijackAll()
        if let getForUserStub = self.getForUserStub {
            OHHTTPStubs.removeStub(getForUserStub)
            self.getForUserStub = nil
        }
        
    }

}

class MockedMessagesStore: MockedRESTStore<Message>, MessageStore, StoreWithLoggedInUser {
    private var getForGameStub: OHHTTPStubsDescriptor?
    private var getForUserStub: OHHTTPStubsDescriptor?
    var loggedInUser: User?
    private var gamesStore: GamesStore

    init(scheme: String, host: String?, games: GamesStore, initialValues: [Message]?) {
        self.gamesStore = games
        super.init(scheme: scheme, host: host, initialValues: initialValues)
        self.authFilterForReading = {(message) in
            if let authuser = self.loggedInUser {
                return message.isAuthorizedForReading(self.gamesStore.store, authuser: authuser)
            }
            return true
        }
        self.authFilterForUpdating = {(message) in
            if let authuser = self.loggedInUser {
                return message.isAuthorizedForUpdating(authuser)
            }
            return true
        }
    }
    
    func hijackGetForGame() {
        if (getForGameStub != nil) {return}
        let queryPattern = "game=(.+)$"
        let queryRegEx = try? NSRegularExpression(pattern: queryPattern, options: NSRegularExpressionOptions.CaseInsensitive)

        let parseGameFromQueryString = {(queryStringIn: String?) -> String? in
            guard let queryString = queryStringIn where queryString != "" else {
                return nil
            }
            var gameString: String?
            if let matches = queryRegEx?.matchesInString(queryString, options: NSMatchingOptions(), range:NSMakeRange(0, queryString.characters.count)) {
                if (matches.count > 0) {
                    gameString = queryString.substringWithRange(matches[0].rangeAtIndex(1))
                }
            }
            return gameString
            
        }

        self.getForGameStub =
            OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
                if (request.URL?.host != self.host) {
                    return false
                }
                if (request.URL?.path != self.endpoint) {
                    return false
                }
                if (request.HTTPMethod != "GET") {
                    return false
                }
                
                return parseGameFromQueryString(request.URL?.query) != nil
            }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                guard let gameString = parseGameFromQueryString(request.URL?.query) where gameString != "" else {
                    return MockHTTPResponder<Message>.produceArrayResponse(nil, error: StoreError.NotFound)
                }

                let response = self.getAll().filter { $0.game?.UUIDString == gameString }.sort(<)
                return MockHTTPResponder<Message>.produceArrayResponse(response, error: nil)
            })
    }
    
    override func hijackAll() {
        super.hijackAll()
        hijackGetForGame()
        
    }
    
    override func unhijackAll() {
        super.unhijackAll()
        if let getForGameStub = self.getForGameStub {
            OHHTTPStubs.removeStub(getForGameStub)
            self.getForGameStub = nil
        }

    }
}

class MockedRESTCalls {
    var userStore: MockedUsersStore
    var loginStore: MockedRESTLogin?
    var gamesStore: MockedGamesStore
    var messagesStore: MockedMessagesStore
    
    init(site: APISite, initialUsers: [User], initialGames: [Game], initialMessages: [Message]) {

        self.userStore = MockedUsersStore(scheme: site.uri?.scheme ?? "https", host: site.uri?.host, initialValues: initialUsers)
        
        self.gamesStore = MockedGamesStore(scheme: site.uri?.scheme ?? "https", host: site.uri?.host, initialValues: initialGames)
        
        self.messagesStore = MockedMessagesStore(scheme: site.uri?.scheme ?? "https", host: site.uri?.host, games: self.gamesStore, initialValues: initialMessages)
        
        self.loginStore = MockedRESTLogin(site: site, usersStore: self.userStore, userLoginChange: { (user) -> () in
            self.userStore.loggedInUser = user
            self.gamesStore.loggedInUser = user
            self.messagesStore.loggedInUser = user
        })
    }
    
    static func getImageWithName(name: String) -> UIImage? {
        let myBundle = NSBundle(forClass: self)
        if let jsonFilePath = myBundle.pathForResource(name, ofType: "jpeg") {
            if let data = NSData(contentsOfFile: jsonFilePath) {
                return UIImage(data: data)
            }
        }
        return nil
    }

    func hijackAll() {
        self.loginStore?.hijackAll()
        self.userStore.hijackAll()
        self.gamesStore.hijackAll()
        self.messagesStore.hijackAll()
    }
    
    func unhijackAll() {
        self.loginStore?.unhijackAll()
        self.userStore.unhijackAll()
        self.gamesStore.unhijackAll()
        self.messagesStore.unhijackAll()
    }
    
    deinit {
        self.unhijackAll()
    }
}
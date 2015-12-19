//
//  TestModelGame.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/19/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import XCTest
import RSDSerialization
@testable import CodeMash2016

class TestModelGame: XCTestCase {
    func testSerializeAndDeserializeWithNils() {
        let game = Game(id: nil, title: "Glorantha", owner: NSUUID(), users: nil)
        let json = game.convertToJSON()
        XCTAssert(json.count == 2)
        
        let newGame = Game.createFromJSON(json)
        XCTAssertTrue(newGame != nil)
        XCTAssertTrue(game == newGame!)
    }
    
    func testSerializeAndDeserialize() {
        let game = Game(id: NSUUID(), title: "Glorantha", owner: NSUUID(), users: [NSUUID(), NSUUID()])
        let json = game.convertToJSON()
        XCTAssert(json.count == 4)
        
        let newGame = Game.createFromJSON(json)
        XCTAssertTrue(newGame != nil)
        XCTAssertTrue(game == newGame!)
    }
}

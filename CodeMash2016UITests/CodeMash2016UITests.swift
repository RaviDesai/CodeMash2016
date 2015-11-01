//
//  CodeMash2016UITests.swift
//  CodeMash2016UITests
//
//  Created by Ravi Desai on 10/23/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import XCTest

class CodeMash2016UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testChoosePhoto() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.buttons["Login"].tap()
        tablesQuery.staticTexts["Two"].tap()
        app.buttons["Choose Photo"].tap()
        tablesQuery.buttons["Moments"].tap()
        app.collectionViews.cells["Photo, Landscape, March 12, 2011, 4:17 PM"].tap()
        
        let chooseButton = app.buttons["Choose"]
        XCTAssertTrue(chooseButton.exists)
        XCTAssertTrue(chooseButton.hittable)
        chooseButton.tap()
        
        app.navigationBars["CodeMash2016.UpdateUser"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        app.sheets["Save changes"].collectionViews.buttons["Save changes"].tap()
        
    }
    
}

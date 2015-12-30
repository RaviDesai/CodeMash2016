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
        let app = XCUIApplication()
        app.launchArguments = ["--mockdata"]
        app.launch()
        XCUIDevice.sharedDevice().orientation = .Portrait
    }
    
    override func tearDown() {
        XCUIDevice.sharedDevice().orientation = .Portrait
        super.tearDown()
    }
    
    func testRotate() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.buttons["Login"].tap()
        tablesQuery.staticTexts["Two"].tap()

        let textField = app.otherElements.containingType(.NavigationBar, identifier:"Edit User").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.TextField).elementBoundByIndex(0)
        let beforeRect = textField.frame
        XCUIDevice.sharedDevice().orientation = .LandscapeRight
        let afterRect = textField.frame
        XCTAssertGreaterThan(afterRect.width, beforeRect.width)
    }
    
    func testChoosePhotoThatFails() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.buttons["Login"].tap()
        tablesQuery.staticTexts["Two"].tap()
        app.buttons["Choose Photo"].tap()

        let okButton = app.alerts.element.collectionViews.buttons["OK"]
        if (okButton.exists) {
            //this line will never be hit even when the dialog is displayed
            okButton.tap()
        }

        tablesQuery.buttons["Moments"].tap()
        
        app.collectionViews.childrenMatchingType(.Cell).matchingIdentifier("Photo, Landscape, March 12, 2011, 4:17 PM").elementBoundByIndex(0).tap()
        
        let chooseButton = app.buttons["Choose"]
        XCTAssertTrue(chooseButton.exists)
        
        // test fails here - chooseButton is not 'hittable'
        XCTAssertTrue(chooseButton.hittable)
        chooseButton.tap()
        
        app.navigationBars["CodeMash2016.UpdateUser"]
            .childrenMatchingType(.Button)
            .matchingIdentifier("Back")
            .elementBoundByIndex(0)
            .tap()
        
        app.sheets["Save changes"].collectionViews.buttons["Save changes"].tap()
        
    }
    
    func testAttemptToReproduceUITestException() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.buttons["Login"].tap()
        tablesQuery.staticTexts["Three"].tap()
        
        let backButton = app.navigationBars["Edit User"].buttons["Users"]
        backButton.tap()
        tablesQuery.staticTexts["Two"].tap()
        
        let textField = app.otherElements.containingType(.NavigationBar, identifier:"Edit User").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.TextField).elementBoundByIndex(0)
        textField.tap()
        textField.typeText("abx")
        backButton.tap()
        
        let saveChangesSheet = app.sheets["Save changes"]
        let collectionViewsQuery = saveChangesSheet.collectionViews
        let saveChangesButton = collectionViewsQuery.buttons["Save changes"]
        saveChangesButton.tap()
        
        let changedValue = tablesQuery.staticTexts["Twoabx"]
        XCTAssertTrue(changedValue.exists)
    }
    

}

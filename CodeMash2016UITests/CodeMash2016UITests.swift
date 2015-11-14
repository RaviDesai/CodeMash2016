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
        app.launchArguments = ["--noanimations"]
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testForCoverage() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.buttons["Login"].tap()
        tablesQuery.staticTexts["Four"].tap()
        
        let textField = app.otherElements.containingType(.NavigationBar, identifier:"CodeMash2016.UpdateUser").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.TextField).elementBoundByIndex(0)
        textField.tap()
        textField.typeText("a")
        app.navigationBars["CodeMash2016.UpdateUser"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        app.sheets["Save changes"].collectionViews.buttons["Save changes"].tap()
        
    }
    
    func testChoosePhoto() {
        
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
        
        let backButton = app.navigationBars["CodeMash2016.UpdateUser"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0)
        backButton.tap()
        tablesQuery.staticTexts["Two"].tap()
        
        let textField = app.otherElements.containingType(.NavigationBar, identifier:"CodeMash2016.UpdateUser").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.TextField).elementBoundByIndex(0)
        textField.tap()
        textField.typeText("abx")
        backButton.tap()
        
        let saveChangesSheet = app.sheets["Save changes"]
        let collectionViewsQuery = saveChangesSheet.collectionViews
        let saveChangesButton = collectionViewsQuery.buttons["Save changes"]
        saveChangesButton.tap()
        
        app.tables.staticTexts["One"].tap()
        
        let textField2 = app.otherElements.containingType(.NavigationBar, identifier:"CodeMash2016.UpdateUser").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.TextField).elementBoundByIndex(0)
        textField2.tap()
        textField2.typeText("s")
        app.navigationBars["CodeMash2016.UpdateUser"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        app.sheets["Save changes"].collectionViews.buttons["Exit without saving"].tap()
        
        // test fails after executing this line...
        app.navigationBars["CodeMash2016.ShowUsers"].buttons["Compose"].tap()
        
        // but only if you comment out the following 4 lines...
        let navBarText = app.navigationBars.containingType(.StaticText, identifier: "Compose").element
        let navBarTextExists = NSPredicate(format: "exists == 1")
        self.expectationForPredicate(navBarTextExists, evaluatedWithObject: navBarText, handler: nil)
        self.waitForExpectationsWithTimeout(5, handler: nil)
        // ...stop commenting out here
        
        let toTextField = app.textFields.containingType(.StaticText, identifier:"To:").element
        toTextField.tap()
        toTextField.typeText("a")
        app.tables.staticTexts["four@desai.com"].tap()
        toTextField.typeText("a")
        app.tables.staticTexts["three@desai.com"].tap()
        
        let ccTextField = app.scrollViews.otherElements.textFields
            .containingType(.StaticText, identifier:"Cc:").element
        
        ccTextField.tap()
        ccTextField.typeText("a")
        app.staticTexts["one@desai.com"].tap()
        ccTextField.typeText("a")
        app.staticTexts["two@desai.com"].tap()
        
        app.navigationBars["Compose"]
            .childrenMatchingType(.Button)
            .matchingIdentifier("Back")
            .elementBoundByIndex(0)
            .tap()
    }
    
}

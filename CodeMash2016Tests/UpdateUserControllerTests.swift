//
//  UpdateUserControllerTests.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/30/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import XCTest
import RSDTesting
import RSDRESTServices
import RSDSerialization
import OHHTTPStubs
@testable import CodeMash2016

class UpdateUserControllerTests: ControllerTestsBase {
    var controller: UpdateUserController?
    var called = false
    var mockViewModel: PartialMockUpdateUserViewModel?
    
    func getStoryboard(name: String) -> UIStoryboard? {
        let storyboardBundle = NSBundle(forClass: UpdateUserController.classForCoder())
        return UIStoryboard(name: name, bundle: storyboardBundle)
    }
    
    class override func setUp() {
        super.setUp()
        Swizzler<UpdateUserController>.swizzlePresentViewControllerAnimated()
        Swizzler<UpdateUserController>.swizzleDismissViewControllerAnimated()
    }
    
    class override func tearDown() {
        Swizzler<UpdateUserController>.swizzlePresentViewControllerAnimated()
        Swizzler<UpdateUserController>.swizzleDismissViewControllerAnimated()
        
        super.tearDown()
    }
    
    override func setUp() {
        super.setUp()
        
        ActionFactory.Action = {(title: String, style: UIAlertActionStyle, handler: ((UIAlertAction)->()))->UIAlertAction in
            return MockAlertAction(title: title, style: style, handler: handler)
        }

        let storyboard = self.getStoryboard("Main")
        self.controller = storyboard?.instantiateViewControllerWithIdentifier("updateUserController") as? UpdateUserController
        
        self.controller?.view.hidden = false
        
        self.mockViewModel = PartialMockUpdateUserViewModel(vm: self.controller!.viewModel! as! UpdateUserViewModel)
        self.controller!.viewModel = self.mockViewModel
        
        self.called = false
    }
    
    override func tearDown() {
        ActionFactory.restoreDefault()
        self.controller = nil
        self.called = false
        super.tearDown()
    }
    
    func testInitialLoadCanEdit() {
        let userOne = getUserOne()
        let admin = getLoginUser()
        self.controller!.setUser(userOne, loggedInUser: admin) { (savedIndicator, savedUser) -> () in
        }
        
        XCTAssertTrue(self.controller!.idValue.text == userOne.id?.compressedUUIDString)
        XCTAssertTrue(self.controller!.nameTextField.text == .Some(userOne.name))
        XCTAssertTrue(self.controller!.nameTextField.enabled)
        XCTAssertTrue(self.controller!.emailTextField.text == userOne.emailAddress?.description)
        XCTAssertTrue(self.controller!.emailTextField.enabled)
        XCTAssertTrue(self.controller!.contactImageView.image != nil)
        XCTAssertTrue(self.controller!.navigationItem.rightBarButtonItem!.enabled)
        XCTAssertTrue(self.controller!.removePhotoButton!.enabled)
        XCTAssertTrue(self.controller!.choosePhotoButton!.enabled)
    }
    
    func testInitialLoadCannotEdit() {
        let userTwo = getUserTwo()
        let userOne = getUserOne()

        self.controller!.setUser(userOne, loggedInUser: userTwo) { (savedIndicator, savedUser) -> () in
        }

        XCTAssertTrue(self.controller!.idValue.text == userOne.id?.compressedUUIDString)
        XCTAssertTrue(self.controller!.nameTextField.text == .Some(userOne.name))
        XCTAssertFalse(self.controller!.nameTextField.enabled)
        XCTAssertTrue(self.controller!.emailTextField.text == userOne.emailAddress?.description)
        XCTAssertFalse(self.controller!.emailTextField.enabled)
        XCTAssertTrue(self.controller!.contactImageView.image != nil)
        XCTAssertFalse(self.controller!.navigationItem.rightBarButtonItem!.enabled)
        XCTAssertFalse(self.controller!.removePhotoButton!.enabled)
        XCTAssertFalse(self.controller!.choosePhotoButton!.enabled)
    }
    
    func testInitialLoadSaveUserCannotDelete() {
        let admin = getLoginUser()
        
        self.controller!.setUser(admin, loggedInUser: admin) { (savedIndicator, savedUser) -> () in
        }
        
        XCTAssertFalse(self.controller!.navigationItem.rightBarButtonItem!.enabled)
    }
    
    func testAttachPhotoPresentsANewControllerAndCancelIt() {
        let userTwo = getUserTwo()
        self.controller!.setUser(userTwo, loggedInUser: userTwo) { (savedIndicator, savedUser) -> () in
        }
        
        XCTAssertTrue(self.controller!.idValue.text == userTwo.id?.compressedUUIDString)
        XCTAssertTrue(self.controller!.nameTextField.text == .Some(userTwo.name))
        XCTAssertTrue(self.controller!.nameTextField.enabled)
        XCTAssertTrue(self.controller!.choosePhotoButton!.enabled)
        
        var imagePicker: UIImagePickerController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated)->Bool in
            imagePicker  = viewController as? UIImagePickerController
            self.called = true
            return false
        })
        
        self.controller!.choosePhotoButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(imagePicker != nil)
        
        var dismissCalled = false
        imagePicker!.dismissViewControllerAnimatedInterceptCallback = DismissViewControllerAnimatedInterceptCallbackWrapper({(animated) -> Bool in
            dismissCalled = true
            self.called = true
            return false
        })
        
        self.called = false
        self.controller!.imagePickerControllerDidCancel(imagePicker!)
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(dismissCalled)
        
        XCTAssertTrue(self.controller!.viewModel!.contactImage == nil)
        XCTAssertTrue(self.controller!.contactImageView.image == nil)
    }

    func testAttachPhotoPresentsANewControllerAndChoosePhoto() {
        let userTwo = getUserTwo()
        self.controller!.setUser(userTwo, loggedInUser: userTwo) { (savedIndicator, savedUser) -> () in
        }
        
        XCTAssertTrue(self.controller!.idValue.text == userTwo.id?.compressedUUIDString)
        XCTAssertTrue(self.controller!.nameTextField.text == .Some(userTwo.name))
        XCTAssertTrue(self.controller!.nameTextField.enabled)
        XCTAssertTrue(self.controller!.choosePhotoButton!.enabled)
        
        var imagePicker: UIImagePickerController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated)->Bool in
            imagePicker  = viewController as? UIImagePickerController
            self.called = true
            return false
        })
        
        self.controller!.choosePhotoButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(imagePicker != nil)
        
        var dismissCalled = false
        imagePicker!.dismissViewControllerAnimatedInterceptCallback = DismissViewControllerAnimatedInterceptCallbackWrapper({(animated) -> Bool in
            dismissCalled = true
            self.called = true
            return false
        })
        
        self.called = false
        let imagePicked = MockedRESTCalls.getImageWithName("NumberOne")
        self.controller!.imagePickerController(imagePicker!, didFinishPickingImage: imagePicked, editingInfo: Dictionary<NSObject, AnyObject>())
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(dismissCalled)
        
        XCTAssertTrue(self.controller!.viewModel!.contactImage != nil)
        XCTAssertTrue(self.controller!.contactImageView.image != nil)
    }
    
    func testRemovePhoto() {
        let userOne = getUserOne()
        self.controller!.setUser(userOne, loggedInUser: userOne) { (savedIndicator, savedUser) -> () in
        }
        
        self.controller!.removePhotoButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        
        XCTAssertTrue(self.controller!.contactImageView.image == nil)
        XCTAssertTrue(self.controller!.viewModel!.contactImage == nil)
    }
    
    func testDeleteUserSuccess() {
        let userOne = getUserOne()
        let admin = getLoginUser()
        
        var savedIndicator: DeletedOrSaved?
        var savedUser: User?
        self.controller!.setUser(userOne, loggedInUser: admin) { (indicator, user) -> () in
            savedIndicator = indicator
            savedUser = user
        }
        
        self.mockViewModel!.deleteUserCallback = {(user) -> (User?, NSError?) in
            return (user, nil)
        }
        
        let deleteButton = self.controller!.navigationItem.rightBarButtonItem
        UIApplication.sharedApplication().sendAction(deleteButton!.action, to: deleteButton!.target, from: deleteButton, forEvent: nil)
        
        XCTAssertTrue(savedIndicator == .Some(.Deleted))
        XCTAssertTrue(savedUser == .Some(userOne))
    }

    func testDeleteUserFailure() {
        let userOne = getUserOne()
        let admin = getLoginUser()
        
        self.controller!.setUser(userOne, loggedInUser: admin) { (indicator, user) -> () in
        }
        
        self.mockViewModel!.deleteUserCallback = {(user) -> (User?, NSError?) in
            return (nil, self.mockViewModel!.generateError(401, message: "unauthorized"))
        }
        
        var alertController: UIAlertController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated)->Bool in
            alertController  = viewController as? UIAlertController
            self.called = true
            return false
        })

        self.called = false
        let deleteButton = self.controller!.navigationItem.rightBarButtonItem
        UIApplication.sharedApplication().sendAction(deleteButton!.action, to: deleteButton!.target, from: deleteButton, forEvent: nil)
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(alertController != nil)
    }
    
    func testUpdateName() {
        let userOne = getUserOne()
        let admin = getLoginUser()
        
        self.controller!.setUser(userOne, loggedInUser: admin) { (indicator, user) -> () in }
        
        self.controller!.nameTextField.text = "updated"
        self.controller!.textFieldDidEndEditing(self.controller!.nameTextField)
        XCTAssertTrue(self.mockViewModel!.contactName == .Some("updated"))
        XCTAssertTrue(self.mockViewModel!.hasInformationChanged)
    }

    func testUpdateAddress() {
        let userOne = getUserOne()
        let admin = getLoginUser()
        
        self.controller!.setUser(userOne, loggedInUser: admin) { (indicator, user) -> () in }

        self.controller!.emailTextField.text = "zzz"
        self.controller!.textFieldDidEndEditing(self.controller!.emailTextField)
        XCTAssertFalse(mockViewModel!.hasValidEmailAddress)
        XCTAssertTrue(mockViewModel!.contactAddress == nil)

        self.controller!.emailTextField.text = "newaddr@gmail.com"
        self.controller!.textFieldDidEndEditing(self.controller!.emailTextField)
        XCTAssertTrue(self.mockViewModel!.contactAddress == .Some("newaddr@gmail.com"))
        XCTAssertTrue(self.mockViewModel!.hasValidEmailAddress)
        XCTAssertTrue(self.mockViewModel!.hasInformationChanged)
    }
    
    func testColorWhenEmailBad() {
        let userOne = getUserOne()
        let admin = getLoginUser()
        
        self.controller!.setUser(userOne, loggedInUser: admin) { (indicator, user) -> () in }
        let range = self.controller!.emailTextField.text!.NSRangeFromRange(self.controller!.emailTextField.text!.startIndex ..< self.controller!.emailTextField.text!.endIndex)
        self.controller!.textField(self.controller!.emailTextField, shouldChangeCharactersInRange: range, replacementString: "zzz@")
        XCTAssertTrue(self.controller!.emailTextField.textColor == UIColor.redColor())
    }

    func testColorWhenEmailGood() {
        let userOne = getUserOne()
        let admin = getLoginUser()
        
        self.controller!.setUser(userOne, loggedInUser: admin) { (indicator, user) -> () in }
        let range = self.controller!.emailTextField.text!.NSRangeFromRange(self.controller!.emailTextField.text!.startIndex ..< self.controller!.emailTextField.text!.endIndex)
        self.controller!.textField(self.controller!.emailTextField, shouldChangeCharactersInRange: range, replacementString: "good@addr.com")
        XCTAssertTrue(self.controller!.emailTextField.textColor == UIColor.blackColor())
    }

    func testBackButtonWhenInfoNotChanged() {
        let userOne = getUserOne()
        let admin = getLoginUser()
        
        self.controller!.setUser(userOne, loggedInUser: admin) { (indicator, user) -> () in }

        XCTAssertTrue(self.controller!.navigationShouldPopOnBackButton())
    }

    func testBackButtonWhenNameChanged() {
        let userOne = getUserOne()
        let admin = getLoginUser()
        
        self.controller!.setUser(userOne, loggedInUser: admin) { (indicator, user) -> () in }
        self.controller!.nameTextField.text = "changed"
        self.controller!.textFieldDidEndEditing(self.controller!.nameTextField)
        
        var alertController: UIAlertController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated)->Bool in
            alertController  = viewController as? UIAlertController
            self.called = true
            return false
        })

        XCTAssertFalse(self.controller!.navigationShouldPopOnBackButton())
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(alertController != nil)
    }
    
    func testBackButtonWhenEmailChangedToInvalid() {
        let userOne = getUserOne()
        let admin = getLoginUser()
        
        self.controller!.setUser(userOne, loggedInUser: admin) { (indicator, user) -> () in }
        self.controller!.emailTextField.text = "invalid"
        self.controller!.textFieldDidEndEditing(self.controller!.emailTextField)
        XCTAssertFalse(mockViewModel!.hasValidEmailAddress)
        
        var alertController: UIAlertController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated)->Bool in
            alertController  = viewController as? UIAlertController
            self.called = true
            return false
        })
        
        XCTAssertFalse(self.controller!.navigationShouldPopOnBackButton())
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(alertController != nil)
        XCTAssertTrue(alertController!.message == "Warning - the name or email field has an invalid value")
    }

    func testBackButtonWhenUpdateUserNameChangedPressSave() {
        let userOne = getUserOne()
        let admin = getLoginUser()
        
        var saveIndicator: DeletedOrSaved?
        var saveUser: User?
        self.controller!.setUser(userOne, loggedInUser: admin) { (indicator, user) -> () in
            saveIndicator = indicator
            saveUser = user
        }
        
        self.controller!.nameTextField.text = "changed"
        self.controller!.textFieldDidEndEditing(self.controller!.nameTextField)
        
        var alertController: UIAlertController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated)->Bool in
            alertController  = viewController as? UIAlertController
            self.called = true
            return false
        })
        
        XCTAssertFalse(self.controller!.navigationShouldPopOnBackButton())
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(alertController != nil)
        
        self.mockViewModel!.saveUserCallback = {(user) -> (User?, NSError?) in
            return (user, nil)
        }
        
        let mockNavigator = UINavigationController()
        var popWasCalled = true
        mockNavigator.popViewControllerAnimatedInterceptCallback = PopViewControllerAnimatedInterceptCallbackWrapper({(animated) -> Bool in
            popWasCalled = true
            return false
        })
        self.controller!.navigationControllerInterceptCallback = NavigationControllerInterceptCallbackWrapper({() -> UINavigationController in
            return mockNavigator
        })
        
        let saveAction = alertController!.actions[1] as? MockAlertAction
        XCTAssertTrue(saveAction != nil)
        saveAction!.call()
        XCTAssertTrue(saveIndicator == .Some(.Saved))
        XCTAssertTrue(saveUser == mockViewModel!.user)
        XCTAssertTrue(popWasCalled)
    }
    
    func testBackButtonWhenUpdateUserNameChangedPressCancel() {
        let userOne = getUserOne()
        let admin = getLoginUser()
        
        var saveIndicator: DeletedOrSaved?
        var saveUser: User?
        self.controller!.setUser(userOne, loggedInUser: admin) { (indicator, user) -> () in
            saveIndicator = indicator
            saveUser = user
        }
        
        self.controller!.nameTextField.text = "changed"
        self.controller!.textFieldDidEndEditing(self.controller!.nameTextField)
        
        var alertController: UIAlertController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated)->Bool in
            alertController  = viewController as? UIAlertController
            self.called = true
            return false
        })
        
        XCTAssertFalse(self.controller!.navigationShouldPopOnBackButton())
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(alertController != nil)
        
        self.mockViewModel!.saveUserCallback = {(user) -> (User?, NSError?) in
            return (user, nil)
        }
        
        let cancelAction = alertController!.actions[2] as? MockAlertAction
        XCTAssertTrue(cancelAction != nil)
        cancelAction!.call()
        XCTAssertTrue(saveIndicator == nil)
        XCTAssertTrue(saveUser == nil)
    }
    
    func testBackButtonWhenUpdateUserNameChangedPressExitNotSave() {
        let userOne = getUserOne()
        let admin = getLoginUser()
        
        var saveIndicator: DeletedOrSaved?
        var saveUser: User?
        self.controller!.setUser(userOne, loggedInUser: admin) { (indicator, user) -> () in
            saveIndicator = indicator
            saveUser = user
        }
        
        self.controller!.nameTextField.text = "changed"
        self.controller!.textFieldDidEndEditing(self.controller!.nameTextField)
        
        var alertController: UIAlertController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated)->Bool in
            alertController  = viewController as? UIAlertController
            self.called = true
            return false
        })
        
        XCTAssertFalse(self.controller!.navigationShouldPopOnBackButton())
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(alertController != nil)
        
        self.mockViewModel!.saveUserCallback = {(user) -> (User?, NSError?) in
            return (user, nil)
        }
        
        let mockNavigator = UINavigationController()
        var popWasCalled = true
        mockNavigator.popViewControllerAnimatedInterceptCallback = PopViewControllerAnimatedInterceptCallbackWrapper({(animated) -> Bool in
            popWasCalled = true
            return false
        })
        self.controller!.navigationControllerInterceptCallback = NavigationControllerInterceptCallbackWrapper({() -> UINavigationController in
            return mockNavigator
        })
        
        let exitAction = alertController!.actions[0] as? MockAlertAction
        XCTAssertTrue(exitAction != nil)
        exitAction!.call()
        XCTAssertTrue(saveIndicator == nil)
        XCTAssertTrue(saveUser == nil)
        XCTAssertTrue(popWasCalled)
    }

    func testBackButtonWhenCreateUserNameChangedPressSave() {
        let userOne = User(id: nil, name: "new user", password: "pass", emailAddress: nil, image: nil)
        let admin = getLoginUser()
        
        var saveIndicator: DeletedOrSaved?
        var saveUser: User?
        self.controller!.setUser(userOne, loggedInUser: admin) { (indicator, user) -> () in
            saveIndicator = indicator
            saveUser = user
        }
        
        self.controller!.emailTextField.text = "new@user.com"
        self.controller!.textFieldDidEndEditing(self.controller!.emailTextField)
        
        var alertController: UIAlertController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated)->Bool in
            alertController  = viewController as? UIAlertController
            self.called = true
            return false
        })
        
        XCTAssertFalse(self.controller!.navigationShouldPopOnBackButton())
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(alertController != nil)
        
        var createdUser: User?
        self.mockViewModel!.createUserCallback = {(user) -> (User?, NSError?) in
            createdUser = user
            createdUser!.id = NSUUID()
            return (user, nil)
        }
        
        let mockNavigator = UINavigationController()
        var popWasCalled = true
        mockNavigator.popViewControllerAnimatedInterceptCallback = PopViewControllerAnimatedInterceptCallbackWrapper({(animated) -> Bool in
            popWasCalled = true
            return false
        })
        self.controller!.navigationControllerInterceptCallback = NavigationControllerInterceptCallbackWrapper({() -> UINavigationController in
            return mockNavigator
        })
        
        let saveAction = alertController!.actions[1] as? MockAlertAction
        XCTAssertTrue(saveAction != nil)
        saveAction!.call()
        XCTAssertTrue(saveIndicator == .Some(.Saved))
        XCTAssertTrue(saveUser == createdUser)
        XCTAssertTrue(popWasCalled)
    }
}
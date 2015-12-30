//
//  UpdateUserController.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/29/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

class UpdateUserController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var idValue: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var removePhotoButton: UIButton!
    @IBOutlet weak var choosePhotoButton: UIButton!
    
    var viewModel: UpdateUserViewModelProtocol?
    var userModificationHandler: ((DeletedOrSaved, User?) -> ())?
    
    func ensureViewModelIsCreated() {
        if (self.viewModel != nil) { return }
        
        viewModel = UpdateUserViewModel()
    }
    
    func initializeComponentsFromViewModel() {
        if (self.viewModel == nil) { return }
        if (!self.isViewLoaded()) { return }
        
        idLabel.text = "ID"
        nameLabel.text = "Name"
        emailLabel.text = "Email"
        
        idValue.text = self.viewModel?.uuidString ?? "--New User--"
        nameTextField.text = self.viewModel?.contactName
        emailTextField.text = self.viewModel?.contactAddress
        
        nameTextField.enabled = self.viewModel!.canBeUpdated
        emailTextField.enabled = self.viewModel!.canBeUpdated
        self.removePhotoButton.enabled = self.viewModel!.canBeUpdated
        self.choosePhotoButton.enabled = self.viewModel!.canBeUpdated
        
        if (self.viewModel?.hasValidEmailAddress == .Some(false)) {
            self.emailTextField.textColor = UIColor.redColor()
        } else {
            self.emailTextField.textColor = UIColor.blackColor()
        }
        
        self.contactImageView.image = self.viewModel?.contactImage
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        
        let deleteButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: Selector("deleteUser:"))
        deleteButton.enabled = self.viewModel!.canBeUpdated && self.viewModel!.user != self.viewModel!.loggedInUser

        self.navigationItem.rightBarButtonItem = deleteButton
        self.navigationItem.title = "Edit User"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ensureViewModelIsCreated()
        initializeComponentsFromViewModel()
    }
    
    func setUser(user : User?, loggedInUser: User?, userWasModified: (DeletedOrSaved, User?)->()) {
        self.userModificationHandler = userWasModified
        ensureViewModelIsCreated()
        self.viewModel?.setUser(user, loggedInUser: loggedInUser)
        initializeComponentsFromViewModel()
    }
    
    override func navigationShouldPopOnBackButton() -> Bool {
        updateViewModelFromTextField(self.nameTextField)
        updateViewModelFromTextField(self.emailTextField)
        
        let emailAddressIsValid = (self.viewModel?.contactAddress != nil)
        let nameIsValid = (self.viewModel?.contactName != nil && self.viewModel?.contactName != .Some(""))
        let informationHasChanged = self.viewModel?.hasInformationChanged ?? false
        let userIsBeingUpdated = self.viewModel?.uuidString != nil
        
        if (!informationHasChanged && self.viewModel?.uuidString != nil) {
            return true
        }
        
        let title = "Save changes"
        
        let message: String? = (!emailAddressIsValid || !nameIsValid) ? "Warning - the name or email field has an invalid value" : nil
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let exitAction = ActionFactory.Action("Exit without saving", UIAlertActionStyle.Default) { (action) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        let saveAction = ActionFactory.Action("Save changes", UIAlertActionStyle.Default) { (action) -> Void in
            if (userIsBeingUpdated) {
                self.viewModel!.saveUser({ (returnedUser, returnedError) -> () in
                    guard let myError = returnedError else {
                        self.userModificationHandler?(.Saved, returnedUser)
                        self.navigationController?.popViewControllerAnimated(true)
                        return
                    }
                    self.notifyUserOfError(myError, withCallbackOnDismissal: { () -> () in })
                })
            } else {
                self.viewModel!.createUser({ (returnedUser, returnedError) -> () in
                    guard let myError = returnedError else {
                        self.userModificationHandler?(.Saved, returnedUser)
                        self.navigationController?.popViewControllerAnimated(true)
                        return
                    }
                    self.notifyUserOfError(myError, withCallbackOnDismissal: { () -> () in })
                })
            }
        }
        
        let cancelAction = ActionFactory.Action("Cancel", UIAlertActionStyle.Cancel) { (action) -> Void in
        }
        
        alert.addAction(exitAction)
        if (emailAddressIsValid && nameIsValid) {
            alert.addAction(saveAction)
        }
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        return false
    }
    
    func deleteUser(sender: UIBarButtonItem) {
        self.viewModel?.deleteUser({(deletedUser, returnedError) -> () in
            guard let myError = returnedError else {
                self.userModificationHandler?(.Deleted, deletedUser)
                self.navigationController?.popViewControllerAnimated(true)
                return
            }
            self.notifyUserOfError(myError, withCallbackOnDismissal: { () -> () in })
        })
    }
        
    func updateViewModelFromTextField(textField: UITextField) {
        if (textField == self.nameTextField) {
            self.viewModel?.contactName = textField.text
        } else if (textField == self.emailTextField) {
            self.viewModel?.contactAddress = textField.text
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (textField == self.emailTextField) {
            let newString = textField.text?.stringByReplacingCharactersInRange(range, withString: string)
            if (EmailAddress(string: newString) == nil) {
                self.emailTextField.textColor = UIColor.redColor()
            } else {
                self.emailTextField.textColor = UIColor.blackColor()
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateViewModelFromTextField(textField)
    }
    
    @IBAction func removePhoto(sender: AnyObject) {
        self.viewModel?.contactImage = nil
        self.contactImageView.image = viewModel?.contactImage
    }
    
    
    @IBAction func attachPhoto(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        if let chosenImage = (editingInfo[UIImagePickerControllerEditedImage] as? UIImage) ?? image {
            self.viewModel?.contactImage = chosenImage
            self.contactImageView.image = self.viewModel?.contactImage
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil);
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil);
    }
}


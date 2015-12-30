//
//  PartialMockUpdateUserViewModel.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/30/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation
import RSDRESTServices
@testable import CodeMash2016

class PartialMockUpdateUserViewModel: PartialMockViewModelBase, UpdateUserViewModelProtocol {
    var vm: UpdateUserViewModel
    init(vm: UpdateUserViewModel) {
        self.vm = vm
    }
    
    var user: User? { get { return vm.user } }
    var loggedInUser: User? { get { return vm.loggedInUser } }
    var canBeUpdated: Bool { get { return vm.canBeUpdated } }
    var uuidString: String? { get { return vm.uuidString } }
    var hasValidEmailAddress: Bool { get { return vm.hasValidEmailAddress } }
    var hasInformationChanged: Bool { get { return vm.hasInformationChanged } }

    var contactName: String? { get { return vm.contactName } set { vm.contactName = newValue } }
    var contactAddress: String? { get { return vm.contactAddress } set { vm.contactAddress = newValue } }
    var contactImage: UIImage? { get { return vm.contactImage } set { vm.contactImage = newValue } }

    var saveUserCallback: ((User?) -> (User?, NSError?))?
    var deleteUserCallback: ((User?) -> (User?, NSError?))?
    var createUserCallback: ((User?) -> (User?, NSError?))?

    func setUser(user: User?, loggedInUser: User?) {
        vm.setUser(user, loggedInUser: loggedInUser)
    }
    
    func saveUser(completionHandler: (User?, NSError?)->()) {
        if let callback = saveUserCallback {
            let (user, error) = callback(self.vm.user)
            if (error == nil) {
                self.vm.originalUser = self.vm.user
            }
            completionHandler(user, error)
        } else {
            completionHandler(nil, self.generateError(405, message: "unimplemented"))
        }
    }
    
    func createUser(completionHandler: (User?, NSError?) -> ()) {
        if let callback = createUserCallback {
            completionHandler(callback(self.vm.user))
        } else {
            completionHandler(nil, self.generateError(405, message: "unimplemented"))
        }
    }
    
    func deleteUser(completionHandler: (User?, NSError?)->()) {
        if let callback = deleteUserCallback {
            completionHandler(callback(self.vm.user))
        } else {
            completionHandler(nil, self.generateError(405, message: "unimplemented"))
        }
    }

}

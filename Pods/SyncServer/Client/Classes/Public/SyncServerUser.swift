//
//  SyncServerUser.swift
//  SyncServer
//
//  Created by Christopher Prince on 12/2/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

import Foundation
import SMCoreLib
import SyncServer_Shared

public class SyncServerUser {
    private var _creds:GenericCredentials?
    public var creds:GenericCredentials? {
        set {
            ServerAPI.session.creds = newValue
            _creds = newValue
        }
        
        get {
            return _creds
        }
    }
    
    public static let session = SyncServerUser()
    
    func appLaunchSetup() {
    }

    // A distinct UUID for this user mobile device.
    // I'm going to persist this in the keychain not so much because it needs to be secure, but rather because it will survive app deletions/reinstallations.
    static let mobileDeviceUUID = SMPersistItemString(name: "SyncServerUser.mobileDeviceUUID", initialStringValue: "", persistType: .keyChain)
    
    private init() {
        // Check to see if the device has a UUID already.
        if SyncServerUser.mobileDeviceUUID.stringValue.count == 0 {
            SyncServerUser.mobileDeviceUUID.stringValue = UUID.make()
        }
        
        ServerAPI.session.delegate = self
    }
    
    public enum CheckForExistingUserResult {
    case noUser
    case owningUser
    case sharingUser(sharingPermission:SharingPermission, accessToken:String?)
    }
    
    fileprivate func showAlert(with title:String, and message:String? = nil) {
        let window = UIApplication.shared.keyWindow
        let rootViewController = window?.rootViewController
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.popoverPresentationController?.sourceView = rootViewController?.view
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        Thread.runSync(onMainThread: {
            rootViewController?.present(alert, animated: true, completion: nil)
        })
    }
    
    public func checkForExistingUser(creds: GenericCredentials,
        completion:@escaping (_ result: CheckForExistingUserResult?, Error?) ->()) {
        
        // Have to do this before call to `checkCreds` because it sets up creds with the ServerAPI.
        self.creds = creds
        
        Log.msg("SignInCreds: \(creds)")
        
        ServerAPI.session.checkCreds { (checkCredsResult, error) in
            var checkForUserResult:CheckForExistingUserResult?
            var errorResult:Error? = error
            
            switch checkCredsResult {
            case .none:
                self.creds = nil
                
                // Don't sign the user out here. Callers of `checkForExistingUser` (e.g., GoogleSignIn or FacebookSignIn) can deal with this.
                
                Log.error("Had an error: \(String(describing: error))")
                errorResult = error
            
            case .some(.noUser):
                self.creds = nil
                
                // Definitive result from server-- there was no user. Still, I'm not going to sign the user out here. Callers can do that.
                
                checkForUserResult = .noUser
                
            case .some(.owningUser):
                checkForUserResult = .owningUser
                
            case .some(.sharingUser(let permission, let accessToken)):
                checkForUserResult = .sharingUser(sharingPermission: permission, accessToken:accessToken)
            }
            
            if case .some(.noUser) = checkForUserResult {
                Thread.runSync(onMainThread: {
                    self.showAlert(with: "\(creds.uiDisplayName) doesn't exist on the system.", and: "You can sign in as a \"New user\", or get a sharing invitation from another user.")
                })
            }
            else if errorResult != nil {
                Thread.runSync(onMainThread: {
                    self.showAlert(with: "Error trying to sign in: \(errorResult!)")
                })
            }
            
            Thread.runSync(onMainThread: {
                completion(checkForUserResult, errorResult)
            })
        }
    }
    
    public func addUser(creds: GenericCredentials, completion:@escaping (Error?) ->()) {
        Log.msg("SignInCreds: \(creds)")

        self.creds = creds
        
        ServerAPI.session.addUser { error in
            if error != nil {
                self.creds = nil
                Log.error("Error: \(String(describing: error))")
                Thread.runSync(onMainThread: {
                    self.showAlert(with: "Failed adding user \(creds.uiDisplayName).", and: "Error was: \(error!).")
                })
            }
            Thread.runSync(onMainThread: {
                completion(error)
            })
        }
    }
    
    public func createSharingInvitation(withPermission permission:SharingPermission, completion:((_ invitationCode:String?, Error?)->(Void))?) {

        ServerAPI.session.createSharingInvitation(withPermission: permission) { (sharingInvitationUUID, error) in
            Thread.runSync(onMainThread: {
                completion?(sharingInvitationUUID, error)
            })
        }
    }
    
    public func redeemSharingInvitation(creds: GenericCredentials, invitationCode:String, completion:((_ accessToken:String?, Error?)->())?) {
        
        self.creds = creds
        
        ServerAPI.session.redeemSharingInvitation(sharingInvitationUUID: invitationCode) { accessToken, error in
            Thread.runSync(onMainThread: {
                completion?(accessToken, error)
            })
        }
    }
}

extension SyncServerUser : ServerAPIDelegate {
    func deviceUUID(forServerAPI: ServerAPI) -> Foundation.UUID {
        return Foundation.UUID(uuidString: SyncServerUser.mobileDeviceUUID.stringValue)!
    }
    
    func userWasUnauthorized(forServerAPI: ServerAPI) {
        Thread.runSync(onMainThread: {
            self.showAlert(with: "The server is having problems authenticating you. Please sign out and sign back in.")
            // May want to explicitly force a user sign-out here. Shall see.
        })
    }

#if DEBUG
    func doneUploadsRequestTestLockSync(forServerAPI: ServerAPI) -> TimeInterval? {
        return nil
    }
    
    func fileIndexRequestServerSleep(forServerAPI: ServerAPI) -> TimeInterval? {
        return nil
    }
#endif
}



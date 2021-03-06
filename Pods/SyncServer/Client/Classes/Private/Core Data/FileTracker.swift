//
//  FileTracker+CoreDataClass.swift
//  Pods
//
//  Created by Christopher Prince on 3/2/17.
//
//

import Foundation
import CoreData
import SMCoreLib
import SyncServer_Shared

@objc(FileTracker)
public class FileTracker: NSManagedObject, Filenaming {
    public var fileUUID:String! {
        get {
            return fileUUIDInternal!
        }
        
        set {
            fileUUIDInternal = newValue
        }
    }
    
    public var fileVersion:Int32! {
        get {
            return fileVersionInternal
        }
        
        set {
            fileVersionInternal = newValue
        }
    }
}

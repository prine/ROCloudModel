//
//  CloudModel.swift
//  CloudKitTest
//
//  Created by Robin Oster on 01/02/16.
//  Copyright © 2016 Prine Development. All rights reserved.
//

import Foundation
import CloudKit
import ROConcurrency

open class ROCloudModel {
    
    open var recordType:String = ""
    open var record:CKRecord?
    open var currentDatabase:CKDatabase
    
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    
    var references = Dictionary<String, CKReference>()
    var referenceLists = Dictionary<String, Array<CKReference>>()
    
    public required init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        
        // Default is always current DB
        self.currentDatabase = publicDB
    }
    
    open func initializeRecord() {
        self.record = CKRecord(recordType: self.recordType)
    }
    
    open func encode() -> Data? {
        if let record = self.record {
            let archivedObject = NSKeyedArchiver.archivedData(withRootObject: record)
            return archivedObject
        }
        
        return nil
    }
    
    open func decode(_ data:Data) -> ROCloudModel? {
        if let record = NSKeyedUnarchiver.unarchiveObject(with: data) as? CKRecord {
            self.record = record
            return self
        } else {
            return nil
        }
    }
}

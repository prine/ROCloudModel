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

public class ROCloudModel {
    
    public var recordType:String = ""
    public var record:CKRecord?
    public var currentDatabase:CKDatabase
    
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    
    var references = Dictionary<String, CKReference>()
    var referenceLists = Dictionary<String, Array<CKReference>>()
    
    public required init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        
        // Default is always current DB
        self.currentDatabase = publicDB
    }
    
    public func initializeRecord() {
        self.record = CKRecord(recordType: self.recordType)
    }
    
    public func encode() -> NSData? {
        if let record = self.record {
            let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(record)
            return archivedObject
        }
        
        return nil
    }
    
    public func decode(data:NSData) -> ROCloudModel? {
        if let record = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? CKRecord {
            self.record = record
            return self
        } else {
            return nil
        }
    }
}

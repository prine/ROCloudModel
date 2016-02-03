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
    
    let cachingEnabled:Bool = false
    
    var references = Dictionary<String, CKReference>()
    var referneceLists = Dictionary<String, Array<CKReference>>()
    
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
}

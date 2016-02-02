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

class ROCloudModel {
    
    var recordType:String = ""
    var record:CKRecord?
    var currentDatabase:CKDatabase
    
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    
    let cachingEnabled:Bool = false
    
    var references = Dictionary<String, CKReference>()
    var referneceLists = Dictionary<String, Array<CKReference>>()
    
    required init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        
        // Default is always current DB
        self.currentDatabase = publicDB
    }
    
    func initializeRecord() {
        self.record = CKRecord(recordType: self.recordType)
    }
}

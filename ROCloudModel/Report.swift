//
//  Report.swift
//  CloudKitTest
//
//  Created by Robin Oster on 01/02/16.
//  Copyright © 2016 Prine Development. All rights reserved.
//

import Foundation
import CloudKit

class Report : ROCloudModel {
    
    required init() {
        super.init()
        self.recordType = "Reports"
        super.initializeRecord()
    }
    
    convenience init(name:String, title:String) {
        self.init()
        
        self.name = name
        self.title = title
    }
    
    var name:String {
        get {
            return self.record?["name"] as? String ?? ""
        }
        
        set(value) {
            self.record?["name"] = value as CKRecordValue?
        }
    }
    
    var title:String {
        get {
            return self.record?["title"] as? String ?? ""
        }
        
        set(value) {
            self.record?["title"] = value as CKRecordValue?
        }
    }
    
    
    var stringLists:Array<String> {
        get {
            return self.record?["stringLists"] as? Array<String> ?? []
        }
        
        set(value) {
            self.record?["stringLists"] = value as CKRecordValue?
        }
    }
}

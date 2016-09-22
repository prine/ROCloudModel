//
//  Post.swift
//  CloudKitTest
//
//  Created by Robin Oster on 01/02/16.
//  Copyright © 2016 Prine Development. All rights reserved.
//

import Foundation
import CloudKit

class Post : ROCloudModel {
    
    required init() {
        super.init()
        self.recordType = "Posts"
        
        super.initializeRecord()
    }
    
    convenience init(title:String, report:Report? = nil) {
        self.init()
        
        self.title = title
        self.report = report
    }
    
    var title:String {
        get {
            return self.record?["title"] as? String ?? ""
        }
        
        set(value) {
            self.record?["title"] = value as CKRecordValue?
        }
    }
    
    var report:Report? {
        get {
            return fetchReferenceSynchronous("report")
        }
        
        set(value) {
            self.setReferenceValue("report", value: value)
        }
    }
   
    // Reference
    func report(_ callback:@escaping (_ report:Report) -> ()) {
        fetchReference("report") { (report:Report) -> () in
            callback(report)
        }
    }
    
    // Reference List
    func reports(_ callback:@escaping (_ reports:Array<Report>) -> ()) {
        fetchReferenceArray("reports") { (reports:Array<Report>) -> () in
            callback(reports)
        }
    }
}

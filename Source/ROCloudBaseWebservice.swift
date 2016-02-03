//
//  PostWebservice.swift
//  CloudKitTest
//
//  Created by Robin Oster on 01/02/16.
//  Copyright © 2016 Prine Development. All rights reserved.
//

import Foundation
import CloudKit

public class ROCloudBaseWebservice<T:ROCloudModel> {
    
    var model:T = T()
    
    public init() {
        
    }
    
    public func load(predicate:NSPredicate? = nil, sort:NSSortDescriptor? = nil, callback:(data:Array<T>) -> ()) {
        let predicate = predicate ?? NSPredicate(value: true)
        let sort = sort ?? NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: model.recordType, predicate: predicate)
        
        query.sortDescriptors = [sort]
        
        model.currentDatabase.performQuery(query, inZoneWithID: nil) { results, error in
            if error != nil {
                callback(data: Array<T>())
            } else {
                var records = Array<T>()
                
                if let results = results {
                    for record in results {
                        let cloudModel = T()
                        cloudModel.record = record
                        records.append(cloudModel)
                    }
                    
                    if self.model.cachingEnabled {
                        // Store data persistent
                    }
                    
                    callback(data: records)
                }
            }
        }
    }
    
    public func loadByRecordName(recordName:String, callback:(cloudModel:T?) -> ()) {
        model.currentDatabase.fetchRecordWithID(CKRecordID(recordName: recordName)) { (record, error) -> Void in
            if error == nil {
                let cloudModel = T()
                cloudModel.record = record
                
                print("Fetch record by name: \(record?.recordID)")
                
                callback(cloudModel: cloudModel)
            } else {
                print("Something went wrong fetching the record: \(recordName) \(error)")
                callback(cloudModel: nil)
            }
        }
    }
    
    public func save(cloudModel:T, callback:(success:Bool, error:NSError?, reportID:CKRecordID?) -> ()) {
        if let cloudModelRecord = cloudModel.record {
            self.model.currentDatabase.saveRecord(cloudModelRecord) { (record, error) -> Void in
                if error == nil {
                    cloudModel.record = record
                    
                    // Successful
                    callback(success: true, error: error, reportID: record?.recordID)
                } else {
                    callback(success: false, error: error, reportID: record?.recordID)
                }
            }
        }
    }
    
    public func delete(cloudModel:T, callback:(success:Bool, error:NSError?) -> ()) {
        if let cloudModelRecordID = cloudModel.record?.recordID {
            
            print("Record id: \(cloudModelRecordID)")
            
            model.currentDatabase.deleteRecordWithID(cloudModelRecordID) { (recordID, error) -> Void in
                if error == nil {
                    print("Deleted successfully: \(cloudModelRecordID) \(recordID)")
                } else {
                    print("ERROR: \(error)")
                    print("Could not delete model: \(cloudModelRecordID) \(recordID)")
                }
            }
        }
    }
}

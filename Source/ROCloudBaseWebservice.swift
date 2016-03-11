//
//  PostWebservice.swift
//  CloudKitTest
//
//  Created by Robin Oster on 01/02/16.
//  Copyright © 2016 Prine Development. All rights reserved.
//

import Foundation
import CloudKit
import ROConcurrency

public class ROCloudBaseWebservice<T:ROCloudModel> {
    
    public var caching:Bool = false
    public var localCache = LocalCache<T>()
    
    var model:T = T()

    public init() {
        localCache.key = model.recordType
    }
    
    public func load(predicate:NSPredicate? = nil, sort:NSSortDescriptor? = nil, callback:(data:Array<T>) -> ()) {
        let predicate = predicate ?? NSPredicate(value: true)
        let sort = sort ?? NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: model.recordType, predicate: predicate)
        
        query.sortDescriptors = [sort]
        
        let cancable = Delay.delayCall(0.5) { () -> () in
            // First return offline data
            if self.caching {
                callback(data:self.localCache.loadData())
            }
        }
        
        // Then return online data
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
                    
                    if self.caching {
                        // Store data per sistent
                        self.localCache.storeData(records)
                    }
                    
                    // If the online data is retrieved before the delay timer runs out cancel the offline data and only return the online data
                    Delay.cancelDelayCall(cancable)
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
                
                callback(cloudModel: cloudModel)
            } else {
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
            model.currentDatabase.deleteRecordWithID(cloudModelRecordID) { (recordID, error) -> Void in
                callback(success: error == nil, error: error)
            }
        }
    }
}

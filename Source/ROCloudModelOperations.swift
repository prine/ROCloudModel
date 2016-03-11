//
//  CloudModelCRUD.swift
//  CloudKitTest
//
//  Created by Robin Oster on 02/02/16.
//  Copyright © 2016 Prine Development. All rights reserved.
//

import Foundation
import CloudKit
import ROConcurrency

public extension ROCloudModel {
    
    public func save(callback:(success:Bool, error:NSError?, record:CKRecord?) -> ()) {
        
        // FIXME: Rewrite that it can handle more than one save at the same time
        if let record = self.record {
            self.currentDatabase.saveRecord(record, completionHandler: { (record, error) -> Void in
                callback(success: error == nil, error: error, record: record)
            })
        }
    }
    
    public func saveDeep(callback:(success:Bool, error:NSError?, recordID:CKRecordID?) -> ()) {
        if let record = record {
            self.currentDatabase.saveRecord(record, completionHandler: { (record, error) -> Void in
                if error == nil {
                    // Successful
                    if let recordID = record?.recordID {
                        callback(success: true, error: error, recordID: recordID)
                        return
                    }
    
                    callback(success: false, error: error, recordID: nil)
                }
            })
        }
    }
    
    public func setReferenceValue<T:ROCloudModel>(referenceName:String, value:T?) {
        if let givenRecord = value?.record {
            self.record?[referenceName] = CKReference(record: givenRecord, action: CKReferenceAction.None)
        }
    }
    
    public func fetchReferenceSynchronous<T:ROCloudModel>(referenceName:String) -> T? {

        var retrievedCloudModel:T?
        
        let semaphore = dispatch_semaphore_create(0)
        
        self.fetchReference(referenceName) { (cloudModel:T) -> () in
            retrievedCloudModel = cloudModel
            dispatch_semaphore_signal(semaphore)
        }
        
        let timeout = dispatch_time(DISPATCH_TIME_NOW, 1000*1000*1000*5)
        if (dispatch_semaphore_wait(semaphore, timeout) != 0) {
            SynchronizedLogger.sharedInstance.log("Semaphore time out received")
        }
        
        return retrievedCloudModel
    }

    
    public func fetchReference<T:ROCloudModel>(referenceName:String, callback:(cloudModel:T) -> ()) {
        if let reference = self.record?[referenceName] as? CKReference {
            
            self.currentDatabase.fetchRecordWithID(reference.recordID, completionHandler: { (record, error) -> Void in
                let cloudModel = T()
                cloudModel.record = record
                
                // Store reference locally
                self.references.updateValue(reference, forKey: referenceName)
                
                callback(cloudModel: cloudModel)
            })
        }
    }
    
    public func fetchReferenceArray<T:ROCloudModel>(referenceName:String, callback:(cloudModels:Array<T>) -> ()) {
        if let references = self.record?[referenceName] as? Array<CKReference> {
            
            var recordIDs = Array<CKRecordID>()
            
            for reference in references {
                let recordID = reference.recordID
                recordIDs.append(recordID)
            }
            
            let fetchOperation = CKFetchRecordsOperation(recordIDs: recordIDs)
            
            fetchOperation.fetchRecordsCompletionBlock = {
                records, error in
                if error != nil {
                    print("\(error)")
                } else {
                    if let records = records {
                        
                        var cloudModels = Array<T>()
                        var dict = Dictionary<CKRecordID, T>()
                        
                        for (recordID, record) in records {
                            // Generate empty cloud model and set the record
                            let cloudModel = T()
                            cloudModel.record = record
                            
                            dict.updateValue(cloudModel, forKey: recordID)
                        }
                        
                        // Fetch records does not return all objects if there are duplicate recordIds
                        // Therefor we need to loop again over all IDs and use the already fetched records in the lookup dictionary
                        for recordID in recordIDs {
                            if let cloudModel = dict[recordID] {
                                cloudModels.append(cloudModel)
                            }
                        }
                        
                        callback(cloudModels: cloudModels)
                    }
                }
            }
            
            self.currentDatabase.addOperation(fetchOperation)
        }
    }

}
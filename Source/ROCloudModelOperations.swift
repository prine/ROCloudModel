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
    
    public func save(_ callback:@escaping (_ success:Bool, _ error:Error?, _ record:CKRecord?) -> ()) {
        
        // FIXME: Rewrite that it can handle more than one save at the same time
        if let record = self.record {
            self.currentDatabase.save(record, completionHandler: { (record, error) in
                callback(error == nil, error, record)
            })
        }
    }
    
    public func saveDeep(_ callback:@escaping (_ success:Bool, _ error:NSError?, _ recordID:CKRecordID?) -> ()) {
        if let record = record {
            self.currentDatabase.save(record, completionHandler: { (record, error) -> Void in
                if error == nil {
                    // Successful
                    if let recordID = record?.recordID {
                        callback(true, error as NSError?, recordID)
                        return
                    }
    
                    callback(false, error as NSError?, nil)
                }
            })
        }
    }
    
    public func setReferenceValue<T:ROCloudModel>(_ referenceName:String, value:T?) {
        if let givenRecord = value?.record {
            self.record?[referenceName] = CKReference(record: givenRecord, action: CKReferenceAction.none)
        }
    }
    
    public func fetchReferenceSynchronous<T:ROCloudModel>(_ referenceName:String) -> T? {

        var retrievedCloudModel:T?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        self.fetchReference(referenceName) { (cloudModel:T) -> () in
            retrievedCloudModel = cloudModel
            semaphore.signal()
        }
        
        let timeout = DispatchTime.now() + Double(1000*1000*5) / Double(NSEC_PER_SEC)
        if (semaphore.wait(timeout: timeout) != DispatchTimeoutResult.timedOut) {
            SynchronizedLogger.sharedInstance.log("Semaphore time out received")
        }
        
        return retrievedCloudModel
    }

    
    public func fetchReference<T:ROCloudModel>(_ referenceName:String, callback:@escaping (_ cloudModel:T) -> ()) {
        if let reference = self.record?[referenceName] as? CKReference {
            
            self.currentDatabase.fetch(withRecordID: reference.recordID, completionHandler: { (record, error) -> Void in
                let cloudModel = T()
                cloudModel.record = record
                
                // Store reference locally
                self.references.updateValue(reference, forKey: referenceName)
                
                callback(cloudModel)
            })
        }
    }
    
    public func fetchReferenceArray<T:ROCloudModel>(_ referenceName:String, callback:@escaping (_ cloudModels:Array<T>) -> ()) {
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
                        
                        callback(cloudModels)
                    }
                }
            }
            
            self.currentDatabase.add(fetchOperation)
        }
    }

}

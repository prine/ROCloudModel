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
import SystemConfiguration


public enum DataSource {
    case online
    case offline
}

open class ROCloudBaseWebservice<T:ROCloudModel> {
    
    open var localCache = LocalCache<T>()
    
    var model:T = T()
    
    var fetchedRecords = Array<T>()

    public init() {
        localCache.defaultKey = model.recordType
    }
    
    open func load(_ predicate:NSPredicate? = nil, sortDescriptors:Array<NSSortDescriptor>? = nil, amountRecords:Int? = nil, desiredKeys:Array<String>? = nil, callback:@escaping (_ data:Array<T>) -> ()) {
        let predicate = predicate ?? NSPredicate(value: true)
        
        let query = CKQuery(recordType: model.recordType, predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        // If sort descriptors are a
        if let sortDescriptors = sortDescriptors {
            query.sortDescriptors = sortDescriptors
        }
        
        if let amountRecords = amountRecords {
            operation.resultsLimit = amountRecords
        }

        if let desiredKeys = desiredKeys {
            operation.desiredKeys = desiredKeys
        }
        
        self.fetchedRecords = Array<T>()
        
        operation.recordFetchedBlock = self.fetchedAsRecord
        
        operation.queryCompletionBlock = { (cursor, error) in
            print(error.debugDescription)
            self.retrieveNextRecords(cursor, error:error, records:self.fetchedRecords, callback: callback)
        }
        
        self.model.currentDatabase.add(operation)
    }
    
    fileprivate func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }

    
    fileprivate func retrieveNextRecords(_ cursor:CKQueryCursor?, error:Error?, records:Array<T>, callback:@escaping (_ records:Array<T>) -> ()) {
        if let cursor = cursor {
            // There is more data to fetch
            let moreWork = CKQueryOperation(cursor: cursor)
            moreWork.recordFetchedBlock = self.fetchedAsRecord
            moreWork.queryCompletionBlock =  { (cursor, error) in
                self.retrieveNextRecords(cursor, error:error, records:self.fetchedRecords, callback: callback)
            }

            if self.isConnectedToNetwork() {
                self.model.currentDatabase.add(moreWork)
            }
        } else {
            callback(self.fetchedRecords)
        }
    }
    
    fileprivate func fetchedAsRecord(_ record:CKRecord!) {
        let cloudModel = T()
        cloudModel.record = record
        fetchedRecords.append(cloudModel)
    }
    
    open func loadWithCache(_ predicate:NSPredicate? = nil, sortDescriptors:Array<NSSortDescriptor>? = nil, amountRecords:Int? = nil, desiredKeys:Array<String>? = nil, cachingKey:String? = nil, callback:@escaping (_ data:Array<T>, _ dataSource:DataSource) -> ()) {
        
        Delay.delayCall(0.5) { () -> () in
            // First return offline data
            callback(self.localCache.loadData(cachingKey), DataSource.offline)
        }
        
        self.load(predicate, sortDescriptors: sortDescriptors, amountRecords: amountRecords, desiredKeys: desiredKeys, callback: { (data) in
            // Store data per sistent
            self.localCache.storeData(data, cachingKey: cachingKey)
            
            // If the online data is retrieved before the delay timer runs out cancel the offline data and only return the online data
            // Delay.cancelDelayCall(cancable) FIXME (Cancelable requests are currently not supported in the ROConcurrency framework)
            
            callback(data, DataSource.online)
        })
    }

    
    open func loadByRecordName(_ recordName:String, callback:@escaping (_ cloudModel:T?) -> ()) {
        model.currentDatabase.fetch(withRecordID: CKRecordID(recordName: recordName)) { (record, error) -> Void in
            if error == nil {
                let cloudModel = T()
                cloudModel.record = record
                
                callback(cloudModel)
            } else {
                callback(nil)
            }
        }
    }
    
    open func save(_ cloudModel:T, callback:@escaping (_ success:Bool, _ error:NSError?, _ reportID:CKRecordID?) -> ()) {
        if let cloudModelRecord = cloudModel.record {
            self.model.currentDatabase.save(cloudModelRecord, completionHandler: { (record, error) -> Void in
                if error == nil {
                    cloudModel.record = record
                    
                    // Successful
                    callback(true, error as NSError?, record?.recordID)
                } else {
                    callback(false, error as NSError?, record?.recordID)
                }
            }) 
        }
    }
    
    open func delete(_ cloudModel:T, callback:@escaping (_ success:Bool, _ error:NSError?) -> ()) {
        if let cloudModelRecordID = cloudModel.record?.recordID {
            model.currentDatabase.delete(withRecordID: cloudModelRecordID) { (recordID, error) -> Void in
                callback(error == nil, error as NSError?)
            }
        }
    }
}

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
    case ONLINE
    case OFFLINE
}

public class ROCloudBaseWebservice<T:ROCloudModel> {
    
    public var localCache = LocalCache<T>()
    
    var model:T = T()
    
    var fetchedRecords = Array<T>()

    public init() {
        localCache.defaultKey = model.recordType
    }
    
    public func load(predicate:NSPredicate? = nil, sortDescriptors:Array<NSSortDescriptor>? = nil, amountRecords:Int? = nil, desiredKeys:Array<String>? = nil, callback:(data:Array<T>) -> ()) {
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
            self.retrieveNextRecords(cursor, error:error, records:self.fetchedRecords, callback: callback)
        }
        
        self.model.currentDatabase.addOperation(operation)
    }
    
    private func retrieveNextRecords(cursor:CKQueryCursor?, error:NSError?, records:Array<T>, callback:(records:Array<T>) -> ()) {
        if let cursor = cursor {
            // There is more data to fetch
            let moreWork = CKQueryOperation(cursor: cursor)
            moreWork.recordFetchedBlock = self.fetchedAsRecord
            moreWork.queryCompletionBlock =  { (cursor, error) in
                self.retrieveNextRecords(cursor, error:error, records:self.fetchedRecords, callback: callback)
            }

            if self.isConnectedToNetwork() {
                self.model.currentDatabase.addOperation(moreWork)
            }
        } else {
            callback(records: self.fetchedRecords)
        }
    }
    
    private func fetchedAsRecord(record:CKRecord!) {
        let cloudModel = T()
        cloudModel.record = record
        fetchedRecords.append(cloudModel)
    }
    
    public func loadWithCache(predicate:NSPredicate? = nil, sortDescriptors:Array<NSSortDescriptor>? = nil, amountRecords:Int? = nil, desiredKeys:Array<String>? = nil, cachingKey:String? = nil, callback:(data:Array<T>, dataSource:DataSource) -> ()) {
        
        let cancable = Delay.delayCall(0.5) { () -> () in
            // First return offline data
            callback(data:self.localCache.loadData(cachingKey), dataSource: DataSource.OFFLINE)
        }
        
        self.load(predicate, sortDescriptors: sortDescriptors, amountRecords: amountRecords, desiredKeys: desiredKeys, callback: { (data) in
            
            print("COUNT: \(data.count)")
            
            // Store data per sistent
            self.localCache.storeData(data, cachingKey: cachingKey)
            
            // If the online data is retrieved before the delay timer runs out cancel the offline data and only return the online data
            Delay.cancelDelayCall(cancable)
            
            callback(data: data, dataSource: DataSource.ONLINE)
        })
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
    
    private func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags.ConnectionAutomatic
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

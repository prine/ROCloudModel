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

public class ROCloudBaseWebservice<T:ROCloudModel> {
    
    public var caching:Bool = false
    public var localCache = LocalCache<T>()
    
    var model:T = T()

    public init() {
        localCache.key = model.recordType
    }
    
    public func load(predicate:NSPredicate? = nil, sort:NSSortDescriptor? = nil, amountRecords:Int? = nil, desiredKeys:Array<String>? = nil, callback:(data:Array<T>) -> ()) {
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
        
        let operation = CKQueryOperation(query: query)
        
        if let amountRecords = amountRecords {
            operation.resultsLimit = amountRecords
        }
        
        if let desiredKeys = desiredKeys {
            operation.desiredKeys = desiredKeys
        }
        
        var records = Array<T>()
        
        operation.recordFetchedBlock = { (record) in
            let cloudModel = T()
            cloudModel.record = record
            records.append(cloudModel)
        }
        
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            if error != nil {
                callback(data: Array<T>())
                return
            }
            
            if self.caching {
                // Store data per sistent
                self.localCache.storeData(records)
            }
            
            // If the online data is retrieved before the delay timer runs out cancel the offline data and only return the online data
            Delay.cancelDelayCall(cancable)
            callback(data: records)
        }
        
        if self.isConnectedToNetwork() {
            model.currentDatabase.addOperation(operation)
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

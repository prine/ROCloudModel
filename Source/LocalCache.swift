//
//  LocalCache.swift
//  ROCloudModel
//
//  Created by Robin Oster on 11/03/16.
//  Copyright © 2016 Prine Development. All rights reserved.
//

import Foundation

public class LocalCache<T:ROCloudModel> {
    
    var userDefaults = NSUserDefaults.standardUserDefaults()
    var key = "localCache.DefaultKey"
    
    public func storeData<T:ROCloudModel>(data:Array<T>) {
        
        var serializableObjects = Array<NSData>()
        
        for model in data {
            if let offlineObject = model.encode() {
                serializableObjects.append(offlineObject)
            }
        }
        
        userDefaults.setObject(serializableObjects, forKey: key)
        userDefaults.synchronize()
    }
    
    public func loadData<T:ROCloudModel>() -> Array<T> {
        
        var models = Array<T>()
        
        if let serializedObjects = userDefaults.objectForKey(key) as? Array<NSData> {
            for serializeObject in serializedObjects {
                
                let cloudModel = T()
                
                if let cloudModel = cloudModel.decode(serializeObject) as? T {
                    models.append(cloudModel)
                }
            }
            
            return models
        } else {
            return []
        }
    }
    
    public func decode<T:ROCloudModel>(data:NSData) -> Array<T> {
        if let models = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Array<T> {
            return models
        } else {
            return []
        }
    }
}
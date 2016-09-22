//
//  LocalCache.swift
//  ROCloudModel
//
//  Created by Robin Oster on 11/03/16.
//  Copyright © 2016 Prine Development. All rights reserved.
//

import Foundation

open class LocalCache<T:ROCloudModel> {
    
    var userDefaults = UserDefaults.standard
    var defaultKey = "localCache.DefaultKey"
    
    open func storeData<T:ROCloudModel>(_ data:Array<T>, cachingKey:String? = nil) {
        
        var serializableObjects = Array<Data>()
        
        for model in data {
            if let offlineObject = model.encode() {
                serializableObjects.append(offlineObject as Data)
            }
        }
        
        userDefaults.set(serializableObjects, forKey: cachingKey ?? defaultKey)
        userDefaults.synchronize()
    }
    
    open func loadData<T:ROCloudModel>(_ cachingKey:String? = nil) -> Array<T> {
        
        var models = Array<T>()
        
        if let serializedObjects = userDefaults.object(forKey: cachingKey ?? defaultKey) as? Array<Data> {
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
    
    open func decode<T:ROCloudModel>(_ data:Data) -> Array<T> {
        if let models = NSKeyedUnarchiver.unarchiveObject(with: data) as? Array<T> {
            return models
        } else {
            return []
        }
    }
}

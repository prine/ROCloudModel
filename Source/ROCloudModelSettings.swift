//
//  ROCloudModelSettings.swift
//  ROCloudModel
//
//  Created by Robin Oster on 15/12/16.
//  Copyright © 2016 Prine Development. All rights reserved.
//

import Foundation
import CloudKit

open class ROCloudModelSettings {
    
    open var container = CKContainer.default()
    
    private init() {
        // Make constructor private
    }
    
    open static let sharedInstance : ROCloudModelSettings = {
        let instance = ROCloudModelSettings()
        return instance
    }()
}

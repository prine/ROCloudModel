//
//  ViewController.swift
//  CloudKitTest
//
//  Created by Robin Oster on 29/01/16.
//  Copyright © 2016 Prine Development. All rights reserved.
//

import UIKit
import CloudKit
import ROConcurrency

class ViewController: UIViewController {
    
    var postWebservice = ROCloudBaseWebservice<Post>()
    var reportWebservice = ROCloudBaseWebservice<Report>()

    override func viewDidLoad() {
        super.viewDidLoad()

        reportWebservice.load { (data) in
            print("Count: \(data.count)")
        }
        
        // self.createTestData()
        
        /*
        reportWebservice.loadWithCache(amountRecords: 2, cachingKey: "cache.limit2") { (data, dataSource) in
            for report in data {
                print("Data loaded from limit 2 \(dataSource)")
                print("REPORT (cache with limit 2): \(report.name)")
            }
        }
        
        let report = Report(name: "From Code", title: "Title from code")
        report.stringLists = ["asdasd", "asdasdasdasdasd", "asdasdasdas"]
        */
        
        /*
        report.save { (success, error, record) -> () in
            print("SUCCESS: \(success)")
        }
        
        reportWebservice.load { (data:Array<Report>) -> () in
            for report in data {
                print("\(report.stringLists)")
            }
        }
        */
    }
    
    func createTestData() {
        for i in 1...200 {
            let report = Report(name: "Testentry\(i)", title: "Title (\(i))")
            report.save({ (success, error, record) in
                print("Saved \(i) \(success)")
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


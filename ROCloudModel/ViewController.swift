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
        
        reportWebservice.load { (data) -> () in
            
            print("Received DATA from Webservice")
            for report in data {
                print("REPORT: \(report.name)")
            }
        }
        
        reportWebservice.loadWithCache { (data, dataSource) in
            print("Data loaded from \(dataSource)")
            print("Count data: \(data.count)")
        }
        
        reportWebservice.load(amountRecords: 1) { (data) in
            
            print("Received DATA from Webservice (RESULT LIMIT)")
            for report in data {
                print("REPORT: \(report.name)")
            }
        }
        
        let report = Report(name: "From Code", title: "Title from code")
        report.stringLists = ["asdasd", "asdasdasdasdasd", "asdasdasdas"]
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


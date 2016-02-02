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
        
        /*
        let query = CKQuery(recordType: "Reports", predicate: NSPredicate(value: true))
        
        let container = CKContainer.defaultContainer()
        let publicDB = container.publicCloudDatabase

        publicDB.performQuery(query, inZoneWithID: nil) { results, error in
            print("RESULTS \(results?.count)")
        }
        */


        let report = Report(name: "Robin", title: "Bla")
        report.save { (success, error, record) -> () in

            let post = Post(title: "TIIITLE NEEEW", report: report)
            post.save({ (success, error, record) -> () in
                print("Saving: \(success)")
            })
            
        }

        
        Lock.synchronize(self) { () -> () in
            sleep(2)
            print("before")
        }
        
        print("AFTER")

        self.postWebservice.load { (data) -> () in
            for post in data {
                dispatch_async(dispatch_get_main_queue(),{
                    print("Report: \(post.report?.title)")
                })
                
                post.report({ (report) -> () in
                    print("Report: \(report.title)")
                })
            }
        }
        
        self.reportWebservice.load { (data) -> () in
            for report in data {
                dispatch_async(dispatch_get_main_queue(),{
                    print(report.name)
                    print(report.title)
                })
            }
        }
    }
    
    func delete() {
        self.postWebservice.loadByRecordName("CA71C937-9767-4B3E-AC79-6CD566FA10A7") { (post) -> () in
            if let post = post {
                self.postWebservice.delete(post, callback: { (success, error) -> () in
                    if success {
                        print("Was successfully deleted")
                    }
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//
//  FoursquareProcesses.swift
//  vyse
//
//  Created by Stratazima on 6/5/15.
//  Copyright (c) 2015 Stratazima. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

typealias JSONParameters = [String: AnyObject]

class FoursquareProccesses {
    var callingViewController: UIViewController!
    var session = Session.sharedSession()
    var venues: JSON!
    var currentTask: Task?
    var indexedPath: Int?
    var currentValue: Int!


    func getData(parameters: Parameters, isSearching: Bool) {
        currentTask?.cancel()
        
        currentTask = session.venues.explore(parameters) {
            (result) -> Void in
            if result.response != nil {
                if let items = result.response?["groups"][0]["items"] {
                    
                    self.venues = items
                    
                    if isSearching {
                        self.callingViewController!.performSegueWithIdentifier("SearchSegue", sender: self.callingViewController!)
                    } else {
                        self.callingViewController!.performSegueWithIdentifier("VyseSegue", sender: self.callingViewController!)
                    }
                }
            }
        }
        currentTask?.start()
    }
    
    func writeToFile(isSaved:Bool) {
        
    }
    
    func readFromFile(isSaved:Bool){
        
    }
}

let sharedFoursquareProcesses = FoursquareProccesses()
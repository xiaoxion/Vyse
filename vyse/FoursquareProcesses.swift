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

class FoursquareProccesses {
    var callingViewController: UIViewController!
    var session = Session.sharedSession()
    var venues: JSON!
    var currentTask: Task?
    var indexedPath: Int?
    var currentValue: Int!
    
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
    let saveFile = "saved.json"
    let favoriteFile = "favorites.json"

    func getData(parameters: Parameters, isSearching: Bool) {
        currentTask?.cancel()
        
        currentTask = session.venues.explore(parameters) {
            (result) -> Void in
            if result.response != nil {
                if let warning = result.response?["warning"]["text"].string {
                    self.showWarningAlert(warning)
                } else {
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
        }
        currentTask?.start()
    }
    
    func showWarningAlert(warningString: String) {
        let alertController = UIAlertController(title: "Warning", message: warningString, preferredStyle: .Alert)
        let openSettings = UIAlertAction(title: "Try Again", style: .Default, handler: {
            (action) -> Void in
        })
        alertController.addAction(openSettings)
        callingViewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func checkReachibility() -> Bool {
        let reachability = Reachability.reachabilityForInternetConnection()
        
        return reachability.isReachable()
    }
    
    func likeVenueWith(id: String) {
        currentTask?.cancel()
        currentTask = session.venues.like(id, like: true, completionHandler: nil)
        currentTask?.start()
    }
    
    func tipVenueWith(id: String, tipText: String) {
        currentTask?.cancel()
        currentTask = session.tips.add(id, text: tipText, parameters: nil, completionHandler: nil)
        currentTask?.start()
    }
    
    func addToSaved() {
        if session.isAuthorized() {
            if checkReachibility() {
                session.venues
            } else {
                
            }
        } else {
            
        }
    }
    
    func retrieveFromSaved() {
        if session.isAuthorized() {
            if checkReachibility() {
                
            } else {
                
            }
        } else {
            
        }
    }
    
    func addToFavorites() {
        if session.isAuthorized() {
            if checkReachibility() {
                
            } else {
                
            }
        } else {
            
        }
    }
    
    func retrieveFromFavorites() {
        if session.isAuthorized() {
            if checkReachibility() {
                
            } else {
                
            }
        } else {
            
        }
    }
    
    func exists (file: String) -> Bool {
        return NSFileManager().fileExistsAtPath(documentsPath + file)
    }
    
    func read (file: String) {
        var venueArray: JSON
        if self.exists(file) {
            venueArray = JSON(data: NSData(contentsOfFile: documentsPath + file)!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            
            for venueArrays in venueArray {
                //ve
            }
        }
    }
    
    func write (file: String, content: String, encoding: NSStringEncoding = NSUTF8StringEncoding) -> Bool {
        return content.writeToFile(file, atomically: true, encoding: encoding, error: nil)
    }
}

let sharedFoursquareProcesses = FoursquareProccesses()
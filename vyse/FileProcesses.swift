//
//  FileProcesses.swift
//  vyse
//
//  Created by Stratazima on 6/13/15.
//  Copyright (c) 2015 Stratazima. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import JLToast

class FileProcesses {
    var removeInt = 0
    let saveFile = "saved.json"
    let favoriteFile = "favorites.json"
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
    
    // File Logic
    func exists(saving: Bool) -> Bool {
        if saving {
            return NSFileManager().fileExistsAtPath(documentsPath + "/" + saveFile)
        } else {
            return NSFileManager().fileExistsAtPath(documentsPath + "/" + favoriteFile)
        }
    }
    
    func readCreate(saving: Bool) {
        var file = favoriteFile
        if saving {
            file = saveFile
        }
        
        if self.exists(saving) {
            var venueArray = [JSON(data: NSData(contentsOfFile: documentsPath + "/" + file)!, options: nil, error: nil)]
            if venueArray == [] || venueArray[0].count == 0 {
                JLToast.makeText("Nothing to Show!").show()
                return
            }
            
            var daInteger = 0
            var counter = venueArray[0].count
            var tempArray = [JSON]()
            for venue in venueArray[0].arrayValue {
                var task = sharedFoursquareProcesses.session.venues.get(venue["id"].stringValue) {
                    (result) -> Void in
                    if result.response != nil {
                        tempArray.append(result.response!)
                    }
                    
                    if tempArray.count == venueArray[0].count {
                        sharedFoursquareProcesses.venues = JSON(tempArray)
                        sharedFoursquareProcesses.retrieveFromList = false
                        sharedFoursquareProcesses.retrieveFromLocal = true
                        sharedFoursquareProcesses.callingViewController!.performSegueWithIdentifier("SearchSegue", sender: sharedFoursquareProcesses.callingViewController!)
                    }
                }
                
                task.start()
                if daInteger == counter {
                    return
                }
                daInteger = daInteger + 1
            }
        } else {
            JLToast.makeText("Nothing to Show!").show()
        }
    }
    
    func read(saving: Bool) -> JSON? {
        var file = favoriteFile
        if saving {
            file = saveFile
        }
        
        return JSON(data: NSData(contentsOfFile: (documentsPath + "/" + file))!, options: nil, error: nil)
    }
    
    func write(saving: Bool, content: String, encoding: NSStringEncoding = NSUTF8StringEncoding) -> Bool {
        if saving {
            return content.writeToFile(documentsPath + "/" + saveFile, atomically: true, encoding: encoding, error: nil)
        } else {
            return content.writeToFile(documentsPath + "/" + favoriteFile, atomically: true, encoding: encoding, error: nil)
        }
    }
    
    func delete(saving: Bool) {
        var save = favoriteFile
        if saving {
            save = saveFile
        }
        
        NSFileManager.defaultManager().removeItemAtPath(documentsPath + "/" + save, error: nil)
    }
    
    func check(saving: Bool, id: String) -> Bool {
        if exists(saving) {
            if let jsonToCheck = read(saving) {
                var removalInt = 0
                for venue in jsonToCheck.arrayValue {
                    if venue["id"].stringValue == id {
                        removeInt = removalInt
                        return true
                    }
                    
                    removalInt++
                }
                return false
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func remove(saving: Bool) -> Bool {
        if let jsonToRemove = read(saving) {
            var mutableJSON = jsonToRemove.arrayValue
            mutableJSON.removeAtIndex(removeInt)
            
            return write(saving, content: mutableJSON.description, encoding: NSUTF8StringEncoding)
        }
        return false
    }
}

let sharedFileProcesses = FileProcesses()
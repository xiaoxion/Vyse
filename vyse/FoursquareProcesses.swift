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
import JLToast

class FoursquareProccesses {
    var callingViewController: UIViewController!
    var session = Session.sharedSession()
    var venues: JSON!
    var currentTask: Task?
    var indexedPath: Int?
    var currentValue: Int!
    var savedID: String!
    var favoriteID: String!
    var retrieveFromList = false
    var retrieveFromLocal = false

    func getData(parameters: Parameters, isSearching: Bool) {
        currentTask?.cancel()
        
        currentTask = session.venues.explore(parameters) {
            (result) -> Void in
            if result.error == nil {
                if result.response != nil {
                    if let warning = result.response?["warning"]["text"].string {
                        self.showWarningAlert(warning)
                    } else {
                        if let items = result.response?["groups"][0]["items"] {
                            
                            self.venues = items
                            self.retrieveFromList = false
                            self.retrieveFromLocal = false
                            if isSearching {
                                self.callingViewController!.performSegueWithIdentifier("SearchSegue", sender: self.callingViewController!)
                            } else {
                                self.callingViewController!.performSegueWithIdentifier("VyseSegue", sender: self.callingViewController!)
                            }
                        }
                    }
                }
            } else {
                JLToast.makeText("Error: Check Location and Try Again").show()
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
        if !Reachability.reachabilityForInternetConnection().isReachable() {
            JLToast.makeText("Need Internet Connection").show()
        }
        
        return Reachability.reachabilityForInternetConnection().isReachable()
    }
    
    func checkAuthorized() -> Bool {
        return session.isAuthorized()
    }
    
    func likeVenueWith(id: String, currentStatus: Bool) {
        currentTask?.cancel()
        var controller = callingViewController as! VyseViewController
        if currentStatus {
            currentTask = session.venues.like(id, like: false) {
                (result) -> Void in
                if result.error == nil {
                    if result.response != nil {
                        JLToast.makeText("Success!").show()
                        controller.likeFoursquare.setImage(UIImage(named: "thumb_up-50.png"), forState: UIControlState.Normal)
                        controller.likedFoursquare = false
                    }
                } else {
                    JLToast.makeText("Error").show()
                }
            }
        } else {
            currentTask = session.venues.like(id, like: true) {
                (result) -> Void in
                if result.error == nil {
                    if result.response != nil {
                        JLToast.makeText("Success!").show()
                        controller.likeFoursquare.setImage(UIImage(named: "thumb_up_filled-50.png"), forState: UIControlState.Normal)
                        controller.likedFoursquare = true
                    }
                } else {
                    JLToast.makeText("Error").show()
                }
            }
        }
        currentTask?.start()
    }
    
    func tipVenueWith(id: String, tipText: String) {
        currentTask?.cancel()
        currentTask = session.tips.add(id, text: tipText, parameters: nil, completionHandler: nil)
        currentTask?.start()
    }
    
    func checkLists() {
        if checkAuthorized() {
            if savedID != nil && favoriteID != nil {
                return
            }
            
            currentTask?.cancel()
            currentTask =  session.users.lists(userId: "self", parameters: [Parameter.group: "created"]) {
                (result) -> Void in
                    if result.response != nil {
                        if let items = result.response?["lists"]["items"].array {
                            var isSaved = false;
                            var isFavorite = false;
                            
                            // Check for listed items
                            for item in items {
                                if item["name"] == "VyséSaved" {
                                    isSaved = true
                                    self.savedID = item["id"].string
                                }
                                
                                if item["name"] == "VyséFavorites" {
                                    isFavorite = true
                                    self.favoriteID = item["id"].string
                                }
                                
                                if isSaved && isFavorite {
                                    return
                                }
                            }
                            
                            // if lists don't exists, make them
                            if !isSaved {
                                let task = self.session.lists.add("VyséSaved", text: "Vysé saved for later", parameters: nil) {
                                    (result) -> Void in
                                    if result.response != nil {
                                        self.savedID = result.response?["id"].string
                                    }
                                }
                                task.start()
                            }
                            
                            if !isFavorite {
                                let task = self.session.lists.add("VyséFavorites", text: "Vysé favorited", parameters: nil) {
                                    (result) -> Void in
                                    if result.response != nil {
                                        self.favoriteID = result.response?["id"].string
                                    }
                                }
                                task.start()
                            }
                        }
                    }
            }
            currentTask?.start()
        }
    }
    
    func addRemoveGet(getting: Bool, adding: Bool?, saving: Bool, venueID: String?) {
        //Getting Data Foursquare
        if checkAuthorized() {
            if checkReachibility() {
                var daListID: String!
                if saving {
                    daListID = savedID
                } else {
                    daListID = favoriteID
                }
                
                currentTask?.cancel()
                if getting {
                    currentTask = session.lists.get(daListID, parameters: nil) {
                        (result) -> Void in
                        if result.response != nil {
                            if let item = result.response?["list"]["listItems"]["items"] {
                                if item.count > 0 {
                                    self.venues = item
                                    self.retrieveFromList = true
                                    self.retrieveFromLocal = false
                                    self.callingViewController!.performSegueWithIdentifier("SearchSegue", sender: self.callingViewController!)
                                } else {
                                    JLToast.makeText("Nothing to Show").show()
                                }
                            }
                        }
                    }
                } else {
                    var controller = callingViewController as! VyseViewController
                    
                    if adding! {
                        currentTask = session.lists.additem(daListID, parameters: [Parameter.venueId: venueID!]) {
                            (result) -> Void in
                            if result.error == nil {
                                if result.response != nil {
                                    JLToast.makeText("Success!").show()
                                    if saving {
                                        controller.saveButton.setImage(UIImage(named: "save_as_filled-50.png"), forState: UIControlState.Normal)
                                        controller.addSaved = false
                                    } else {
                                        controller.favoriteButton.setImage(UIImage(named: "like_filled-50.png"), forState: UIControlState.Normal)
                                        controller.addFavorite = false
                                    }
                                }
                            } else {
                                JLToast.makeText("Error. Please try again later.").show()
                            }
                        }
                    } else {
                        currentTask = session.lists.deleteitem(daListID, parameters: [Parameter.venueId: venueID!]) {
                            (result) -> Void in
                            
                            if result.error == nil {
                                if result.response != nil {
                                    JLToast.makeText("Removed!").show()
                                    
                                    if saving {
                                        controller.saveButton.setImage(UIImage(named: "save_as-50.png"), forState: UIControlState.Normal)
                                        controller.addSaved = true
                                    } else {
                                        controller.favoriteButton.setImage(UIImage(named: "like-50.png"), forState: UIControlState.Normal)
                                        controller.addFavorite = true
                                    }
                                }
                            } else {
                                JLToast.makeText("Error. Please try again later.").show()
                            }
                        }
                    }
                }
                currentTask?.start()
            } else {
                JLToast.makeText("Check Internet Connection!").show()
            }
        }
        
        // Getting the Data Locally
        else {
            if getting {
                if sharedFileProcesses.exists(saving) {
                    sharedFileProcesses.readCreate(saving)
                } else {
                    JLToast.makeText("Nothing to Show").show()
                }
            } else {
                var daID: JSON  = ["id": venueID!]
                
                if sharedFileProcesses.exists(saving) {
                    if let JSONObject = sharedFileProcesses.read(saving) {
                        var mutableJSON = JSONObject.arrayValue
                        mutableJSON.append(daID)
                        var daData = mutableJSON.description
                        
                        if sharedFileProcesses.write(saving, content: mutableJSON.description, encoding: NSUTF8StringEncoding) {
                            JLToast.makeText("Saved!").show()
                        } else {
                            JLToast.makeText("Error Saving").show()
                        }
                    }
                } else {
                    var daJSON = [daID]
                    if sharedFileProcesses.write(saving, content: daJSON.description, encoding: NSUTF8StringEncoding) {
                        JLToast.makeText("Saved!").show()
                    } else {
                        JLToast.makeText("Error Saving").show()
                    }
                }
            }
        }
    }
    
    func exportLocal(data:JSON?, saving: Bool) {
        var daInteger = 0
        var counter = data!.array!.count - 1
        
        if counter == -1 {
            println("Nothing to Transfer")
            return
        }
        
        if sharedFoursquareProcesses.checkReachibility() {
            var listID = favoriteID
            if saving {
                listID = savedID
            }
            
            for dataVenue in data!.array! {
                var task = sharedFoursquareProcesses.session.lists.additem(listID, parameters: [Parameter.venueId: dataVenue["id"].stringValue], completionHandler: nil)
                
                task.start()
                
                if daInteger == counter {
                    sharedFileProcesses.delete(saving)
                    return
                }
                
                daInteger = daInteger + 1
            }
        }
    }
}

let sharedFoursquareProcesses = FoursquareProccesses()
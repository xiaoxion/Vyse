//
//  ListViewController.swift
//  vyse
//
//  Created by Stratazima on 5/26/15.
//  Copyright (c) 2015 Stratazima. All rights reserved.
//

import UIKit
import SwiftyJSON

class ListViewController: UITableViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sharedFoursquareProcesses.venues == nil {
            return 0
        }
        return sharedFoursquareProcesses.venues.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> FoodCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! FoodCell
        let objectVenue: JSON? = sharedFoursquareProcesses.venues[indexPath.row]["venue"]
        
        var ratingString: String
        
        if let ratingNumber = objectVenue?["rating"].number {
            ratingString = prefix(ratingNumber.stringValue, 3)
        } else {
            ratingString = "?.?"
        }
        
        var hoursString = "Closed Now"
        
        if let hours = objectVenue?["hours"] {
            if hours["isOpen"].boolValue {
                hoursString = "Open Now"
            }
            
            if hours["status"] != nil {
                hoursString = hours["status"].stringValue
            }
        } else {
            hoursString = "Hours Unknown"
        }
        
        
        if let venuePhoto = objectVenue?["featuredPhotos"]["items"][0].dictionary {
            var imageString = venuePhoto["prefix"]!.string! + "100x100" + venuePhoto["suffix"]!.string!
            let url = NSURL(string: imageString)
            
            getDataFromUrl(url!) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    cell.imageView!.image = UIImage(data: data!)
                }
            }
        } else {
            cell.imageView!.image = UIImage(named: "MainBackground.png")
        }
        
        cell.mainLabel.text = ratingString + " " + (objectVenue?["name"].string)!
        cell.subLabel.text = hoursString
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        sharedFoursquareProcesses.indexedPath = indexPath.row
        self.performSegueWithIdentifier("SearchVyseSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var segued = segue.destinationViewController as! VyseViewController
    }
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: NSData(data: data))
            }.resume()
    }
}

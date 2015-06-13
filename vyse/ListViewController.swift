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
    
    // Table Logic
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> FoodCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! FoodCell
        let objectVenue: JSON? = sharedFoursquareProcesses.venues[indexPath.row]["venue"]
        
        var ratingString: String
        
        // Check what Data is Present
        if sharedFoursquareProcesses.retrieveFromList {
            // Photo Logic
            if let venuePhoto = sharedFoursquareProcesses.venues[indexPath.row]["photo"].dictionary {
                var imageString = venuePhoto["prefix"]!.string! + "100x100" + venuePhoto["suffix"]!.string!
                let url = NSURL(string: imageString)
                
                getDataFromUrl(url!) { data in
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.mainImage.image = UIImage(data: data!)
                    }
                }
            } else {
                cell.mainImage.image = UIImage(named: "MainBackground.png")
            }

            // Set Rating and Date to Empty
            cell.ratingLabel.text = ""
            cell.subLabel.text = ""
        } else {
            // Photo Logic
            if let venuePhoto = objectVenue?["featuredPhotos"]["items"][0].dictionary {
                var imageString = venuePhoto["prefix"]!.string! + "100x100" + venuePhoto["suffix"]!.string!
                let url = NSURL(string: imageString)
                
                getDataFromUrl(url!) { data in
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.mainImage.image = UIImage(data: data!)
                    }
                }
            } else {
                cell.mainImage.image = UIImage(named: "MainBackground.png")
            }
            
            // Get Rating Data
            if let ratingNumber = objectVenue?["rating"].number {
                if ratingNumber < 5 {
                    cell.ratingLabel.backgroundColor = UIColor.redColor()
                } else if ratingNumber >= 5 &&  ratingNumber < 7 {
                    cell.ratingLabel.backgroundColor = UIColor.yellowColor()
                } else if ratingNumber >= 7 {
                    cell.ratingLabel.backgroundColor = UIColor.greenColor()
                }
                ratingString = prefix(ratingNumber.stringValue, 3)
            } else {
                cell.ratingLabel.backgroundColor = UIColor.whiteColor()
                ratingString = "?.?"
            }
            
            // Get Hours Data
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
            
            cell.ratingLabel.text = ratingString
            cell.subLabel.text = hoursString
        }
        
        // Get Name Data
        cell.mainLabel.text = (objectVenue?["name"].string)!
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        sharedFoursquareProcesses.indexedPath = indexPath.row
        self.performSegueWithIdentifier("SearchVyseSegue", sender: self)
    }
    
    // Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var segued = segue.destinationViewController as! VyseViewController
    }
    
    // Photo Data
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: NSData(data: data))
            }.resume()
    }
}

// Extension for Rating Colors
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

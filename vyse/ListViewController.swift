//
//  ListViewController.swift
//  vyse
//
//  Created by Stratazima on 5/26/15.
//  Copyright (c) 2015 Stratazima. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    var session: Session!
    var venues: [[String:AnyObject]]!
    var indexedPath: NSIndexPath!
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if venues == nil {
            return 0
        }
        return venues.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> FoodCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! FoodCell
        let object = venues![indexPath.row] as JSONParameters!
        let objectVenue = object["venue"] as? JSONParameters
        
        var miniInt:NSNumber? = objectVenue!["rating"] as? NSNumber
        if miniInt == nil {
            miniInt = 0
        }
        var hours = objectVenue!["hours"] as? JSONParameters
        var hoursString = "Closed Now"
        
        if hours != nil {
            if hours!["isOpen"] as! Bool {
                hoursString = "Open Now"
            }
            
            if hours!["status"] != nil {
                hoursString = hours!["status"] as! String
            }
        } else {
            hoursString = "Hours Unknown"
        }
        
        var objectPhotos: JSONParameters? = objectVenue!["featuredPhotos"] as? JSONParameters
    
        if objectPhotos != nil {
            
            var objectPhotoItem = objectPhotos!["items"] as? [JSONParameters]
            var ObjectFirstPhoto = objectPhotoItem![0] as JSONParameters
            var imageString = (ObjectFirstPhoto["prefix"] as? String)! + "100x100" + (ObjectFirstPhoto["suffix"] as? String)!
            let url = NSURL(string: imageString)
        
            getDataFromUrl(url!) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    cell.imageView!.image = UIImage(data: data!)
                }
            }
        }
        
        
        cell.mainLabel.text = prefix(miniInt!.stringValue, 3) + " " + (objectVenue!["name"] as? String)!
        cell.subLabel.text = hoursString
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        indexedPath = indexPath
        self.performSegueWithIdentifier("SearchVyseSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var segued = segue.destinationViewController as! VyseViewController
        
        segued.ifRecieving = true
        segued.venueObject = venues!
        segued.indexedPath = indexedPath!
    }
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: NSData(data: data))
            }.resume()
    }
}

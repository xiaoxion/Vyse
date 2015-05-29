//
//  ListViewController.swift
//  vyse
//
//  Created by Stratazima on 5/26/15.
//  Copyright (c) 2015 Stratazima. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    let restaurants = [["9.3 Italian Restaurant #1", "Open until 4:00PM"], ["9.2 Italian Place", "Open until 10:00PM"], ["8.7 The Italians", "Open Untill 9:00PM"], ["8.2 Little Italy", "Open Untill 2:00AM"], ["8.1 Italian Restaurant #2", "Open Untill 4:00PM"]]
    
    var indexedPath: NSIndexPath!
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> FoodCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! FoodCell
        let object = restaurants[indexPath.row]
        
        cell.mainLabel.text = object[0]
        cell.subLabel.text = object[1]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        indexedPath = indexPath
        self.performSegueWithIdentifier("SearchVyseSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var segued = segue.destinationViewController as! VyseViewController
        
        segued.ifRecieving = true;
        
        var string1 = restaurants[indexedPath.row][0]
        var index = advance(string1.startIndex, 4);
        
        segued.dataOne = string1.substringFromIndex(index)
        segued.dataTwo = restaurants[indexedPath.row][1]
    }
}

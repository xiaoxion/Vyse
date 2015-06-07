//
//  VyseViewController.swift
//  vyse
//
//  Created by Stratazima on 5/27/15.
//  Copyright (c) 2015 Stratazima. All rights reserved.
//

import UIKit
import SwiftyJSON

class VyseViewController:UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var mainTopContraint: NSLayoutConstraint!
    @IBOutlet weak var subTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftMainView: NSLayoutConstraint!
    @IBOutlet weak var rightMiainView: NSLayoutConstraint!
    
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var phoneNumber: UIButton!
    @IBOutlet weak var WebsiteURL: UIButton!
    @IBOutlet weak var addressLine: UILabel!
    @IBOutlet weak var cityStateZip: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var ratingNumber: UILabel!
    @IBOutlet weak var foodType: UILabel!
    
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var likeFoursquare: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var venueID: String!
    
    override func viewDidLoad() {
        if sharedFoursquareProcesses.indexedPath != nil {
            sharedFoursquareProcesses.currentValue = sharedFoursquareProcesses.indexedPath
        }
        
        addLogoToTitleBar()
        addGestureRecognizers()
        fillData()
        reenableHiddenContent()
    }
    
    func addGestureRecognizers() {
        var upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("swipeHandler:"))
        var downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("swipeHandler:"))
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("swipeHandler:"))
        
        upSwipe.direction = .Up
        downSwipe.direction = .Down
        rightSwipe.direction = .Right
        
        mainView.addGestureRecognizer(upSwipe)
        mainView.addGestureRecognizer(rightSwipe)
        subView.addGestureRecognizer(downSwipe)
    }
    
    func swipeHandler(sender: UISwipeGestureRecognizer) {
        if sender.direction == .Right {
            if sharedFoursquareProcesses.currentValue < sharedFoursquareProcesses.venues.count {
                sharedFoursquareProcesses.currentValue = sharedFoursquareProcesses.currentValue + 1
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.mainTopContraint.constant = 8
                    self.subTopConstraint.constant = 300
                    self.leftMainView.constant = 509
                    self.rightMiainView.constant = -509
                    self.mainView.layoutIfNeeded()
                    self.subView.layoutIfNeeded()
                    }, completion: {
                        (value:Bool) in
                        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
                            self.fillData()
                            self.leftMainView.constant = 9
                            self.rightMiainView.constant = 9
                            self.mainView.layoutIfNeeded()
                            }, completion: nil)
                })
            } else {
                
            }
        } else if sender.direction == .Up {
            UIView.animateWithDuration(0.75, delay: 0.0, options: .CurveEaseOut, animations: {
                self.mainTopContraint.constant = -80
                self.subTopConstraint.constant = -34
                self.mainView.layoutIfNeeded()
                self.subView.layoutIfNeeded()
            }, completion: nil)
        } else if sender.direction == .Down {
            UIView.animateWithDuration(0.75, delay: 0.0, options: .CurveEaseOut, animations: {
                self.mainTopContraint.constant = 8
                self.subTopConstraint.constant = 300
                self.mainView.layoutIfNeeded()
                self.subView.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    func addLogoToTitleBar() {
        let logoImage = UIImage(named: "Vyse.png")
        let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 36))
        logoView.contentMode = .ScaleAspectFit
        logoView.image = logoImage
        self.navigationItem.titleView = logoView
    }
    
    func fillData() {
        let objectVenue: JSON? = sharedFoursquareProcesses.venues[sharedFoursquareProcesses.currentValue]["venue"]
        
        // Get Image
        if let venuePhoto = objectVenue?["featuredPhotos"]["items"][0].dictionary {
            var imageString = venuePhoto["prefix"]!.string! + "300x300" + venuePhoto["suffix"]!.string!
            let url = NSURL(string: imageString)
            
            getDataFromUrl(url!) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    self.foodImage.image = UIImage(data: data!)
                }
            }
        } else {
            foodImage.image = UIImage(named: "MainBackground.png")
        }
        
        // Restaurant Name
        restaurantName.text = objectVenue?["name"].string
        
        // Restaurant Number if Any
        if let phone = objectVenue?["contact"]["formattedPhone"].string {
            phoneNumber.setTitle(phone, forState: UIControlState.Normal)
            phoneNumber.setTitle(objectVenue?["contact"]["phone"].string , forState: UIControlState.Selected)
        } else {
            phoneNumber.setTitle("None", forState: UIControlState.Normal)
            phoneNumber.userInteractionEnabled = false
        }
        
        // Restaurant Website if Any
        if let website = objectVenue?["url"].string {
            WebsiteURL.setTitle(website, forState: UIControlState.Normal)
        } else {
            WebsiteURL.setTitle("None", forState: UIControlState.Normal)
            WebsiteURL.userInteractionEnabled = false
        }
        
        // Input Location Data
        var locationStringAddress = ""
        var locationStringCityStateZip = ""
        if let addressLocation = objectVenue?["location"].dictionary {
            locationStringAddress = addressLocation["address"]!.string!
            locationStringCityStateZip = addressLocation["city"]!.string! + ", " + addressLocation["state"]!.string! + " " + addressLocation["postalCode"]!.string!
        } else {
            locationStringAddress = "Address"
            locationStringCityStateZip = "Unknown"
        }
        
        addressLine.text = locationStringAddress
        cityStateZip.text = locationStringCityStateZip
        
        // Open Data
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
        
        time.text = hoursString
        
        // Rating Information
        var ratingString: String
        
        if let ratingNum = objectVenue?["rating"].number {
            ratingString = prefix(ratingNum.stringValue, 3)
        } else {
            ratingString = "?.?"
        }
        
        ratingNumber.text = "Rating: " + ratingString
        
        // Category Information
        var categoryInfo = ""
        if let catInfo = objectVenue?["categories"][0]["name"].string {
            categoryInfo = "Type: " + catInfo
        } else {
            categoryInfo = "Type: Unknown"
        }
        
        foodType.text = categoryInfo
        
        venueID = objectVenue?["id"].string
    }
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: NSData(data: data))
            }.resume()
    }
    
    func reenableHiddenContent() {
        if sharedFoursquareProcesses.session.isAuthorized() {
            reviewTextView.hidden = false
            likeFoursquare.hidden = false
            submitButton.hidden = false
        }
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        var button = sender as? UIButton
        
        if button!.tag == 0 {
            
        } else if button!.tag == 1 {
            
        } else if button!.tag == 2 {
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://" + "8134849139")!)
        } else if button!.tag == 3 {
            UIApplication.sharedApplication().openURL(NSURL(string: (button?.titleLabel?.text)!)!)
        } else if button!.tag == 4 {
            sharedFoursquareProcesses.session.venues.like(venueID, like: true, completionHandler: nil)
        } else if button!.tag == 5 {
            sharedFoursquareProcesses.session.tips.add(venueID, text: reviewTextView.text, parameters: nil, completionHandler: nil)
        } else if button!.tag == 6 {
            
        } else if button!.tag == 7 {
            
        }
    }
}

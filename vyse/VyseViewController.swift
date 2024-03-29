//
//  VyseViewController.swift
//  vyse
//
//  Created by Stratazima on 5/27/15.
//  Copyright (c) 2015 Stratazima. All rights reserved.
//

import UIKit
import SwiftyJSON
import JLToast
import CoreLocation
import MapKit

class VyseViewController:UIViewController, UITextViewDelegate {
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
    @IBOutlet weak var outlineImage: UIImageView!
    
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var likeFoursquare: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var venueID: String!
    var number: String!
    var tutorialNeededRight = false
    var tutorialNeededUp = false
    var addSaved = true
    var addFavorite = true
    var likedFoursquare = false
    
    override func viewDidLoad() {
        if sharedFoursquareProcesses.indexedPath != nil {
            sharedFoursquareProcesses.currentValue = sharedFoursquareProcesses.indexedPath
        } else {
            sharedFoursquareProcesses.currentValue = 0
        }
        
        var data = NSMutableDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Data", ofType: "plist")!)
        if data?.objectForKey("isTutorialNeeded") as! Bool {
            tutorialNeededRight = true
            tutorialNeededUp = true
            outlineImage.image = UIImage(named: "VyseSwipeUp.png")
            data?.setObject(false, forKey: "isTutorialNeeded")
            data?.writeToFile(NSBundle.mainBundle().pathForResource("Data", ofType: "plist")!, atomically: false)
        }
        
        addLogoToTitleBar()
        addGestureRecognizers()
        fillData()
        reenableHiddenContent()
        
        if sharedFoursquareProcesses.checkAuthorized() && sharedFoursquareProcesses.checkReachibility() {
            sharedFoursquareProcesses.checkLists()
        }
    }
    
    // TextView
    func textViewDidBeginEditing(textView: UITextView) {
        reviewTextView.text = ""
    }
    
    // Gesture Logic
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
            if sharedFoursquareProcesses.currentValue < (sharedFoursquareProcesses.venues.count - 1) {
                sharedFoursquareProcesses.currentValue = sharedFoursquareProcesses.currentValue + 1
                
                if tutorialNeededRight {
                    tutorialNeededRight = false
                    if tutorialNeededUp {
                        outlineImage.image = UIImage(named: "VyseSwipeUp.png")
                    } else {
                        outlineImage.image = UIImage(named: "VyseOutline.png")
                    }
                }
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.mainTopContraint.constant = 8
                    self.subTopConstraint.constant = 300
                    self.leftMainView.constant = 509
                    self.rightMiainView.constant = -509
                    self.mainView.layoutIfNeeded()
                    self.subView.layoutIfNeeded()
                    }, completion: {
                        (value:Bool) in
                        
                        self.addSaved = true
                        self.addFavorite = true
                        self.likedFoursquare = false
                        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
                            self.fillData()
                            self.leftMainView.constant = 9
                            self.rightMiainView.constant = 9
                            self.mainView.layoutIfNeeded()
                            }, completion: nil)
                })
            } else {
                JLToast.makeText("No More Results").show()
            }
        } else if sender.direction == .Up {
            if tutorialNeededUp {
                tutorialNeededUp = false
                if tutorialNeededRight {
                    outlineImage.image = UIImage(named: "VyseSwipeRight.png")
                } else {
                    outlineImage.image = UIImage(named: "VyseOutline.png")
                }
            }
            UIView.animateWithDuration(0.45, delay: 0.0, options: .CurveEaseOut, animations: {
                self.mainTopContraint.constant = -80
                self.subTopConstraint.constant = -34
                self.mainView.layoutIfNeeded()
                self.subView.layoutIfNeeded()
            }, completion: nil)
        } else if sender.direction == .Down {
            UIView.animateWithDuration(0.45, delay: 0.0, options: .CurveEaseOut, animations: {
                self.mainTopContraint.constant = 8
                self.subTopConstraint.constant = 300
                self.mainView.layoutIfNeeded()
                self.subView.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    // Add Logo
    func addLogoToTitleBar() {
        let logoImage = UIImage(named: "Vyse.png")
        let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 36))
        logoView.contentMode = .ScaleAspectFit
        logoView.image = logoImage
        self.navigationItem.titleView = logoView
    }
    
    // Add Data to Views
    func fillData() {
        favoriteButton.setImage(UIImage(named: "like-50.png"), forState: UIControlState.Normal)
        saveButton.setImage(UIImage(named: "save_as-50.png"), forState: UIControlState.Normal)
        addSaved = true
        addFavorite = true
        
        if sharedFoursquareProcesses.retrieveFromList || sharedFoursquareProcesses.retrieveFromLocal {
            favoriteButton.hidden = true
            saveButton.hidden = true
        }
        
        let objectVenue: JSON? = sharedFoursquareProcesses.venues[sharedFoursquareProcesses.currentValue]["venue"]
        
        // Get Image
        if sharedFoursquareProcesses.retrieveFromList {
            if let venuePhoto = sharedFoursquareProcesses.venues[sharedFoursquareProcesses.currentValue]["photo"].dictionary {
                var imageString = venuePhoto["prefix"]!.string! + "300x198" + venuePhoto["suffix"]!.string!
                let url = NSURL(string: imageString)
                
                getDataFromUrl(url!) { data in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.foodImage.image = UIImage(data: data!)
                    }
                }
            } else {
                foodImage.image = UIImage(named: "MainBackground.png")
            }
            
        } else if sharedFoursquareProcesses.retrieveFromLocal {
            if let venuePhoto = sharedFoursquareProcesses.venues[sharedFoursquareProcesses.currentValue]["venue"]["bestPhoto"].dictionary {
                var imageString = venuePhoto["prefix"]!.string! + "300x198" + venuePhoto["suffix"]!.string!
                let url = NSURL(string: imageString)
                
                getDataFromUrl(url!) { data in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.foodImage.image = UIImage(data: data!)
                    }
                }
            } else {
                foodImage.image = UIImage(named: "MainBackground.png")
            }
        } else {
            if let venuePhoto = objectVenue?["featuredPhotos"]["items"][0].dictionary {
                var imageString = venuePhoto["prefix"]!.string! + "300x198" + venuePhoto["suffix"]!.string!
                let url = NSURL(string: imageString)
                
                getDataFromUrl(url!) { data in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.foodImage.image = UIImage(data: data!)
                    }
                }
            } else {
                foodImage.image = UIImage(named: "MainBackground.png")
            }
            
            // Rating Information
            var ratingString: String
            
            if let ratingNum = objectVenue?["rating"].number {
                ratingString = prefix(ratingNum.stringValue, 3)
                if count(ratingString) == 1 {
                    ratingString = ratingString + ".0"
                }
            } else {
                ratingString = "?.?"
            }
            
            ratingNumber.hidden = false
            ratingNumber.text = "Rating: " + ratingString
            
            // Get Save/Favorite Status
            if let reasonsObject = sharedFoursquareProcesses.venues[sharedFoursquareProcesses.currentValue]["reasons"]["items"][0].dictionary {
                if reasonsObject["summary"]?.string == "On: VyséFavorites" {
                    favoriteButton.setImage(UIImage(named: "like_filled-50.png"), forState: UIControlState.Normal)
                    addFavorite = false
                } else if reasonsObject["summary"]?.string == "On: VyséSaved" {
                    saveButton.setImage(UIImage(named: "save_as_filled-50.png") , forState: UIControlState.Normal)
                    addSaved = false
                }
            }
        }
        
        // Restaurant Name
        restaurantName.text = objectVenue?["name"].string
        
        // Restaurant Number if Any
        if let phone = objectVenue?["contact"]["formattedPhone"].string {
            phoneNumber.setTitle(phone, forState: UIControlState.Normal)
            number = objectVenue?["contact"]["phone"].string
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
        if let addressLocation = objectVenue?["location"]["formattedAddress"].arrayValue {
            locationStringAddress = addressLocation[0].string!
            
            if addressLocation.count > 1 {
                locationStringCityStateZip = addressLocation[1].string!
            } else {
                locationStringCityStateZip = ""
            }
        } else {
            locationStringAddress = "Address"
            locationStringCityStateZip = "Unknown"
        }
        
        addressLine.text = locationStringAddress
        cityStateZip.text = locationStringCityStateZip
        
        // Hours Data
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
        
        // Category Information
        var categoryInfo = ""
        if let catInfo = objectVenue?["categories"][0]["name"].string {
            categoryInfo = "Type: " + catInfo
        } else {
            categoryInfo = "Type: Unknown"
        }
        
        foodType.text = categoryInfo
        
        // Set Venue ID
        venueID = objectVenue?["id"].string
        
        
        // Check if locale is socailly approved
        if sharedFoursquareProcesses.checkAuthorized() {
            if let reason = sharedFoursquareProcesses.venues[sharedFoursquareProcesses.currentValue]["reasons"]["items"][0].dictionary {
                if !tutorialNeededRight || !tutorialNeededUp {
                    if reason["type"]!.stringValue == "social" {
                        outlineImage.image = UIImage(named: "VyseFriendOutline.png")
                    } else {
                        outlineImage.image = UIImage(named: "VyseOutline.png")
                    }
                }
            }
            
            // Get if current user likes place
            likedFoursquare = objectVenue!["like"].boolValue
            if likedFoursquare {
                likeFoursquare.setImage(UIImage(named: "thumb_up_filled-50.png"), forState: UIControlState.Normal)
                likedFoursquare = true
                
            }
        } else {
            if sharedFileProcesses.check(true, id: venueID) {
                saveButton.setImage(UIImage(named: "save_as_filled-50.png") , forState: UIControlState.Normal)
                addSaved = false
            } else if sharedFileProcesses.check(false, id: venueID) {
                favoriteButton.setImage(UIImage(named: "like_filled-50.png"), forState: UIControlState.Normal)
                addFavorite = false
            }
        }
    }
    
    // Get Image
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: NSData(data: data))
            }.resume()
    }
    
    // Reenable disabled content if Logged In
    func reenableHiddenContent() {
        if sharedFoursquareProcesses.session.isAuthorized() {
            reviewTextView.hidden = false
            likeFoursquare.hidden = false
            submitButton.hidden = false
        }
    }
    
    // MARK: Actionable Logic
    @IBAction func buttonPressed(sender: AnyObject) {
        var button = sender as? UIButton
        
        // Button Logic
        if button!.tag == 2 {
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://" + number)!)
        } else if button!.tag == 3 {
            UIApplication.sharedApplication().openURL(NSURL(string: (button?.titleLabel?.text)!)!)
        }
        
        // Like Content
        if sharedFoursquareProcesses.checkReachibility() {
            // Set Controller as Self for segues
            sharedFoursquareProcesses.callingViewController = self
            
            if button!.tag == 4 {
                sharedFoursquareProcesses.likeVenueWith(venueID, currentStatus:likedFoursquare);
            } else if button!.tag == 5 {
                sharedFoursquareProcesses.tipVenueWith(venueID, tipText: reviewTextView.text)
                reviewTextView.text = ""
                JLToast.makeText("Tip left!").show()
            }
            
            // Add/Remove Data
            else if button!.tag == 0 {
                if !addSaved && addFavorite {
                    JLToast.makeText("Cannot Favorite if Saved").show()
                    return
                }
                
                if sharedFoursquareProcesses.checkAuthorized() || addFavorite {
                    sharedFoursquareProcesses.addRemoveGet(false, adding:addFavorite, saving: false, venueID: venueID)
                } else {
                    if sharedFileProcesses.remove(false) {
                        JLToast.makeText("Removed").show()
                        favoriteButton.setImage(UIImage(named: "like-50.png"), forState: UIControlState.Normal)
                        addFavorite = true
                    } else {
                        JLToast.makeText("Error Removing").show()
                    }
                }
            } else if button!.tag == 1 {
                if !addFavorite && addSaved {
                    JLToast.makeText("Cannot Save if Favorited").show()
                    return
                }
                
                if sharedFoursquareProcesses.checkAuthorized() || addSaved {
                    sharedFoursquareProcesses.addRemoveGet(false, adding:addSaved, saving: true, venueID: venueID)
                } else {
                    if sharedFileProcesses.remove(true) {
                        JLToast.makeText("Removed!").show()
                        saveButton.setImage(UIImage(named: "save_as-50.png"), forState: UIControlState.Normal)
                        addSaved = true
                    } else {
                        JLToast.makeText("Error Removing").show()
                    }
                }
            }
            
            // Getting Data
            else if button!.tag == 6 {
                sharedFoursquareProcesses.addRemoveGet(true, adding:nil, saving: false, venueID: nil)
            } else if button!.tag == 7 {
                sharedFoursquareProcesses.addRemoveGet(true, adding:nil, saving: true, venueID: nil)
                sharedFoursquareProcesses.saveHeader = true
            }
        } else {
            JLToast.makeText("Error, check internet connection!").show()
        }
    }
}

//
//  ViewController.swift
//  vyse
//
//  Created by Stratazima on 5/20/15.
//  Copyright (c) 2015 Stratazima. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import JLToast

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, SessionAuthorizationDelegate, UITextFieldDelegate {
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var priceControl: UISegmentedControl!
    @IBOutlet weak var loggingButton: UIBarButtonItem!
    
    var selectedGenre = 0
    var locationManager: CLLocationManager!
    let distanceFormatter = MKDistanceFormatter()
    
    // Food Genres
    let pickerData = ["General", "Global", "American", "Latin", "European", "Asian", "Islands"]
    let generalData = ["Fast Food", "Coffee Shop", "Dessert Shop", "Steak House", "Seafood" , "Vegetarian", "Bakery", "Breakfast Spots", "Buffet"]
    let globalData = ["American", "Latin American", "European", "Asian", "African", "Indian"]
    let americanData = ["New American", "Southern", "Hawaiian", "BBQ Joint", "Burger Joint"]
    let latinData = ["Argentinian", "Brazilian", "Cuban", "Mexican", "Peruvian"]
    let europeanData = ["Austrian", "Eastern European", "English", "French", "German", "Greek", "Irish Pub", "Italian", "Mediterranean", "Modern European", "Portuguese", "Spanish", "Swiss"]
    let asianData = ["Chinese", "Filipino", "Japanese", "Sushi", "Korean", "Thai", "Vietnamese"]
    let islandsData = ["Australian", "Cajun / Creole"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationText.attributedPlaceholder = NSAttributedString(string: "i.e New York, NY", attributes: [NSForegroundColorAttributeName:UIColor(red: CGFloat(232/255.0), green: CGFloat(225/255.0), blue: CGFloat(196/255.0), alpha: CGFloat(1.0))])
        addLogoToTitleBar()
        locationManagerChecker()
        
        if sharedFoursquareProcesses.checkAuthorized() {
            loggingButton.image = nil
            loggingButton.title = "Log Out"
            
            if sharedFoursquareProcesses.checkReachibility() {
                sharedFoursquareProcesses.checkLists()
            }
        }
    }
    
    // Location Alert If Permissions is Denied
    func showNoPermissionsAlert() {
        let alertController = UIAlertController(title: "No permission", message: "Need Permission to retrieve your Location", preferredStyle: .Alert)
        let openSettings = UIAlertAction(title: "Open settings", style: .Default, handler: {
            (action) -> Void in
            let URL = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(URL!)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(openSettings)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Text Field Logic
    func textFieldDidBeginEditing(textField: UITextField) {
        locationText.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName:UIColor(red: CGFloat(232/255.0), green: CGFloat(225/255.0), blue: CGFloat(196/255.0), alpha: CGFloat(1.0))])
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Add Logo to Title Bar
    func addLogoToTitleBar() {
        let logoImage = UIImage(named: "Vyse.png")
        let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 36))
        logoView.contentMode = .ScaleAspectFit
        logoView.image = logoImage
        self.navigationItem.titleView = logoView
    }
    
    // Check for Location Access
    func locationManagerChecker() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            if status == CLAuthorizationStatus.AuthorizedWhenInUse {
                locationManager.startUpdatingLocation()
            }
        } else if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            showNoPermissionsAlert()
        }
    }
    
    // MARK: Picker Data
    // Picker Data and Logic
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return pickerData.count
        } else {
            switch selectedGenre {
            case 0:
                return generalData.count
            case 1:
                return globalData.count
            case 2:
                return americanData.count
            case 3:
                return latinData.count
            case 4:
                return europeanData.count
            case 5:
                return asianData.count
            case 6:
                return islandsData.count
                
            default:
                return 0
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if component == 0 {
            return NSAttributedString(string: pickerData[row], attributes: [NSForegroundColorAttributeName:UIColor(red: CGFloat(49/255.0), green: CGFloat(120/255.0), blue: CGFloat(178/255.0), alpha: CGFloat(1.0))])
        } else {
            var theString = ""
            switch selectedGenre {
            case 0:
                theString = generalData[row]
            case 1:
                theString = globalData[row]
            case 2:
                theString = americanData[row]
            case 3:
                theString = latinData[row]
            case 4:
                theString = europeanData[row]
            case 5:
                theString = asianData[row]
            case 6:
                theString = islandsData[row]
                
            default:
                theString = "Error"
            }
            
            return NSAttributedString(string: theString, attributes: [NSForegroundColorAttributeName:UIColor(red: CGFloat(49/255.0), green: CGFloat(120/255.0), blue: CGFloat(178/255.0), alpha: CGFloat(1.0))])
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedGenre = row
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: false)
        }
    }
    
    // MARK: Actionable Data
    // Add Location Button Logic
    @IBAction func addLocationButton() {
        locationManager.startUpdatingLocation()
        
        if locationManager.location != nil && sharedFoursquareProcesses.checkReachibility() {
            CLGeocoder().reverseGeocodeLocation(locationManager.location, completionHandler: {(placemarks, error) -> Void in
                let placemark = placemarks[0] as! CLPlacemark
                var city = placemark.locality
                var state = placemark.administrativeArea
            
                self.locationText.text = NSString(format:"%@, %@", city, state) as String
                self.locationManager.stopUpdatingLocation()
            })
        } else if locationManager.location == nil {
            self.locationText.text = ""
            JLToast.makeText("Error getting Location").show()
        }
    }
    
    // Start Segues
    @IBAction func segueButton(sender: AnyObject) {
        if !sharedFoursquareProcesses.checkReachibility() {
            return
        }
        
        var button = sender as? UIButton
        var parameters = [Parameter.openNow: "1"]
        sharedFoursquareProcesses.callingViewController = self

        
        if button?.tag == 0 || button?.tag == 1 {
            if locationText.text == "" {
                JLToast.makeText("Need a Location").show()
                return
            }
            
            parameters += [Parameter.m: "swarm"]
            parameters += [Parameter.near:locationText.text]
            parameters += [Parameter.venuePhotos:"1"]
            parameters += [Parameter.price: String(priceControl.selectedSegmentIndex + 1)]
            parameters += [Parameter.query: myPicker.delegate!.pickerView!(myPicker, attributedTitleForRow: myPicker.selectedRowInComponent(1), forComponent: 1)!.string]
            
            var isSearching = false
            if button?.tag == 0 {
                isSearching = true
            }
            
            sharedFoursquareProcesses.indexedPath = nil
            sharedFoursquareProcesses.currentValue = 0
            sharedFoursquareProcesses.getData(parameters, isSearching: isSearching)
        }
        
        if button?.tag == 2 || button?.tag == 3 {
            var saved = false
            if button?.tag == 3 {
                saved = true
            }
            sharedFoursquareProcesses.addRemoveGet(true, adding:nil, saving: saved, venueID: nil)
            sharedFoursquareProcesses.saveHeader = saved
        }
        
        locationManager.stopUpdatingLocation()
        
    }
    
    // Login Button Logic
    @IBAction func barItemPressed() {
        if !sharedFoursquareProcesses.checkAuthorized() {
            sharedFoursquareProcesses.session.authorizeWithViewController(self, delegate: self) {
            (authorized, error) -> Void in
                sharedFoursquareProcesses.checkLists()
                
                if authorized {
                    self.loggingButton.title = "Log Out"
                    
                    // Export local save/favorites
                    if sharedFileProcesses.exists(true) {
                        if let daJSON = sharedFileProcesses.read(true) {
                            sharedFoursquareProcesses.exportLocal(daJSON, saving: true)
                        }
                    }
                    
                    if sharedFileProcesses.exists(false) {
                        if let daJSON = sharedFileProcesses.read(false) {
                            sharedFoursquareProcesses.exportLocal(daJSON, saving: false)
                        }
                    }

                }
            }
        } else {
            logOutAlert()
        }
    }
    
    func logOutAlert() {
        let alertController = UIAlertController(title: "Are you Sure?", message: nil, preferredStyle: .Alert)
        let confrim = UIAlertAction(title: "Confirm", style: .Destructive, handler: {
            (action) -> Void in
            sharedFoursquareProcesses.session.deauthorize()
            self.loggingButton.title = "Login"
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: {
            (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        alertController.addAction(cancel)
        alertController.addAction(confrim)
        presentViewController(alertController, animated: true, completion: nil)
    }
}
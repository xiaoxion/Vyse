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
    
    var locationManager: CLLocationManager!
    
    let distanceFormatter = MKDistanceFormatter()
    let pickerData = [["Mexican","Chinese","American","Japanese","Italian", "Fast Food", "Latin", "Greek", "German", "Thai", "French", "Colombian", "American"]]

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
    
    // Picker Data and Logic
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[component][row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: pickerData[component][row], attributes: [NSForegroundColorAttributeName:UIColor(red: CGFloat(49/255.0), green: CGFloat(120/255.0), blue: CGFloat(178/255.0), alpha: CGFloat(1.0))])
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
            parameters += [Parameter.query:pickerData[0][myPicker.selectedRowInComponent(0)]]
            parameters += [Parameter.near:locationText.text]
            parameters += [Parameter.venuePhotos:"1"]
            parameters += [Parameter.price: String(priceControl.selectedSegmentIndex + 1)]
            
            var isSearching: Bool
            if button?.tag == 0 {
                isSearching = true
            } else{
                isSearching = false
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
        }
        
        locationManager.stopUpdatingLocation()
        
    }
    
    // Login Button Logic
    @IBAction func barItemPressed() {
        if !sharedFoursquareProcesses.checkAuthorized() {
            sharedFoursquareProcesses.session.authorizeWithViewController(self, delegate: self) {
            (authorized, error) -> Void in
                sharedFoursquareProcesses.checkLists()
                self.loggingButton.image = nil
                self.loggingButton.title = "Log Out"
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
            self.loggingButton.title = ""
            self.loggingButton.image = UIImage(named: "Male50.png")
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
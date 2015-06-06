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

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, SessionAuthorizationDelegate, UITextFieldDelegate {
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var priceControl: UISegmentedControl!
    
    var locationManager: CLLocationManager!
    
    let distanceFormatter = MKDistanceFormatter()
    let pickerData = [["Mexican","Chinese","American","Japanese","Italian"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationText.delegate = self
        
        addLogoToTitleBar()
        locationManagerChecker()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
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
    
    func addLogoToTitleBar() {
        let logoImage = UIImage(named: "Vyse.png")
        let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 36))
        logoView.contentMode = .ScaleAspectFit
        logoView.image = logoImage
        self.navigationItem.titleView = logoView
    }
    
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
    
    @IBAction func addLocationButton() {
        locationManager.startUpdatingLocation()
        
        if locationManager.location != nil {
            CLGeocoder().reverseGeocodeLocation(locationManager.location, completionHandler: {(placemarks, error) -> Void in
                let placemark = placemarks[0] as! CLPlacemark
                var city = placemark.locality
                var state = placemark.administrativeArea
            
                self.locationText.text = NSString(format:"%@, %@", city, state) as String
                self.locationManager.stopUpdatingLocation()
            })
        } else {
            self.locationText.attributedPlaceholder = NSAttributedString(string: "Error Getting Location", attributes: [NSForegroundColorAttributeName:UIColor(red: CGFloat(249/255.0), green: CGFloat(150/255.0), blue: CGFloat(108/255.0), alpha: CGFloat(1.0))])
        }
    }
    
    @IBAction func segueButton(sender: AnyObject) {
        var button = sender as? UIButton
        var parameters = [Parameter.openNow: "1"]
        
        if button?.tag == 0 || button?.tag == 1 {
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
            
            sharedFoursquareProcesses.callingViewController = self
            sharedFoursquareProcesses.indexedPath = nil
            sharedFoursquareProcesses.currentValue = 0
            sharedFoursquareProcesses.getData(parameters, isSearching: isSearching)
        }
        
        if button?.tag == 2 {
            
        } else if button?.tag == 3 {
            
        }
        
        locationManager.stopUpdatingLocation()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoginSegue" {
            sharedFoursquareProcesses.session.authorizeWithViewController(self, delegate: self) {
                (authorized, error) -> Void in
            }
        }
    }
}
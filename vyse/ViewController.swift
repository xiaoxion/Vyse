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

typealias JSONParameters = [String: AnyObject]

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, SessionAuthorizationDelegate {
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var priceControl: UISegmentedControl!
    
    var session: Session!
    var currentTask: Task?
    var locationManager: CLLocationManager!
    var venues: [[String:AnyObject]]!
    
    let distanceFormatter = MKDistanceFormatter()
    let pickerData = [["Mexican","Chinese","American","Japanese","Italian"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addLogoToTitleBar()
        locationManagerChecker()
    }
    
    func showNoPermissionsAlert() {
        let alertController = UIAlertController(title: "No permission", message: "In order to work, app needs your location", preferredStyle: .Alert)
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
        session = Session.sharedSession()
        
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
        
        if button?.tag == 0 {
            parameters += [Parameter.query:pickerData[0][myPicker.selectedRowInComponent(0)]]
            parameters += [Parameter.near:locationText.text]
            parameters += [Parameter.venuePhotos:"1"]
            parameters += [Parameter.price: String(priceControl.selectedSegmentIndex + 1)]
        } else if button?.tag == 2 {
            
        } else if button?.tag == 3 {
            
        }
        
        locationManager.stopUpdatingLocation()
        currentTask?.cancel()
        
        currentTask = session.venues.explore(parameters) {
            (result) -> Void in
            if result.response != nil {
                if let groups = result.response!["groups"] as? [[String: AnyObject]]  {
                    var venues = [[String: AnyObject]]()
                    for group in groups {
                        if let items = group["items"] as? [[String: AnyObject]] {
                            venues += items
                        }
                    }
                    
                    self.venues = venues
                    if button?.tag == 1 {
                        self.performSegueWithIdentifier("VyseSegue", sender: self)
                    } else {
                        self.performSegueWithIdentifier("SearchSegue", sender: self)
                    }
                }
            }
        }
        currentTask?.start()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoginSegue" {
            session.authorizeWithViewController(self, delegate: self) {
                (authorized, error) -> Void in
                
            }
        }
        
        if segue.identifier == "SearchSegue" {
            var segued = segue.destinationViewController as! ListViewController
            segued.session = self.session
            segued.venues = venues
        } else if segue.identifier == "VyseSegue" {
            var segued = segue.destinationViewController as! VyseViewController
        }
    }
}
//
//  MapViewController.swift
//  vyse
//
//  Created by Stratazima on 6/22/15.
//  Copyright (c) 2015 Stratazima. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        // Set the current Location
        if let venue = sharedFoursquareProcesses.venues[sharedFoursquareProcesses.currentValue]["venue"].dictionary {
            var latitute:CLLocationDegrees = venue["location"]!["lat"].doubleValue
            var longitute:CLLocationDegrees = venue["location"]!["lng"].doubleValue
            
            var coordinates = CLLocationCoordinate2D(latitude: latitute, longitude: longitute)
            let regionSpan = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
            let region = MKCoordinateRegion(center: coordinates, span: regionSpan)
            var placemark = MKPointAnnotation()
            placemark.coordinate = coordinates
            placemark.title = venue["name"]?.string
                
            mapView.mapType = MKMapType.Standard
            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(placemark)
            
            self.title = venue["name"]?.string
        }
    }
}
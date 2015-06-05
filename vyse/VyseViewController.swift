//
//  VyseViewController.swift
//  vyse
//
//  Created by Stratazima on 5/27/15.
//  Copyright (c) 2015 Stratazima. All rights reserved.
//

import UIKit

class VyseViewController:UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var mainTopContraint: NSLayoutConstraint!
    @IBOutlet weak var subTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftMainView: NSLayoutConstraint!
    @IBOutlet weak var rightMiainView: NSLayoutConstraint!
    
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantTime: UILabel!
    
    var ifRecieving: Bool = false
    var indexedPath: NSIndexPath!
    var venueObject: [[String:AnyObject]]!
    var currentValue: Int!
    
    override func viewDidLoad() {
        addLogoToTitleBar()
        addGestureRecognizers()
        
        if ifRecieving {
            currentValue = indexedPath.row
            let object = venueObject![currentValue] as JSONParameters!
            let objectVenue = object["venue"] as? JSONParameters
            
            var hours = objectVenue!["hours"] as? JSONParameters
            var hoursString = "Closed Now"
            
            if hours != nil {
                if hours!["isOpen"] as! Bool {
                    hoursString = "Open Now"
                }
            } else {
                hoursString = "Hours Unknown"
            }
            
            restaurantName.text = objectVenue!["name"] as? String
            restaurantTime.text = hoursString
        } else {
            
        }
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
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
                if self.currentValue < self.venueObject.count {
                    self.currentValue = self.currentValue + 1
                } else {
                    
                }
                self.mainTopContraint.constant = 8
                self.subTopConstraint.constant = 300
                self.leftMainView.constant = 509
                self.rightMiainView.constant = -509
                self.mainView.layoutIfNeeded()
                self.subView.layoutIfNeeded()
                }, completion: {
                    (value:Bool) in
                    UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
                        self.leftMainView.constant = 9
                        self.rightMiainView.constant = 9
                        self.mainView.layoutIfNeeded()
                        }, completion: nil)
            })
        } else if sender.direction == .Up {
            UIView.animateWithDuration(0.75, delay: 0.0, options: .CurveEaseOut, animations: {
                self.mainTopContraint.constant = -160
                self.subTopConstraint.constant = -36
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
}

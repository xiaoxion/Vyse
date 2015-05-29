//
//  ViewController.swift
//  vyse
//
//  Created by Stratazima on 5/20/15.
//  Copyright (c) 2015 Stratazima. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var locationText: UITextField!
    
    let pickerData = [["Mexican","Chinese","American","Japanese","Italian"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addLogoToTitleBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SearchSegue" {
            
        } else if segue.identifier == "VyseSegue" {
            
        } else if segue.identifier == "LoginSegue" {
            
        }
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
    
    @IBAction func addLocationButton() {
        locationText.text = "Tampa, FL"
    }
}
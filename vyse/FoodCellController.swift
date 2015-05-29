//
//  FoodCellController.swift
//  vyse
//
//  Created by Stratazima on 5/28/15.
//  Copyright (c) 2015 Stratazima. All rights reserved.
//

import UIKit

class FoodCellController: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    
    var mainString: String
    var subString: String
    
    override func init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self = superclass?.init#(style, reuseIdentifier: reuseIdentifier)
        
        if self {
            
        }
        
        return self
    }
    
    func refreshCell() {
        movieLabel.text = mainString
    }
}

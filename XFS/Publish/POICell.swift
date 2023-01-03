//
//  POICell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/11.
//

import UIKit

class POICell: UITableViewCell {
    
    var poi:POI?{
        didSet{
            guard let poi = poi else {return}
            titleLabel.text = poi.name
            addressLabel.text = poi.address
        }
    }

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

}

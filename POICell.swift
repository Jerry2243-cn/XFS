//
//  POICell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/11.
//

import UIKit

class POICell: UITableViewCell {
    
    var poi = ["",""]{
        didSet{
            titleLabel.text = poi[0]
            addressLabel.text = poi[1]
        }
    }

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!


}

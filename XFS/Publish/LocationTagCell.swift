//
//  LocationTagCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/12.
//

import UIKit

class LocationTagCell: UICollectionViewCell {
    
    var poi:POI?{
        didSet{
            guard let poi = poi else {return}
            titleLabel.text = poi.name
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderColor = UIColor.secondaryLabel.cgColor
        self.contentView.layer.borderWidth = 1
    }
}

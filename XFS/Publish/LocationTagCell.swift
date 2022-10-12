//
//  LocationTagCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/12.
//

import UIKit

class LocationTagCell: UICollectionViewCell {
    
    @IBOutlet weak var locationTagButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderColor = UIColor.secondaryLabel.cgColor
        self.contentView.layer.borderWidth = 1
    }
}

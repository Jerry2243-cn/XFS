//
//  NearbyCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/3.
//

import UIKit

class NearbyCell: UICollectionViewCell {
   
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var infoStack: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
////        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        let horizontalConstraint = NSLayoutConstraint(item: titleLabel!, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10)
//        let verticalConstraint = NSLayoutConstraint(item: titleLabel!, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 10)
//        let widthConstraint = NSLayoutConstraint(item: titleLabel!, attribute: .width, relatedBy: .equal, toItem: infoStack, attribute: .width, multiplier: 1, constant: infoStack.frame.width)
//    }
}

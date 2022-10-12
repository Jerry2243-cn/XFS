//
//  WaterFallwCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/2.
//

import UIKit

class WaterFallwCell: UICollectionViewCell {
    @IBOutlet weak var photosImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var nicknamLableView: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var infoStack: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLable.preferredMaxLayoutWidth = infoStack.bounds.width
    }
}

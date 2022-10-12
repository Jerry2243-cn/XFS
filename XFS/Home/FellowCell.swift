//
//  FellowCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/3.
//

import UIKit

class FellowCell: UICollectionViewCell {
    
    @IBOutlet weak var topInfoStack: UIStackView!
    @IBOutlet weak var bottomInfoStack: UIStackView!
    @IBOutlet weak var shareButtonTop: UIButton!
    @IBOutlet weak var showCOntentButton: UIButton!
    @IBOutlet weak var titleAndContentLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var notePublishTime: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nicknameLable: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        shareButton.text("")
        shareButtonTop.text("")
    }
}

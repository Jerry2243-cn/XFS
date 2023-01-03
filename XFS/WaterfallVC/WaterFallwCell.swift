//
//  WaterFallwCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/2.
//

import UIKit
import Kingfisher

class WaterFallwCell: UICollectionViewCell {
    @IBOutlet weak var photosImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoStack: UIStackView!
    
    var note:Note?{
        didSet{
            guard let data = note else {return}
            nicknameLabel.text = data.user.nickname
//            if let title = data.title{
                titleLabel.text = "data.title ?? "
//                titleLabel.isHidden = data.title?.isEmpty ?? true
//            }else{
//                titleLabel.isHidden = true
//            }
            let coverPhotoURL = URL(string: data.coverPhoto)
            photosImageView.kf.setImage(with: coverPhotoURL)
            if let url = data.user.avatar{
                let avatarURL = URL(string: url)
                avatarImage.kf.setImage(with: avatarURL)
            }else{
                avatarImage.image = defaultAvatar
            }
            likeButton.setTitle(data.likeNumber == 0 ? "点赞" : "\(data.likeNumber)", for: .normal)
            
        }
    }
   
}

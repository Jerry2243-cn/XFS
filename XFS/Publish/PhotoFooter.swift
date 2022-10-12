//
//  PhotoFooter.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/5.
//

import UIKit

class PhotoFooter: UICollectionReusableView {
    @IBOutlet weak var addPhotoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addPhotoButton.text("")
        addPhotoButton.layer.borderWidth = 1
        addPhotoButton.layer.borderColor = UIColor.tertiaryLabel.cgColor
    }
}

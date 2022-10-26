//
//  MeHeaderView.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/22.
//

import UIKit

class MeHeaderView: UIView {
    @IBOutlet weak var editOrFellowButton: UIButton!
    @IBOutlet weak var settingsOrChatButton: UIButton!
    @IBOutlet weak var rootStackView: UIStackView!
    @IBOutlet weak var shareBUtton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editOrFellowButton.makeCapsule()
        settingsOrChatButton.makeCapsule()
        settingsOrChatButton.setTitle("", for: .normal)
        shareBUtton.setTitle("", for: .normal)
    }
   
}

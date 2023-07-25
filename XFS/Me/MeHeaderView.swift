//
//  MeHeaderView.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/22.
//

import UIKit
import Kingfisher

class MeHeaderView: UIView {
    
    var user:User?{
        didSet{
            guard let data = user else { return }
            if let avatar = data.avatar {
                let url = URL(string: avatar)
                avatarImageView.kf.setImage(with: url)
            }else{
                avatarImageView.image = defaultAvatar
            }
            nickNameLabel.text = data.nickname
            username.text = data.username
            if let sex = data.sex {
                sexLabel.text = sex == "女" ? "♀" : "♂"
                sexLabel.textColor = sex == "女" ? .systemPink : .link
            }else{
                sexLabel.text = ""
            }
            fellowNumberLabel.text = "\(data.fellowNumber)"
            fansLabel.text = "\(data.fans)"
            notesLikesNumber.text = "\(data.likes)"
        }
    }
    @IBOutlet weak var avatarImageView: UIImageView!
        
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var editOrFellowButton: UIButton!
    @IBOutlet weak var settingsOrChatButton: UIButton!
    @IBOutlet weak var rootStackView: UIStackView!
    @IBOutlet weak var shareBUtton: UIButton!
    
    @IBOutlet weak var fellowNumberLabel: UILabel!
    @IBOutlet weak var fansLabel: UILabel!
    @IBOutlet weak var notesLikesNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editOrFellowButton.makeCapsule()
        settingsOrChatButton.makeCapsule()
        settingsOrChatButton.setTitle("", for: .normal)
//        NotificationCenter.default.addObserver(self, selector: #selector(reSetUser), name: NSNotification.Name(kUpdateuser), object: nil)
    }
   
    @objc func reSetUser(){
        self.user = appDelegate.user
    }
}

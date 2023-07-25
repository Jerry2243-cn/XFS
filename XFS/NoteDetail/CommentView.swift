//
//  CommentView.swift
//  XFS
//
//  Created by Jerry Zhu on 2023/1/5.
//

import UIKit
import Kingfisher

class CommentView: UITableViewHeaderFooterView {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var isAuthor = false {
        didSet{
            authorLabel.isHidden = !isAuthor
        }
    }
    
    var comment:Comment?{
        didSet{
            guard let comment = self.comment else {return}
            if let url = comment.user.avatar{
                let avatarURL = URL(string: url)
                avatarImageView.kf.setImage(with: avatarURL)
            }else{
                avatarImageView.image = defaultAvatar
            }
            nicknameLabel.text = comment.user.nickname
            commentLabel.attributedText = comment.content.spliceAttrStr(Date().formatDate(isoDate: comment.createTime))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickAction))
        avatarImageView.addGestureRecognizer(tap)
    }
    
    @objc func clickAction(){
        NotificationCenter.default.post(name: NSNotification.Name(kGotoMine), object: comment?.user)
    }
   
}

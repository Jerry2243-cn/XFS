//
//  CommentReplyCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2023/1/5.
//

import UIKit

class CommentReplyCell: UITableViewCell {
    
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
    
    var replyUser:String?{
        didSet{
            guard let name = replyUser else {return}
            let reply = "回复 ".toAttrStr()
            let replyName = name.toAttrStr(14, .secondaryLabel)
            let colon = ": ".toAttrStr()
            let content = commentLabel.attributedText ?? NSAttributedString(string: "")
            
            reply.append(replyName)
            reply.append(colon)
            reply.append(content)
            
            commentLabel.attributedText = reply
        }
    }
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickAction))
        avatarImageView.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func clickAction(){
        NotificationCenter.default.post(name: NSNotification.Name(kGotoMine), object: comment?.user)
    }
}

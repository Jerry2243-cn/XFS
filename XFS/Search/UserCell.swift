//
//  UserCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2023/1/6.
//

import UIKit
import SnapKit
import Kingfisher

class UserCell: UITableViewCell {
    
    var user:User?{
        didSet{
            guard let user = self.user else {return}
            if let url = user.avatar{
                let avatarURL = URL(string: url)
                avatarImageView.kf.setImage(with: avatarURL)
            }else{
                avatarImageView.image = defaultAvatar
            }
            nickNameLabel.text = user.nickname
            IDLabel.text = "XFS ID: \(user.username)"
            
            if user.fellow{
                fellowButton.setTitle("已关注", for: .normal)
                fellowButton.setTitleColor(.secondaryLabel, for: .normal)
                fellowButton.layer.borderColor = UIColor.secondaryLabel.cgColor
            }else{
                fellowButton.setTitle("关注", for: .normal)
                fellowButton.setTitleColor(mainColor, for: .normal)
                fellowButton.layer.borderColor = mainColor!.cgColor
            }
            
            if user.id == appDelegate.user?.id{
                fellowButton.isHidden = true
            }else{
                fellowButton.isHidden = false
            }
        }
    }
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = defaultAvatar
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRedius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "nickname"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        return label
    }()
    
    lazy var IDLabel: UILabel = {
        let label = UILabel()
        label.text = "ID: 1234"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    lazy var fellowButton: UIButton = {
        let button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 100, height: 30))
        button.setTitle("关注", for: .normal)
        button.setTitleColor(mainColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.makeCapsule(mainColor!)
        return button
    }()

    override init(style:UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        
        fellowButton.addTarget(self, action: #selector(fellow), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI(){
        contentView.backgroundColor = .systemBackground
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(IDLabel)
        contentView.addSubview(fellowButton)
        
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        nickNameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(8)
            make.bottom.equalTo(contentView.snp.centerY)
        }
        IDLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(8)
            make.top.equalTo(contentView.snp.centerY).offset(2)
        }
        fellowButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(80)
            make.height.equalTo(28)
        }
    }
    
    @objc func fellow(){
        guard var user = self.user else {return}
        if !user.fellow{
            user.fans += 1
            fellowButton.setTitle("已关注", for: .normal)
            fellowButton.setTitleColor(.secondaryLabel, for: .normal)
            fellowButton.layer.borderColor = UIColor.secondaryLabel.cgColor
        }else{
            user.fans -= 1
            fellowButton.setTitle("关注", for: .normal)
            fellowButton.setTitleColor(mainColor, for: .normal)
            fellowButton.layer.borderColor = mainColor!.cgColor
        }
        user.fellow.toggle()
        Server.shared().fellowUser(userId: user.id) { res in
            if let resoult = res, resoult == "操作成功" {
                self.user = user
            }
        }
    }
}

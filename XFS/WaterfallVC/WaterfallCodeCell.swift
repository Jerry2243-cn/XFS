//
//  WaterfallCodeCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/12/14.
//

import UIKit
import SnapKit
import Kingfisher

class WaterfallCodeCell: UICollectionViewCell {
    
    var isMine = false{
        didSet{
            if isMine{
                viewsView.isHidden = false
            }
        }
    }
    
    var note:Note?{
        didSet{
            guard let data = note else {return}
            nicknameLabel.text = data.user.nickname
            if let title = data.title{
                titleLabel.text = title
                titleLabel.isHidden = false
            }else{
                titleLabel.isHidden = true
            }
            let coverPhotoURL = URL(string: data.coverPhoto)
            coverPhotoImageView.kf.setImage(with: coverPhotoURL)
            getHeight(ratio: data.ratio)
            if let url = data.user.avatar{
                let avatarURL = URL(string: url)
                avatarImageView.kf.setImage(with: avatarURL)
            }else{
                avatarImageView.image = defaultAvatar
            }
            if data.liked{
                likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                likeButton.tintColor = .systemPink
            }else{
                likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                likeButton.tintColor = .secondaryLabel
            }
            viewsView.setTitle("\(data.views)", for: .normal)
            likeButton.setTitle(data.likeNumber == 0 ? "点赞" : "\(data.likeNumber)", for: .normal)
        }
    }
    
    lazy var coverPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRedius = 9
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitle("0", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 11)
        button.tintColor = .secondaryLabel
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    lazy var viewsView: UIButton = {
        let button = UIButton()
        let symbolConfig = UIImage.SymbolConfiguration( scale: .unspecified)
        let symbel = UIImage(systemName: "eye.fill", withConfiguration: symbolConfig)
        button.setImage(symbel, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: -3, bottom: 5, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        button.contentHorizontalAlignment = .center
        button.titleLabel?.textAlignment = .left
        button.setTitle("0", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(white: 0, alpha: 0.5)
        button.layer.cornerRadius = 10
        button.isHidden = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        
        likeButton.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getHeight(ratio:Double){
        let imageWidth = (UIScreen.main.bounds.width - kWaterFallpadding * 3) / 2
        var imageRatio = ratio
        if imageRatio > 1.35 {
            imageRatio = 1.35
        }else if imageRatio < 2.0 / 3.0 {
            imageRatio = 2.0 / 3.0
        }
        let imageHight = imageWidth * imageRatio
        coverPhotoImageView.snp.remakeConstraints { make in
            make.top.equalTo(contentView)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(imageHight)
        }
    }
    
    func setUI() {
        
        contentView.backgroundColor = .systemBackground
        contentView.cornerRedius = 4
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(coverPhotoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(viewsView)
        
//        coverPhotoImageView.snp.makeConstraints { make in
//
//            make.top.equalTo(contentView)
//            make.left.equalTo(contentView)
//            make.right.equalTo(contentView)
//        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(coverPhotoImageView.snp.bottom).offset(10)
            make.left.equalTo(contentView).offset(10)
            make.right.equalTo(contentView).offset(-10)
        }
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(18)
            make.left.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView).offset(-10)
        }
        nicknameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatarImageView)
            make.left.equalTo(avatarImageView.snp.right).offset(5)
        }
        likeButton.snp.makeConstraints { make in
            make.height.equalTo(14)
            make.width.equalTo(47)
            make.centerY.equalTo(avatarImageView)
            make.right.equalTo(contentView).offset(-10)
        }
        viewsView.snp.makeConstraints { make in
            make.left.equalTo(coverPhotoImageView).offset(9)
            make.bottom.equalTo(coverPhotoImageView).offset(-9)
            make.height.equalTo(20)
            make.width.equalTo(50)
        }
    }
    
    @objc func likeAction(){
        guard var note = self.note else {return}
        if note.liked{
            if note.user.id == appDelegate.user?.id{
                appDelegate.user?.likes -= 1
            }
            note.likeNumber -= 1
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            likeButton.tintColor = .secondaryLabel
            note.liked = false
        }else{
            if note.user.id == appDelegate.user?.id{
                appDelegate.user?.likes += 1
            }
            note.likeNumber += 1
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tintColor = .systemPink
            note.liked = true
        }
        likeButton.setTitle(note.likeNumber <= 0 ? "点赞" : "\(note.likeNumber)", for: .normal)
        Server.shared().likeNote(noteId: note.id){ res in
            if let resoult = res{
                if resoult == "操作成功"{
                    if self.note?.user.id == appDelegate.user?.id{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateuser), object: nil)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLikeSucceed), object: note)
                }
            }
        }
    }
}

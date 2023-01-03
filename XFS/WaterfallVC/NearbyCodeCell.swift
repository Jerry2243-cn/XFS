//
//  NearbyCodeCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/12/31.
//

//
//  WaterfallCodeCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/12/14.
//

import UIKit
import SnapKit
import Kingfisher

class NearbyCodeCell: UICollectionViewCell {
    
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
            if let myPOI = appDelegate.myPOI,let notPOI = data.poi{
                locationButton.setTitle(distanceFormat(distance: getDistance(poi1: myPOI, poi2: notPOI)), for: .normal)
            }else{
                locationButton.setTitle("error", for: .normal)
            }
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
    
    lazy var locationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitle("0", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 11)
        button.tintColor = .secondaryLabel
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
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
        contentView.addSubview(locationButton)
        
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
        locationButton.snp.makeConstraints { make in
            make.height.equalTo(14)
            make.width.equalTo(80)
            make.centerY.equalTo(avatarImageView)
            make.right.equalTo(contentView).offset(-10)
        }
    }
    
    func getDistance(poi1:POI, poi2:POI) -> Double{
        let radLat1 = poi1.latitude * Double.pi / 180.0;   //角度1˚ = π / 180
        let radLat2 = poi2.latitude * Double.pi / 180.0;   //角度1˚ = π / 180
            let a = radLat1 - radLat2;//纬度之差
        let b = poi1.longitude * Double.pi / 180.0 - poi2.longitude * Double.pi / 180.0;
        var dst = 2 * asin((sqrt(pow(sin(a / 2), 2) + cos(radLat1) * cos(radLat2) * pow(sin(b / 2), 2))));
        dst *= 6378.137
//        dst = round(dst * 10000) / 10000
        return dst
    }
    
    func distanceFormat(distance:Double) -> String{
        if distance > 10 {
            return String(format: "%.0fkm", distance)
        }else if distance > 1{
            return String(format: "%.1fkm", distance)
        }else if distance > 0.001{
            let dis = distance * 1000
            return String(format: "%.0fm", dis)
        }else if distance > 0.0001{
            let dis = distance * 10000
            return String(format: "%.1fm", dis)
        }else{
            return "0.1m"
        }
    }
}


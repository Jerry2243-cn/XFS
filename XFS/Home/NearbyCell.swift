//
//  NearbyCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/3.
//

import UIKit

class NearbyCell: UICollectionViewCell {
   
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var infoStack: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var note:Note?{
        didSet{
            guard let data = note else {return}
            nicknameLabel.text = data.user.nickname
            if let title = data.title{
                titleLabel.text = title
            }else{
                titleLabel.isHidden = true
            }
            let coverPhotoURL = URL(string: data.coverPhoto)
            imageView.kf.setImage(with: coverPhotoURL)
            if let url = data.user.avatar{
                let avatarURL = URL(string: url)
                avatarImage.kf.setImage(with: avatarURL)
            }else{
                avatarImage.image = defaultAvatar
            }
            
            if let myPOI = appDelegate.myPOI,let notPOI = data.poi{
                distanceLabel.text = distanceFormat(distance: getDistance(poi1: myPOI, poi2: notPOI))
            }else{
                distanceLabel.text = "error"
            }
            
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

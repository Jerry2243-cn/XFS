//
//  UserInfoEditCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/12/15.
//

import UIKit
import SnapKit

class UserInfoEditCell: UITableViewCell {
    
    var user:User?{
        didSet{
            
        }
    }
    
    lazy var titleLabel = {
        let label = UILabel()
        label.textColor = .label
        return label
    }()
    
    lazy var infoLabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(16)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-33)
        }
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    
}

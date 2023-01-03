//
//  SettingsCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/11/4.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.textColor = .label
        return label
    }()
    
    var isLogout:Bool?{
        didSet{
            if let out = isLogout{
                if out {
                    titleLabel.snp.remakeConstraints { make in
                        make.center.equalTo(self)
                    }
                }
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.backgroundColor = .secondarySystemBackground
        self.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.centerY.equalTo(self)
                make.left.equalTo(self).offset(16)
            }
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

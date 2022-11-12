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

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .secondarySystemBackground
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(16)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

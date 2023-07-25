//
//  BaseNavigationBar.swift
//  XFS
//
//  Created by Jerry Zhu on 2023/1/6.
//

import UIKit
import SnapKit

class BaseNavigationBar: UIView {
    
    lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 40, height: 44))
        
        let symbolConfig = UIImage.SymbolConfiguration(scale: .large)
        let symbel = UIImage(systemName: "chevron.left", withConfiguration: symbolConfig)
        button.setImage(symbel, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .label
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    init() {
        super.init(frame: CGRect(x: .zero, y: .zero, width: screenWidth, height: statusBarHeight + navigationBarHeight))
        setUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(){
        self.backgroundColor = .systemBackground
        self.addSubview(titleLabel)
        self.addSubview(backButton)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(backButton)
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalTo(self).offset(9)
            make.bottom.equalTo(self).offset(-5)
            make.height.equalTo(35)
            make.width.equalTo(30)
        }
    }
  
}

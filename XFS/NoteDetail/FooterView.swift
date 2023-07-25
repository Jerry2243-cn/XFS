//
//  FooterView.swift
//  XFS
//
//  Created by Jerry Zhu on 2023/1/5.
//

import UIKit

class FooterView: UITableViewHeaderFooterView {

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        tintColor = .systemBackground
        
        let line = UIView(frame: CGRect(x: 62, y: .zero, width: screenRect.width - 62, height: 1))
        line.backgroundColor = .systemGray6
        
        self.addSubview(line)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
//  CustomViews.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/19.
//

import Foundation

@IBDesignable
class BigButton: UIButton{
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        sharedInit()
    }
    
    private func sharedInit(){
        backgroundColor = .secondarySystemBackground
        tintColor = .placeholderText
        setTitleColor(.placeholderText, for: .normal)
        
        contentHorizontalAlignment = .leading
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
}

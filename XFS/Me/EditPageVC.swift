//
//  EditPageVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/12/15.
//

import UIKit

class EditPageVC: UIViewController {
    
    lazy var topView: UIView = {
        let view = UIView()
        view.addSubview(leftButton)
        view.addSubview(rightButton)
        view.addSubview(titleLabel)
        
        leftButton.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.left.equalTo(view).offset(16)
        }
        rightButton.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.right.equalTo(view).offset(-16)
        }
        titleLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
        return view
    }()
    
    lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal)
        return button
    }()
    
    lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setTitle("完成", for: .normal)
        button.setTitleColor(mainColor, for: .normal)
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        return label
    }()

    lazy var editTF: UITextField = {
        let textField = UITextField()
        textField.cornerRedius = 8
        textField.backgroundColor = .systemBackground
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(topView)
        view.addSubview(editTF)
        leftButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        topView.snp.makeConstraints { make in
            make.top.equalTo(view).offset(statusBarH)
            make.left.right.equalTo(view)
            make.height.equalTo(44)
        }
        editTF.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(25)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(45)
        }
       
    }

    
    @objc func cancelAction(){
        dismiss(animated: true)
    }
    
    @objc func doneAction(){
        
    }
}

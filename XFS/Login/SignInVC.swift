//
//  SignInVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/12/9.
//

import UIKit

class SignInVC: UIViewController {
    
    var doneAction:(()->())?

    lazy var usernameTF = { (h:CGFloat) -> UITextField in
        let blankView = UIView(frame: CGRect(x: .zero, y: .zero, width: h / 2, height: h))
        let tf = UITextField()
        tf.leftView = blankView
        tf.rightView = blankView
        tf.leftViewMode = .always
        tf.rightViewMode = .always
        tf.backgroundColor = .secondarySystemBackground
        tf.cornerRedius = h / 2
        tf.placeholder = "输入用户名"
        tf.keyboardType = .alphabet
        return tf;
    }(50)
    
    lazy var passwordTF = { (h:CGFloat) -> UITextField in
        let blankView = UIView(frame: CGRect(x: .zero, y: .zero, width: h / 2, height: h))
        let tf = UITextField()
        tf.leftView = blankView
        tf.rightView = blankView
        tf.leftViewMode = .always
        tf.rightViewMode = .always
        tf.backgroundColor = .secondarySystemBackground
        tf.cornerRedius = h / 2
        tf.isSecureTextEntry = true
        tf.placeholder = "输入密码"
        tf.keyboardType = .alphabet
        return tf;
    }(50)
    
    lazy var currentPasswordTF = { (h:CGFloat) -> UITextField in
        let blankView = UIView(frame: CGRect(x: .zero, y: .zero, width: h / 2, height: h))
        let tf = UITextField()
        tf.leftView = blankView
        tf.rightView = blankView
        tf.leftViewMode = .always
        tf.rightViewMode = .always
        tf.backgroundColor = .secondarySystemBackground
        tf.cornerRedius = h / 2
        tf.isSecureTextEntry = true
        tf.placeholder = "确认密码"
        tf.keyboardType = .alphabet
        return tf;
    }(50)
    
    lazy var phoneTF = { (h:CGFloat) -> UITextField in
        let blankView = UIView(frame: CGRect(x: .zero, y: .zero, width: h / 2, height: h))
        let tf = UITextField()
        tf.leftView = blankView
        tf.rightView = blankView
        tf.leftViewMode = .always
        tf.rightViewMode = .always
        tf.backgroundColor = .secondarySystemBackground
        tf.cornerRedius = h / 2
        tf.placeholder = "输入手机号"
        tf.keyboardType = .numberPad
        return tf;
    }(50)
    
    lazy var signInBtn = { (h:CGFloat) -> UIButton in
        let button = UIButton()
        button.cornerRedius = h/2
        button.backgroundColor = mainColor
        button.setTitleColor(.white, for: .normal)
        button.setTitle("注册", for: .normal)
        return button
    }(50)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInBtn.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        setUI()
        hideKeyboardWhenTappedAround()
    }
    

    func setUI(){
        view.backgroundColor = .systemBackground
        navigationItem.title = "注册"
        navigationController?.navigationBar.backItem?.title = ""
        
        view.addSubview(usernameTF)
        view.addSubview(passwordTF)
        view.addSubview(currentPasswordTF)
        view.addSubview(signInBtn)
        view.addSubview(phoneTF)
        
        usernameTF.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width / 1.3)
            make.height.equalTo(50)
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-200)
        }
        
        passwordTF.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width / 1.3)
            make.height.equalTo(50)
            make.centerX.equalTo(view)
            make.top.equalTo(usernameTF.snp.bottom).offset(20)
        }
        
        currentPasswordTF.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width / 1.3)
            make.height.equalTo(50)
            make.centerX.equalTo(view)
            make.top.equalTo(passwordTF.snp.bottom).offset(20)
        }
        
        phoneTF.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width / 1.3)
            make.height.equalTo(50)
            make.centerX.equalTo(view)
            make.top.equalTo(currentPasswordTF.snp.bottom).offset(20)
        }
        
        signInBtn.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width / 1.3)
            make.height.equalTo(50)
            make.centerX.equalTo(view)
            make.top.equalTo(phoneTF.snp.bottom).offset(100)
        }
        
    }

    @objc func signIn(){
        if !checkEmpty(tfs: [usernameTF,passwordTF,currentPasswordTF,passwordTF]) {
            showTextHUD(showView: self.view, "有项目为空！")
            return
        }
        if passwordTF.text != currentPasswordTF.text {
            showTextHUD(showView: self.view, "两次密码输入不一致！")
            return
        }
        let user = User(username: usernameTF.text!,
                        password: passwordTF.text!,
                        phoneNumber: phoneTF.text!)
        Server.shared().signIn(user: user) { res in
            if let resoult = res{
                if resoult == "注册成功"{
                    self.doneAction?()
                    self.navigationController?.popViewController(animated: true)
                }else{
                    self.showTextHUD(showView: self.view, resoult)
                }
            }else{
                self.showTextHUD(showView: self.view, "系统错误")
            }
        }
    }

    func checkEmpty(tfs:[UITextField]) -> Bool{
        for tf in tfs {
            if tf.text == "" {
                return false
            }
        }
        return true
    }
}

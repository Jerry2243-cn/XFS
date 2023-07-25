//
//  LoginVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/11/22.
//

import UIKit
import SnapKit

class LoginVC: UIViewController {
    
    lazy var logoImageView = {
        let imageView = UIImageView(image: UIImage(named: "LaunchPic")!)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
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
        tf.keyboardType = .asciiCapable
        return tf;
    }(50)
    
    lazy var loginBtn = { (h:CGFloat) -> UIButton in
        let button = UIButton()
        button.cornerRedius = h/2
        button.backgroundColor = mainColor
        button.setTitleColor(.white, for: .normal)
        button.setTitle("登录", for: .normal)
        return button
    }(50)

    lazy var signInBtn = {
        let button = UIButton()
        button.setTitleColor(UIColor.secondaryLabel, for: .normal)
        button.setTitle("没有账号？立即注册", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        hideKeyboardWhenTappedAround()
        loginBtn.addTarget(self, action: #selector(login), for: .touchUpInside)
        signInBtn.addTarget(self, action: #selector(goSignIn), for: .touchUpInside)
        usernameTF.delegate = self
        passwordTF.delegate = self
    }
    
    func setUI(){
        view.backgroundColor = .systemBackground
        
        view.addSubview(usernameTF)
        view.addSubview(passwordTF)
        view.addSubview(loginBtn)
        view.addSubview(logoImageView)
        view.addSubview(signInBtn)
        
        usernameTF.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width / 1.3)
            make.height.equalTo(50)
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-100)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.width.equalTo(240)
            make.height.equalTo(166)
            make.centerX.equalTo(view)
            make.bottom.equalTo(usernameTF.snp.top).offset(-40)
        }
        
        passwordTF.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width / 1.3)
            make.height.equalTo(50)
            make.centerX.equalTo(view)
            make.top.equalTo(usernameTF.snp.bottom).offset(20)
        }
        
        loginBtn.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width / 1.3)
            make.height.equalTo(50)
            make.centerX.equalTo(view)
            make.top.equalTo(passwordTF.snp.bottom).offset(100)
        }
        
        signInBtn.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(loginBtn.snp.bottom).offset(20)
        }
    }
    

    @objc func login(){
        let username = usernameTF.text?.trimmingCharacters(in: .whitespaces)
        let password = passwordTF.text?.trimmingCharacters(in: .whitespaces)
        if username == "" || password == "" {
            showTextHUD(showView: self.view, "用户名或密码为空！")
            return
        }
        showLoadHUD()
        Server.shared().login(usr: username!, pwd: password!) { res in
            
            if let r = res {
                if r == "登录成功"{
                    Server.shared().fetchUser { res in
                        self.hideHUD()
                        if let user = res{
                            appDelegate.user = user
//                            NotificationCenter.default.post(name: NSNotification.Name(kRefreshNotes), object: nil)
//                            NotificationCenter.default.post(name: NSNotification.Name(kUpdateuser), object: nil)
//                            self.dismiss(animated: true)
                            let sb = UIStoryboard(name: "Main", bundle: nil)
                            UIApplication.shared.windows.first?.rootViewController = sb.instantiateViewController(withIdentifier: kMainTabBar)
                            return
                        }else{
                            self.showTextHUD(showView: self.view, "系统错误")
                        }
                    }
                    
                }else{
                    self.hideHUD()
                    self.showTextHUD(showView: self.view, "用户名或密码错误")
                }
            }else{
                self.hideHUD()
                self.showTextHUD(showView: self.view, "系统错误")
            }
        }
    }
    
    @objc func goSignIn(){
        let vc = SignInVC()
        vc.doneAction = { [self] in
            showTextHUD(showView: view, "注册成功")
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.passwordTF{
            login()
        }
        return true
    }
}

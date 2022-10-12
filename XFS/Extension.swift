//
//  Extension.swift
//  
//
//  Created by Jerry Zhu on 2022/10/5.
//

import Foundation
import UIKit
import MBProgressHUD

//给UIView添加右侧工具栏自定义属性
extension UIView{
    @IBInspectable
    var cornerRedius: CGFloat {
        get{
            self.layer.cornerRadius
        }
        set{
            self.layer.cornerRadius = newValue
        }
    }
}

//提示框
extension UIViewController{
    
    //手动隐藏
    func showLoadHUD(title: String? = nil){
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = title
    }
    func hideHUD(){
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    //自动隐藏
    func showTextHUD(showView:UIView, _ title: String, subTitle: String? = nil){
        let hud = MBProgressHUD.showAdded(to: showView, animated: true)
        hud.mode = .text // 不选默认菊花和subtitle
        hud.label.text = title
        hud.detailsLabel.text = subTitle
        hud.hide(animated: true, afterDelay: 1.5)
    }
}

//按空白处收起键盘手饰设定
extension UIViewController{
    func hideKeyboardWhenTappedAround(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}

//加载Xib文件的View
extension Bundle {
    static func loadView<T>(fromNIb name: String, with type: T.Type) -> T{
        if let view =  Bundle.main.loadNibNamed(name, owner: nil)?.first as? T{
            return view
        }
        fatalError("加载\(type)类型的View失败失败")
    }
}

//
//  Extension.swift
//  
//
//  Created by Jerry Zhu on 2022/10/5.
//

import Foundation
import UIKit
import MBProgressHUD
import DateToolsSwift

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
        
            MBProgressHUD.hide(for: self.view, animated: true)
        
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
        if let view = Bundle.main.loadNibNamed(name, owner: nil)?.first as? T{
            return view
        }
        fatalError("加载\(type)类型的View失败失败")
    }
}

extension UILabel {
    
    func getLineSpace() -> CGFloat{
//        attributedText
        return 0
    }
    
    //判断行数
    func textToThisLabelLines(text:String?) -> Int {
        guard let str = text else {return 0}
        let myText = NSString(string: str)
        if myText == "" {
            return 0
        }
        
        if NSString.init(string: text!).contains("滴定仪") {
            print("")
        }
        let targetWidth = (UIScreen.main.bounds.width - kWaterFallpadding * 3) / 2.0
        let rect = CGSize(width: targetWidth, height: CGFloat.greatestFiniteMagnitude)
        let font = UIFont.systemFont(ofSize: 14)
        let labelSize = myText.boundingRect(with: rect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font as Any],
                                            context: nil)
        let rawline = NSNumber.init(value: labelSize.height / font.lineHeight).floatValue
        return NSNumber.init(value: roundf(rawline)).intValue
//        let rawline = roundf(NSNumber.init(value: labelSize.width / frame.width).floatValue)
//        return NSNumber.init(value: rawline).intValue
//        return Int(modf(labelSize.width / (self.frame.width / 2.0)).0) + 1
  }
}

extension UIButton{
    //胶囊按钮
    func makeCapsule(_ color:UIColor = .label){
        layer.cornerRadius = frame.height / 2
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
    }
}

extension UIImage{
    
    //构造可选Data构造器
    convenience init?(_ data: Data?) {
        if let unwappedData = data{
            self.init(data: unwappedData)
        }else{
            return nil
        }
    }
    
    enum ImageQuality: CGFloat{
        case low = 0.25
        case medium = 0.5
        case high = 0.75
    }
    
    //获取压缩的jpeg
    func getJpeg(_ imageQuality: ImageQuality) -> Data?{
        jpegData(compressionQuality: imageQuality.rawValue)
    }
    
    var isLiked: Bool{
        false
    }
    
}

extension Date{
    func formatDate(isoDate:String) -> String{
        
        if isoDate == "刚刚"{
            return isoDate
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        let date = dateFormatter.date(from:isoDate)!

        return date.formatterDate
    }
    //时间格式化
    var formatterDate: String{
        let currentYear = Date().year
        
        if year == currentYear {//今年
            if isToday{
                if minutesAgo > 60{
                    return format(with: "今天HH:mm")
                }else{
                    return timeAgoSinceNow
                }
            }else if isYesterday{//昨天
                return format(with: "昨天HH:mm")
            }else{//前天及之前
                return format(with: "MM-dd")
            }
        }else if year < currentYear{//往年
            return format(with: "yyyy-MM-dd")
        }else{
            return "error time"
        }
    }
}

extension String{
    func spliceAttrStr(_ dateStr: String) -> NSAttributedString{
        let attrText = toAttrStr()
        let attrDate = "  \(dateStr)".toAttrStr(12,.secondaryLabel)
        
        attrText.append(attrDate)
        
        return attrText
    }
    
    func toAttrStr(_ fontSize: CGFloat = 14, _ color:UIColor = .label) -> NSMutableAttributedString{
        let attr: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: fontSize),
            .foregroundColor : color
        ]
        return NSMutableAttributedString(string: self, attributes: attr)
    }
}

extension UserDefaults{
    static func increase(_ key:String, by val:Int = 1){
        standard.set(standard.integer(forKey: key) + val, forKey: key)
    }
    
    static func decrease(_ key:String, by val:Int = 1){
        standard.set(standard.integer(forKey: key) - val, forKey: key)
    }
}

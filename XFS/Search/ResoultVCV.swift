//
//  ResoultVCViewController.swift
//  XFS
//
//  Created by Jerry Zhu on 2023/1/6.
//

import UIKit
import XLPagerTabStrip

class ResoultVC: ButtonBarPagerTabStripViewController {
    
    var keyword:String?{
        didSet{
            guard let _ = self.keyword else {return}
            self.reloadPagerTabStripView()
        }
    }

    override func viewDidLoad() {
        self.settings.style.selectedBarHeight = 0
        
        self.settings.style.buttonBarBackgroundColor = .clear
        self.settings.style.buttonBarItemBackgroundColor = .clear
        self.settings.style.buttonBarItemTitleColor = .label
        self.settings.style.buttonBarItemFont = .systemFont(ofSize: 16)
        self.settings.style.buttonBarLeftContentInset = 16
        self.settings.style.buttonBarItemsShouldFillAvailableWidth = false
        super.viewDidLoad()

         
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }

            oldCell?.label.textColor = UIColor.secondaryLabel
            newCell?.label.textColor = UIColor.label
            newCell?.label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 20))

            //选中文字大小动画
            if animated {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    oldCell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                })
            }
            else {
                newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                oldCell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
        }
    }
    

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let noteVC = sb.instantiateViewController(identifier: kWaterFallVCID) as! WaterFallVC
        let userVC = UserTableView()
        noteVC.cellType = .search
        noteVC.seachKeyWord = keyword
        noteVC.channel = "笔记"
        userVC.keyword = keyword
        return [noteVC,userVC]
    }

}

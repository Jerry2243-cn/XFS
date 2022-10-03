//
//  HomeVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/2.
//

import UIKit
import XLPagerTabStrip

class HomeVC: ButtonBarPagerTabStripViewController{

    override func viewDidLoad() {
        
        // MARK: 顶部导航栏
        
        //顶部tab item下的横条颜色和高度
        self.settings.style.selectedBarBackgroundColor = UIColor(named: "main_color")!
        self.settings.style.selectedBarHeight = 3
        
        //顶部item
        self.settings.style.buttonBarItemBackgroundColor = .clear
        self.settings.style.buttonBarItemTitleColor = .label
        self.settings.style.buttonBarItemFont = .systemFont(ofSize: 18)
        
        super.viewDidLoad()
        
        containerView.bounces = false
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
        
//        DispatchQueue.main.async {
//            self.moveToViewController(at: 1, animated: false)
//        }

        // Do any additional setup after loading the view.
    }
    
    
    //加载三个子视图
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let DiscoverVC = storyboard!.instantiateViewController(identifier: kDiscoverVCID)
        let FellowVC = storyboard!.instantiateViewController(identifier: kFellowVCID)
        let NearbyVC = storyboard!.instantiateViewController(identifier: kNearbyVCID) as! NearbyVC
        NearbyVC.location = "同城"
        return [DiscoverVC, FellowVC, NearbyVC]
    }
    
    

}

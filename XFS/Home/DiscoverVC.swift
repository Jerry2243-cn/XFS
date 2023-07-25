//
//  DiscoverVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/2.
//

import UIKit
import XLPagerTabStrip

class DiscoverVC: ButtonBarPagerTabStripViewController, IndicatorInfoProvider {
    
    var channels = kChannels

    override func viewDidLoad() {
        showLoadHUD()
           
        
        
        self.settings.style.selectedBarHeight = 0
        
        self.settings.style.buttonBarBackgroundColor = .clear
        self.settings.style.buttonBarItemBackgroundColor = .clear
        self.settings.style.buttonBarItemTitleColor = .label
        self.settings.style.buttonBarItemFont = .systemFont(ofSize: 16)
        
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
        // Do any additional setup after loading the view.
            Server.shared().fetchChannelsfromServer { res in
                if let channels = res {
                    if channels.count != 0 {
                        self.channels = channels
                        kChannels = channels
                        kChannels.remove(at: 0)
                        debugPrint(self.channels)
                    }
                }
                    self.reloadPagerTabStripView()
                
                self.hideHUD()
        }
    }


    
    func indicatorInfo(for pagerTabStripController: XLPagerTabStrip.PagerTabStripViewController) -> XLPagerTabStrip.IndicatorInfo {
        IndicatorInfo(title: "发现")
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var vcs:[UIViewController] = []
        for channel in channels{
            let vc = storyboard!.instantiateViewController(identifier: kWaterFallVCID) as! WaterFallVC
            vc.channel = channel
            vc.cellType = .discover
            vcs.append(vc)
        }
        return vcs
    }

}

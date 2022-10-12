//
//  TopicSelectVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/9.
//

import UIKit
import XLPagerTabStrip

class TopicSelectVC: ButtonBarPagerTabStripViewController {
    
    var PVDelegate: TopicSelectViewControllerDelegate?

    override func viewDidLoad() {
        self.settings.style.selectedBarHeight = 2
        self.settings.style.selectedBarBackgroundColor = UIColor(named: "main_color")!
        
        self.settings.style.buttonBarBackgroundColor = .clear
        self.settings.style.buttonBarItemBackgroundColor = .clear
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
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var vcs:[UIViewController] = []
        for i in kChannels.indices{
            let vc = storyboard!.instantiateViewController(identifier: kTopicTableVCID) as! TopicTableVC
            vc.channel = kChannels[i]
            vc.topics = kTopics[i]
            vcs.append(vc)
        }
        return vcs
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  MeVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/18.
//

import UIKit
import Alamofire
import SegementSlide

class MeVC: SegementSlideDefaultViewController {

    override func segementSlideHeaderView() -> UIView? {
           let headerView = UIView()
           headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = mainColor
           headerView.heightAnchor.constraint(equalToConstant: view.bounds.height/4).isActive = true
           return headerView
       }

       override var titlesInSwitcher: [String] {
           return ["笔记", "收藏", "赞过"]
       }
    
    override var switcherConfig: SegementSlideDefaultSwitcherConfig{
        var congfig = super.switcherConfig
        congfig.type = .tab
        congfig.selectedTitleColor = .label
        congfig.indicatorColor = mainColor!
        return congfig
    }

       override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
           let vc = storyboard!.instantiateViewController(withIdentifier: kWaterFallVCID) as! WaterFallVC
           vc.cellType = .discover
           return vc
       }

       override func viewDidLoad() {
           super.viewDidLoad()
           
           scrollView.backgroundColor = .systemBackground
           contentView.backgroundColor = .systemBackground
           switcherView.backgroundColor = .systemBackground
           
           defaultSelectedIndex = 0
           reloadData()
       }
}

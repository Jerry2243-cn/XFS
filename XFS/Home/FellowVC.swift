//
//  FellowVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/3.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import XLPagerTabStrip
import SKPhotoBrowser
import MJRefresh
import SnapKit

class FellowVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let fellowVC = storyboard!.instantiateViewController(identifier: kWaterFallVCID) as! WaterFallVC
        fellowVC.cellType = .fellow
        let wf = fellowVC.collectionView!
        view.addSubview(wf)
        
        wf.snp.makeConstraints { make in
            make.left.top.right.bottom.equalTo(view)
        }
        
    }

}

extension FellowVC: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        IndicatorInfo(title: "关注")
    }
}


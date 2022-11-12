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
    
    @objc func go(){
        let vc = storyboard!.instantiateViewController(withIdentifier: "naviDraftNote") as! UINavigationController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    
    @objc func settingOrChatBtnAct(){
        let nav = UINavigationController(rootViewController: SettingsVC())
//        nav.modalPresentationStyle = .fullScreen;
        self.present(nav, animated: true)
    }

    override func segementSlideHeaderView() -> UIView? {
        let headerView = Bundle.loadView(fromNIb: "MeHeaderView", with: MeHeaderView.self)
        headerView.shareBUtton.addTarget(self, action: #selector(go), for: .touchUpInside)
        headerView.settingsOrChatButton.addTarget(self, action: #selector(settingOrChatBtnAct), for: .touchUpInside)
           headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: headerView.rootStackView.frame.height + 16  ).isActive = true
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
           

           let statusBarOverlayView =  UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: statusBarH))
           statusBarOverlayView.backgroundColor = .systemBackground
           view.addSubview(statusBarOverlayView)
           scrollView.backgroundColor = .systemBackground
           contentView.backgroundColor = .systemBackground
           switcherView.backgroundColor = .systemBackground
           
           defaultSelectedIndex = 0
           reloadData()
       }
}

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
    
    var user:User?
    
    lazy var leftBtn = {
       let btn = UIButton()
        btn.tintColor = .label
        btn.setImage(UIImage(named: "line.3.horizontal"), for: .normal)
        return btn
    }()
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBAction func gotoDraft(_ sender: Any) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "naviDraftNote") as! UINavigationController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc func settingOrChatBtnAct(){
        hidesBottomBarWhenPushed = true
        let vc = SettingsVC()
//        vc.hero.isEnabled = false
        navigationController?.pushViewController(vc, animated: true)
        hidesBottomBarWhenPushed = false
    }
    
    @objc func editOrFellowAct(){
        if let _ = self.user {
            
        }else{
            hidesBottomBarWhenPushed = true
            let vc = UserInfoEditVC()
            vc.user = appDelegate.user
            navigationController?.pushViewController(vc, animated: true)
            hidesBottomBarWhenPushed = false
        }
    }

    override func segementSlideHeaderView() -> UIView? {
        let headerView = Bundle.loadView(fromNIb: "MeHeaderView", with: MeHeaderView.self)
        headerView.user = appDelegate.user
        headerView.settingsOrChatButton.addTarget(self, action: #selector(settingOrChatBtnAct), for: .touchUpInside)
        headerView.editOrFellowButton.addTarget(self, action: #selector(editOrFellowAct), for: .touchUpInside)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: headerView.rootStackView.frame.height).isActive = true
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
    
    override var bouncesType: BouncesType {
        return .child
    }

       override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
           if index == 0 {
               let vc = storyboard!.instantiateViewController(withIdentifier: kWaterFallVCID) as! WaterFallVC
               vc.cellType = .mine
               return vc
           }
           if index == 1 {
               let vc = storyboard!.instantiateViewController(withIdentifier: kWaterFallVCID) as! WaterFallVC
               vc.cellType = .star
               return vc
           }
           if index == 2{
               let vc = storyboard!.instantiateViewController(withIdentifier: kWaterFallVCID) as! WaterFallVC
               vc.cellType = .like
               return vc
           }
           return storyboard!.instantiateViewController(withIdentifier: kWaterFallVCID) as! WaterFallVC
       }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.view.backgroundColor = .systemBackground
    }

       override func viewDidLoad() {
           super.viewDidLoad()

           shareButton.setTitle("", for: .normal)
//           self.navigationController?.navigationBar.backgroundColor = .systemBackground
           navigationItem.backButtonDisplayMode = .minimal
           navigationItem.title = ""
        
           navigationController?.navigationBar.isTranslucent = false
           navigationController?.view.backgroundColor = .systemBackground
//           let statusBarOverlayView =  UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: statusBarH))
//           statusBarOverlayView.backgroundColor = .systemBackground
//           view.addSubview(statusBarOverlayView)
           scrollView.backgroundColor = .systemBackground
           contentView.backgroundColor = .systemBackground
           switcherView.backgroundColor = .systemBackground
           
           defaultSelectedIndex = 0
           reloadData()
       }
}

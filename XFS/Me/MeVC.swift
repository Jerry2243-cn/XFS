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
    
    var isNoteUser = false
    
    var isTabIten = true{
        didSet {
            if !isTabIten{
                navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(goBack))
            }
        }
    }
    
    var user:User?{
        didSet{
            guard let user = self.user else {return}
            if user.id != appDelegate.user?.id{
                if user.fellow{
                    infohHeaderView.editOrFellowButton.setTitle("已关注", for: .normal)
                    infohHeaderView.editOrFellowButton.setTitleColor(.secondaryLabel, for: .normal)
                    infohHeaderView.editOrFellowButton.tintColor = .secondaryLabel
                    infohHeaderView.editOrFellowButton.layer.borderColor = UIColor.secondaryLabel.cgColor
                }else{
                    infohHeaderView.editOrFellowButton.setTitle("关注", for: .normal)
                    infohHeaderView.editOrFellowButton.setTitleColor(mainColor, for: .normal)
                    infohHeaderView.editOrFellowButton.tintColor = mainColor
                    infohHeaderView.editOrFellowButton.layer.borderColor = mainColor?.cgColor
                }
                let button = infohHeaderView.settingsOrChatButton!
                let largeConfig = UIImage.SymbolConfiguration(scale: .small)
                       
                let largeBoldDoc = UIImage(systemName: "ellipsis.message", withConfiguration: largeConfig)

                button.setImage(largeBoldDoc, for: .normal)
                
            }
        }
    }
    
    lazy var infohHeaderView: MeHeaderView = {
        let view = Bundle.loadView(fromNIb: "MeHeaderView", with: MeHeaderView.self)
        view.user = user ?? appDelegate.user
        view.settingsOrChatButton.addTarget(self, action: #selector(settingOrChatBtnAct), for: .touchUpInside)
        view.editOrFellowButton.addTarget(self, action: #selector(editOrFellowAct), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: view.rootStackView.frame.height).isActive = true
        return view
    }()
    
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
    
    @objc func goBack(){
        dismiss(animated: true)
    }
    
    @objc func settingOrChatBtnAct(){
        hidesBottomBarWhenPushed = true
        let vc = SettingsVC()
        navigationController?.pushViewController(vc, animated: true)
        hidesBottomBarWhenPushed = false
    }
    
    @objc func editOrFellowAct(){
        if isTabIten || user?.id == appDelegate.user?.id {
            hidesBottomBarWhenPushed = true
            let vc = UserInfoEditVC()
            vc.user = appDelegate.user
            navigationController?.pushViewController(vc, animated: true)
            hidesBottomBarWhenPushed = false
        }else{
            fellow()
        }
    }
    
    @objc func fellow(){
        guard var user = self.user else {return}
        
        let fellowButton = infohHeaderView.editOrFellowButton!
        if user.fellow{
            user.fans -= 1
            appDelegate.user?.fellowNumber -= 1
            fellowButton.tintColor = mainColor
            fellowButton.layer.borderColor = mainColor?.cgColor
            fellowButton.setTitle("关注", for: .normal)
            fellowButton.setTitleColor(mainColor, for: .normal)
            user.fellow = false
        }else{
            user.fans += 1
            appDelegate.user?.fellowNumber += 1
            fellowButton.tintColor = .secondaryLabel
            fellowButton.layer.borderColor = UIColor.secondaryLabel.cgColor
            fellowButton.setTitle("已关注", for: .normal)
            fellowButton.setTitleColor(.secondaryLabel, for: .normal)
            user.fellow = true
        }
        infohHeaderView.fansLabel.text = "\(user.fans)"
        if isNoteUser {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kFellow), object: nil)
        }else{
            Server.shared().fellowUser(userId: user.id){ res in
                if let resoult = res{
                    if resoult == "操作成功"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateFellow), object: user.id)
                    }
                }else{
                    print("error")
                }
            }
        }
       
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView, isParent: Bool) {
        super.scrollViewDidScroll(scrollView, isParent: isParent)
        guard isParent else {
            return
        }
        updateNavigationBarStyle(scrollView)
    }
    
    private func updateNavigationBarStyle(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 50{
            navigationItem.title = user?.nickname ?? appDelegate.user?.nickname
        } else {
            navigationItem.title = ""
        }
    }

    override func segementSlideHeaderView() -> UIView? {
        infohHeaderView
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
               vc.userId = user?.id ?? appDelegate.user?.id
               let hasDraft = user == nil && UserDefaults.standard.integer(forKey: userDefaultsDraftNotesCount) > 0
               vc.hasDraftNote = hasDraft
               return vc
           }
           if index == 1 {
               let vc = storyboard!.instantiateViewController(withIdentifier: kWaterFallVCID) as! WaterFallVC
               vc.cellType = .star
               vc.userId = user?.id ?? appDelegate.user?.id
               return vc
           }
           if index == 2{
               let vc = storyboard!.instantiateViewController(withIdentifier: kWaterFallVCID) as! WaterFallVC
               vc.cellType = .like
               vc.userId = user?.id ?? appDelegate.user?.id
               return vc
           }
           return storyboard!.instantiateViewController(withIdentifier: kWaterFallVCID) as! WaterFallVC
       }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.view.backgroundColor = .systemBackground
    }

//    init?(coder: NSCoder, user:User) {
//        self.user = user
//        super.init(coder: coder)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError()
//    }
    
       override func viewDidLoad() {
           super.viewDidLoad()
//           user = appDelegate.user
           shareButton.setTitle("", for: .normal)

           navigationItem.backButtonDisplayMode = .minimal
           navigationItem.title = ""
        
           navigationController?.navigationBar.isTranslucent = false
           navigationController?.view.backgroundColor = .systemBackground

           scrollView.backgroundColor = .systemBackground
           contentView.backgroundColor = .systemBackground
           switcherView.backgroundColor = .systemBackground
           
           defaultSelectedIndex = 0
           reloadData()
       }
}

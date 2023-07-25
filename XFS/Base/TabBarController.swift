//
//  TabBarController.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/3.
//

import UIKit
import YPImagePicker

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        let tabBarApperance = UITabBarAppearance()
        tabBarApperance.configureWithDefaultBackground()

        let tabBarItemApperance = UITabBarItemAppearance()
        
        tabBarItemApperance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -14)
        tabBarItemApperance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -14)
        tabBarItemApperance.normal.titleTextAttributes = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .medium)
        ]
        
        tabBarItemApperance.selected.titleTextAttributes = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .heavy)
        ]
        
        tabBarApperance.stackedLayoutAppearance = tabBarItemApperance
        
        tabBar.standardAppearance = tabBarApperance
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Server.shared().token == ""{
            let vc = LoginVC()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is PublishVC {
            
            var config = YPImagePickerConfiguration()
            config.isScrollToChangeModesEnabled = false
            config.onlySquareImagesFromCamera = false
            config.usesFrontCamera = true
            config.albumName = "小粉书"
            config.startOnScreen = YPPickerScreen.library
            config.screens = [.library, .photo]
//            config.overlayView = UIView()

            config.maxCameraZoomFactor = 5.0
            
            config.library.defaultMultipleSelection = true
            config.library.maxNumberOfItems = kMaxPhotoCount
            config.library.spacingBetweenItems = 1.5
            config.library.preSelectItemOnMultipleSelection = false
            
//            config.gallery.hidesRemoveButton = false
            
            let picker = YPImagePicker(configuration: config)
            
            YPImagePickerConfiguration.shared = config
            
            picker.didFinishPicking { [unowned picker] items, cancelled in
                if cancelled {
                    print("用户点击取消按钮")
                    picker.dismiss(animated: true)
                    
                }
                
                let vc = self.storyboard!.instantiateViewController(withIdentifier: kNoteEditingVC) as! NoteEditingVC
                var photos:[UIImage] = []
                for item in items{
                    switch item{
                    case let .photo(photo):
                        photos.append(photo.image)
                    default:
                        continue
                    }
                }
                vc.photos = photos
                vc.saveNoteOptions = {
                    self.showTextHUD(showView: self.view, "笔记保存成功")
                }
                vc.publishNoteOptions = {
                    self.showTextHUD(showView: self.view, "笔记发布成功")
                }
                picker.pushViewController(vc, animated: true)
            }
            present(picker, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }

}

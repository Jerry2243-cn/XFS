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
//
        let tabBarItemApperance = UITabBarItemAppearance()
        
        tabBarItemApperance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -13)
        tabBarItemApperance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -13)
        tabBarItemApperance.normal.titleTextAttributes = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .light)
        ]
        
        tabBarItemApperance.selected.titleTextAttributes = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .heavy)
        ]
        
        tabBarApperance.stackedLayoutAppearance = tabBarItemApperance
        
        tabBar.standardAppearance = tabBarApperance

    }
    
   
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is PublishVC {
            
            var config = YPImagePickerConfiguration()
            config.isScrollToChangeModesEnabled = false
            config.onlySquareImagesFromCamera = false
            config.usesFrontCamera = true
            config.albumName = "小粉书"
            config.startOnScreen = YPPickerScreen.library
            config.screens = [.library, .photo, .video]
//            config.overlayView = UIView()

            config.maxCameraZoomFactor = 5.0
            
            config.library.defaultMultipleSelection = true
            config.library.maxNumberOfItems = 9
            config.library.minNumberOfItems = 1
            config.library.spacingBetweenItems = 1.5
            config.library.preSelectItemOnMultipleSelection = false
            
//            config.gallery.hidesRemoveButton = false
            
            let picker = YPImagePicker(configuration: config)
            
            YPImagePickerConfiguration.shared = config
            
            picker.didFinishPicking { [unowned picker] items, cancelled in
                if cancelled {
                    print("用户点击取消按钮")
                }
                
                picker.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
            
            return false
        }
        
        
        return true
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

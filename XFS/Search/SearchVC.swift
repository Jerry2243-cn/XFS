//
//  SearchVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/12.
//

import UIKit
import XLPagerTabStrip
import Hero

class SearchVC:UIViewController ,UISearchBarDelegate {

    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchBar.text = ""
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //搜索操作
        searchBar.resignFirstResponder()
        let vc = SearchResoultVC()
        vc.keyWords = searchBar.text
        vc.modalPresentationStyle = .fullScreen
        vc.hero.isEnabled = true
        vc.hero.modalAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .pull(direction: .right))
        present(vc, animated: true)
    }

//    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
//        let noteVC = storyboard!.instantiateViewController(identifier: kWaterFallVCID) as!WaterFallVC
//        noteVC.channel = "笔记"
//        noteVC.cellType = .discover
//        let userVC = storyboard!.instantiateViewController(identifier: kWaterFallVCID) as!WaterFallVC
//        userVC.channel = "用户"
//        userVC.cellType = .fellow
//
//        return [noteVC]
//    }
  
}

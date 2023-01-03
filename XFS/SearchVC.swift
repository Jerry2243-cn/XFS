//
//  SearchVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/12.
//

import UIKit
import XLPagerTabStrip

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
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //搜索操作
        searchBar.resignFirstResponder()
    }

//    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
//        let noteVC = storyboard!.instantiateViewController(identifier: kWaterFallVCID) as!WaterFallVC
//        noteVC.channel = "笔记"
//        noteVC.cellType = .discover
//        let userVC = storyboard!.instantiateViewController(identifier: kWaterFallVCID) as!WaterFallVC
//        userVC.channel = "用户"
//        userVC.cellType = .fellow
//
//        return [noteVC,userVC]
//    }
  
}

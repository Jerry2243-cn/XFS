//
//  SearchResoultVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2023/1/3.
//

import UIKit
import SnapKit

class SearchResoultVC: UIViewController, UISearchBarDelegate {
    
    var keyWords:String?{
        didSet{
            guard let keyWords = self.keyWords else {return}
            nav.searchBar.text = keyWords
            searchAction(keyWords)
        }
    }
    
    let nav = SearchNavigationBar()
    let vc = ResoultVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        addChild(vc)
        view.addSubview(vc.view)
        nav.searchBar.delegate = self
        vc.view.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(nav.snp.bottom)
        }
    }
    

    func setUI(){
        view.backgroundColor = .systemBackground
        view.addSubview(nav)
        nav.backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }
    
    func searchAction(_ keyWords:String){
        vc.keyword = keyWords
    }
    
    @objc func goBack(){
        dismiss(animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //搜索操作
        searchBar.resignFirstResponder()
        vc.keyword = searchBar.text
    }
}

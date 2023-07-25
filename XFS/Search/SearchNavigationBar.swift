//
//  SearchNavigationBar.swift
//  XFS
//
//  Created by Jerry Zhu on 2023/1/6.
//

import UIKit
import SnapKit

class SearchNavigationBar: BaseNavigationBar {

    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    override init() {
        super.init()
        setNavigationBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNavigationBar() {
        self.addSubview(searchBar)
        
        searchBar.snp.makeConstraints { make in
            make.left.equalTo(backButton.snp.right)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
}

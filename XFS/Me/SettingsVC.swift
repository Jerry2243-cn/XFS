//
//  SettingsVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/11/4.
//

import UIKit
import SnapKit

class SettingsVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    
    lazy var settingsTableView: UITableView = {
        let tableView = UITableView(frame: CGRect())
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }

    func setUI(){
        view.backgroundColor = .systemBackground
        navigationItem.title = "设置"
        settingsTableView.register(SettingsCell.self, forCellReuseIdentifier: "settingsCell")
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        view.addSubview(settingsTableView)
        settingsTableView.snp.makeConstraints { make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view).offset(44)
            make.bottom.equalTo(self.view.snp.bottom)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0 :
            return 2
        case 1 :
            return 3
        case 2 :
            return 1
        case 3 :
            return 5
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rows = tableView.numberOfRows(inSection: indexPath.section)
     
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsCell
//        switch indexPath.section{
//        case 0 :
//            if indexPath.row == 0 {
//                cell.titleLabel.text = "账号与安全"
//            }
//        case 1 :
//            return 3
//        case 2 :
//            return 1
//        case 3 :
//            return 5
//        default:
//            return 0
//        }
            cell.titleLabel.text = "账号与安全"
        return cell
    }
    

}

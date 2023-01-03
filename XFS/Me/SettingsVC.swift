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
        let tableView = UITableView(frame: CGRect(),style: .insetGrouped)
//        tableView.backgroundColor = .systemBackground
        tableView.bounces = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    func setUI(){
        navigationController?.view.backgroundColor = .secondarySystemBackground
        view.backgroundColor = .secondarySystemBackground
        navigationItem.title = "设置"
        settingsTableView.register(SettingsCell.self, forCellReuseIdentifier: "settingsCell")
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        view.addSubview(settingsTableView)
        settingsTableView.snp.makeConstraints { make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.bottom.equalTo(self.view)
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
            return 1
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsCell
        cell.accessoryType = .disclosureIndicator
        switch indexPath.section{
        case 0 :
            if indexPath.row == 0 {
                cell.titleLabel.text = "账号与安全"
            }else{
                cell.titleLabel.text = "隐私设置"
            }
        case 1 :
            if indexPath.row == 0{
                cell.titleLabel.text = "通知设置"
            }else if indexPath.row == 1{
                cell.titleLabel.text = "通用设置"
            }else{
                cell.titleLabel.text = "深色模式"
            }
        case 2 :
                cell.titleLabel.text = "关于小粉书"
        case 3 :
            cell.titleLabel.text = "退出登录"
            cell.isLogout = true
            cell.accessoryType = .none
        default:
            cell.titleLabel.text = "error"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 3:
            logoutAlert()
        default:
            debugPrint(indexPath.section)
        }
    }
    
    func logout(){
        UserDefaults.standard.removeObject(forKey: userDefaultsTokenKey)
        Server.shared().token = ""
        let nav = UINavigationController(rootViewController: LoginVC())
        UIApplication.shared.windows.first?.rootViewController = nav
    }
    
    private func logoutAlert(){
        let alert = UIAlertController(title: "确认退出登录嘛", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel){_ in
            
        }
        let delete = UIAlertAction(title: "确认", style: .default){_ in
            self.logout()
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        present(alert, animated: true)
    }
}

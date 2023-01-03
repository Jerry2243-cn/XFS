//
//  UserInfoEditVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/12/15.
//

import UIKit
import Kingfisher

class UserInfoEditVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var user:User?{
        didSet{
            guard let user = self.user else {return}
            if let avatar = user.avatar {
                let url = URL(string: avatar)
                avatarImageView.kf.setImage(with: url)
            }else{
                avatarImageView.image = defaultAvatar
            }
        }
    }
    
    lazy var headerView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 180))
        let icon = UIImageView(image: UIImage(systemName: "camera.circle.fill"))
        icon.tintColor = .label
        icon.backgroundColor = .systemBackground
        icon.cornerRedius = 15
        view.addSubview(avatarImageView)
        view.addSubview(icon)
        avatarImageView.snp.makeConstraints { make in
            make.center.equalTo(view)
            make .width.height.equalTo(100)
        }
        icon.snp.makeConstraints { make in
            make.right.equalTo(avatarImageView)
            make.bottom.equalTo(avatarImageView)
            make.height.width.equalTo(30)
        }
        return view
    }()
    
    lazy var userInfoTableView = {
        let tableView = UITableView()
        tableView.tableHeaderView = self.headerView
        return tableView
    }()
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRedius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "编辑资料"
        view.backgroundColor = .systemBackground
        userInfoTableView.register(UserInfoEditCell.self, forCellReuseIdentifier: "userInfoCell")
        view.addSubview(userInfoTableView)
       
        
        userInfoTableView.delegate = self
        userInfoTableView.dataSource = self 
        userInfoTableView.snp.makeConstraints { make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
     
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userInfoCell", for: indexPath) as! UserInfoEditCell
        cell.accessoryType = .disclosureIndicator
        cell.infoLabel.textColor = .label
        switch indexPath.item{
        case 0:
            cell.titleLabel.text = "昵称"
            cell.infoLabel.text = user?.nickname
        case 1:
            cell.titleLabel.text = "XFS ID"
            cell.infoLabel.text = user?.username
        case 2:
            cell.titleLabel.text = "简介"
            if let intro = user?.intro {
                cell.infoLabel.text = intro
            }else{
                cell.infoLabel.text =  "编辑简介吸引更多粉丝"
                cell.infoLabel.textColor = .secondaryLabel
            }
        case 3:
            cell.titleLabel.text = "性别"
            if let sex = user?.sex {
                cell.infoLabel.text = sex
            }else{
                cell.infoLabel.text =  "选择你的性别"
                cell.infoLabel.textColor = .secondaryLabel
            }
        case 4:
            cell.titleLabel.text = "生日"
            if let birthday = user?.birthday {
                cell.infoLabel.text = birthday
            }else{
                cell.infoLabel.text =  "填写你的生日"
                cell.infoLabel.textColor = .secondaryLabel
            }
        case 5:
            cell.titleLabel.text = "地区"
        default :
            cell.titleLabel.text = "error"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
  
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = EditPageVC()
        switch indexPath.item{
        case 0:
            vc.titleLabel.text = "昵称"
        case 1:
            vc.titleLabel.text = "XFS ID"
        case 2:
            vc.titleLabel.text = "简介"
        case 3:
            vc.titleLabel.text = "性别"
        case 4:
            vc.titleLabel.text = "生日"
        case 5:
            vc.titleLabel.text = "地区"
        default :
            vc.titleLabel.text = "error"
        }
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

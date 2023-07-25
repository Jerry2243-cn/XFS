//
//  UserTableView.swift
//  XFS
//
//  Created by Jerry Zhu on 2023/1/6.
//

import UIKit
import XLPagerTabStrip
import MJRefresh
import Hero

class UserTableView: UITableViewController {
    
    var keyword:String?
    var isGotAllData = false
    var currentPage = 0
    var users:[User] = []
    
    lazy var footer = MJRefreshAutoNormalFooter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .systemBackground
        getUsers()
        tableView.register(UserCell.self, forCellReuseIdentifier: kUserCellID)
        tableView.mj_footer = footer
        tableView.mj_footer?.setRefreshingTarget(self, refreshingAction:  #selector(loadMoreData))
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kUserCellID) as! UserCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! UserCell
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: kMeVCID) as! MeVC
        vc.user = cell.user
        vc.isTabIten = false
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.hero.isEnabled = true
        nav.hero.modalAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .pull(direction: .right))
        present(nav, animated: true)
    }

    func getUsers(){
        guard let keyword = self.keyword else {return}
        showLoadHUD()
        Server.shared().searchUsers(keyword:keyword, page: currentPage) { [self] res in
            hideHUD()
            guard let users = res else { self.showTextHUD(showView: self.view, "用户加载失败"); return}
            if users.count == 0{
                isGotAllData = true
                if currentPage == 0 {
                    self.showTextHUD(showView: self.view, "未找到相关用户")
                }
            }else{
                for user in users {
                    self.users.append(user)
                }
                if users.count < eachPageCount{
                    footer.endRefreshingWithNoMoreData()
                }else{
                    footer.endRefreshing()
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            tableView.mj_footer?.endRefreshing()
        }
    }
    
    @objc func loadMoreData(){
        if !isGotAllData{
            currentPage += 1
            getUsers()
        }else{
            footer.endRefreshingWithNoMoreData()
        }
    }
}

extension UserTableView: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: XLPagerTabStrip.PagerTabStripViewController) -> XLPagerTabStrip.IndicatorInfo {
        IndicatorInfo(title: "用户")
    }
}

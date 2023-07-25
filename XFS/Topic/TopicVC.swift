//
//  TopicVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2023/1/5.
//

import UIKit
import SnapKit
import MJRefresh
import Hero

class TopicVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var topics:[Topic] = []
    
    lazy var header = MJRefreshNormalHeader()
    
    lazy var topicTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(),style: .insetGrouped)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        topicTableView.delegate = self
        topicTableView.dataSource = self
        
        topicTableView.mj_header = header
        topicTableView.mj_header?.setRefreshingTarget(self, refreshingAction:  #selector(refreshData))
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .systemBackground
        navigationItem.backButtonDisplayMode = .minimal
        setUI()
        loadData()
    }
    
    func setUI(){
        view.addSubview(topicTableView)
        self.navigationController?.view.backgroundColor = .systemBackground
        topicTableView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(view)
        }
    }
    
    @objc func refreshData(){
        loadData()
        
    }
    
    func loadData(){
        Server.shared().fetchTopicsFromServer{ data in
            if let topics = data{
                self.topics = topics
                self.topicTableView.mj_header?.endRefreshing()
                self.topicTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 15
        }
        return 6
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView(frame: CGRect(x: .zero, y: .zero, width: view.bounds.width, height: 6))
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView(frame: CGRect(x: .zero, y: .zero, width: view.bounds.width, height: 6))
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
       6
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        topics.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let index = indexPath.section
        cell.textLabel?.text = "\(index + 1) \(topics[index].name)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        topics[indexPath.section].views += 1
        
        let vc = TopicDetailVC()
        vc.topic = topics[indexPath.section]
        vc.modalPresentationStyle = .fullScreen
        vc.hero.isEnabled = true
        vc.hero.modalAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .pull(direction: .right))
        present(vc, animated: true)
    }
}

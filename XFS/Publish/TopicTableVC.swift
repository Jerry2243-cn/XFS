//
//  TopicTableVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/9.
//

import UIKit
import XLPagerTabStrip

class TopicTableVC: UITableViewController, IndicatorInfoProvider {
    
    var channel = ""
    var topics: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

       loadData()
    }

    func loadData(){
        showLoadHUD()
        Server.shared().fetchTopicsByChannel(channel: channel) { data in
            self.hideHUD()
            if let topics = data{
                self.topics = topics
                self.tableView.reloadData()
            }
        }
    }
    
    func indicatorInfo(for pagerTabStripController: XLPagerTabStrip.PagerTabStripViewController) -> XLPagerTabStrip.IndicatorInfo {
        IndicatorInfo(title: channel)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return topics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kTopicCellID, for: indexPath)
        
        cell.textLabel?.text("#"+topics[indexPath.item])
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topicSelectVC = parent as! TopicSelectVC
//        NotificationCenter.default.post(name: .updateTopic, object: ["title": "test"])
        topicSelectVC.PVDelegate?.updateTopic(channel: channel, topic: topics[indexPath.item])
        dismiss(animated: true)
    }

}

//extension Notification.Name {
//    static let updateTopic = Notification.Name.init("updateTopic")
//}

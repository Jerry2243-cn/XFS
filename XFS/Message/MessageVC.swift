//
//  MessageVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/23.
//

import UIKit

class MessageVC: UIViewController {
    
    lazy var newChatButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "开启聊天"
        button.tintColor = .label
        button.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium)
        ], for: .normal)
        return button
    }()
    
    @IBAction func likeButton(_ sender: Any) {
        hidesBottomBarWhenPushed = true
        let vc = storyboard?.instantiateViewController(withIdentifier: kNotficationLIstVC) as! NotficationLIstVC
        vc.navigationItem.title = "新的喜欢"
        navigationController?.pushViewController(vc, animated: true)
        hidesBottomBarWhenPushed = false
    }
    @IBAction func fellowButton(_ sender: Any) {
        hidesBottomBarWhenPushed = true
        let vc = storyboard?.instantiateViewController(withIdentifier: kNotficationLIstVC) as! NotficationLIstVC
        vc.navigationItem.title = "新的关注"
        navigationController?.pushViewController(vc, animated: true)
        hidesBottomBarWhenPushed = false
    }
    @IBAction func commentButton(_ sender: Any) {
        hidesBottomBarWhenPushed = true
        let vc = storyboard?.instantiateViewController(withIdentifier: kNotficationLIstVC) as! NotficationLIstVC
        vc.navigationItem.title = "新的评论"
        navigationController?.pushViewController(vc, animated: true)
        hidesBottomBarWhenPushed = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = newChatButton
        navigationItem.backButtonDisplayMode = .minimal
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



extension MessageVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kMessageCellID, for: indexPath) as! MessageCell
        cell.avatarImage.image = UIImage(named: "\(indexPath.item + 1)")
        cell.nicknameLabel.text = "🐔你太美"
        cell.timeLabel.text = "2020-4-20"
        cell.lastMessageLabel.text = "练习结果如何？"
        return cell
    }
    
    
}

extension MessageVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       showTextHUD(showView: view, "push聊天界面（待做：new folder）")
        tableView.selectionFollowsFocus = false
    }
}

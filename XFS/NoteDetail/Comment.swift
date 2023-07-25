//
//  Comment.swift
//  XFS
//
//  Created by Jerry Zhu on 2023/1/5.
//

import UIKit

extension NoteDetailVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let commentView = tableView.dequeueReusableHeaderFooterView(withIdentifier: kCommentViewID) as! CommentView
        let comment = comments[section]
        commentView.comment = comment
        commentView.isAuthor = comment.user.id == note.user.id
        let commentTap = UITapGestureRecognizer(target: self, action: #selector(commentTapped))
        commentView.addGestureRecognizer(commentTap)
        commentView.tag = section
        return commentView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        tableView.dequeueReusableHeaderFooterView(withIdentifier: kCommentSectionFooterView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let comment = comments[section]
        let repliesCount = comments[section].replies?.count ?? 0
        if repliesCount > 1 && !(comment.showAllreplies ?? false) {
            return 1
        }else{
            return repliesCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReplayCellID, for: indexPath) as! CommentReplyCell
        guard var comment = comments[indexPath.section].replies?[indexPath.row] else {return cell}
        let superCommentReplies = comments[indexPath.section].replies ?? []
        cell.selectionStyle = .none
        cell.isAuthor = comment.user.id == note.user.id
        cell.comment = comment
        if !(comments[indexPath.section].showAllreplies ?? false) && superCommentReplies.count > 1{
            cell.showMoreButton.isHidden = false
            cell.showMoreButton.setTitle("展开\(superCommentReplies.count - 1)条回复", for: .normal)
            cell.showMoreButton.tag = indexPath.section
            cell.showMoreButton.addTarget(self, action: #selector(showMoreReplies), for: .touchUpInside)
            
        }else{
            cell.showMoreButton.isHidden = true
        }
            for reply in superCommentReplies{
                if reply.id == comment.replyId{
                    cell.replyUser = reply.user.nickname
                    break
                }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let comment = comments[indexPath.section].replies?[indexPath.row] else {return}
        commentReplyTapped(indexPath: indexPath)
    }
    
    func commentReplyTapped(indexPath:IndexPath){
        guard let comment = comments[indexPath.section].replies?[indexPath.row] else {return}
        if note.user.id == appDelegate.user?.id || comment.user.id == appDelegate.user?.id{
            let alert = UIAlertController(title: nil, message: "评论：\(comment.content)", preferredStyle: .actionSheet)
            let edit = UIAlertAction(title: "回复", style: .default){_ in
                self.reply(comment,superCommentId: self.comments[indexPath.section].id)
            }
            let delete = UIAlertAction(title: "删除", style: .destructive){_ in
                self.deleteComment(commentId: comment.id){
                    self.deleteData(section: indexPath.section, row: indexPath.row)
                    
                    debugPrint(self.deleteRows)
                    for r in self.deleteRows{
                        self.comments[indexPath.section].replies?.remove(at: r)
                    }
                    self.deleteRows = []
                    self.updateComment()
                    self.tableView.performBatchUpdates {
                        self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            //            tableView.reloadData()
                    }
                }
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel){_ in
                
            }
            
            alert.addAction(edit)
            alert.addAction(delete)
            alert.addAction(cancel)
            
            present(alert, animated: true)
        }else{
            reply(comment, superCommentId: self.comments[indexPath.section].id)
        }
    }
    
    func deleteData(section:Int, row:Int){
        let replies = comments[section].replies?.count ?? 0
        for i in 0 ..< replies{
            if comments[section].replies?[i].replyId == comments[section].replies?[row].id{
                deleteData(section: section, row: i)
            }
        }
        deleteRows.append(row)
    }
    
    @objc func commentTapped(_ tap:UIGestureRecognizer){
        guard let index = tap.view?.tag else {return}
        let comment = comments[index]
        if note.user.id == appDelegate.user?.id || comment.user.id == appDelegate.user?.id{
            let alert = UIAlertController(title: nil, message: "评论：\(comment.content)", preferredStyle: .actionSheet)
            let edit = UIAlertAction(title: "回复", style: .default){_ in
                self.reply(comment)
            }
            let delete = UIAlertAction(title: "删除", style: .destructive){_ in
                self.deleteComment(commentId: comment.id){
                    self.comments.remove(at: index)
                    self.updateComment()
                    self.tableView.reloadData()
                }
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel){_ in
                
            }
            
            alert.addAction(edit)
            alert.addAction(delete)
            alert.addAction(cancel)
            
            present(alert, animated: true)
        }else{
            reply(comment)
        }
    }
    
    func deleteComment(commentId:Int, completion: @escaping()->()){
        let alert = UIAlertController(title: "确认删除吗", message: "删除评论会连带删除对该评论的回复", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel){_ in
            
        }
        let delete = UIAlertAction(title: "删除", style: .destructive){_ in
            Server.shared().deleteComment(commentId: commentId) { res in
                if let response = res {
                    if response == "操作成功"{
                       completion()
                        return
                    }
                }
                self.showTextHUD(showView: self.view, "删除失败")
            }
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        present(alert, animated: true)
    }
    
    func reply(_ comment:Comment, superCommentId:Int? = nil){
        commentBarAppear()
        postComment.replyId = comment.id
        if let id = superCommentId{
            postComment.superCommentId = id
        }else{
            postComment.superCommentId = comment.id
        }
        commentTextView.placeholder = "回复 \(comment.user.nickname): \(comment.content)"
    }
    
    @objc func showMoreReplies(sender: UIButton){
        comments[sender.tag].showAllreplies = true
        tableView.performBatchUpdates {
            tableView.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
//            tableView.reloadData()
        }
        
    }
}

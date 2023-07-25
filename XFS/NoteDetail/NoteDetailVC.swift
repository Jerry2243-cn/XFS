//
//  NoteDetailVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/19.
//

import UIKit
import ImageSlideshow
import Alamofire
import Hero
import Kingfisher
import Motion
import GrowingTextView
import MJRefresh

class NoteDetailVC: UIViewController {

    var note:Note
    var noteDetalHeroID:String?
    var photos:[Photo]
    var comments:[Comment] = []
    
    var postComment:PostComment
    
    lazy var footer = MJRefreshAutoNormalFooter()
    
    var currentPage = 0
    var isGotAllData = false
    var deleteRows:[Int] = []
    
    @IBOutlet weak var backeButton: UIButton!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nicknameButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var fellowButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var topicButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var userImageButton: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var photosShow: ImageSlideshow!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var commontButton: BigButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var starBUtton: UIButton!
    @IBOutlet weak var commenticonButton: UIButton!
    
    @IBOutlet weak var commentBarView: UIView!
    @IBOutlet weak var commentTextView: GrowingTextView!
    
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var commentBarBottom: NSLayoutConstraint!
    
    lazy var overlayView: UIView = {
        let view = UIView(frame: view.frame)
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func commentButtonAction(_ sender: Any) {
        commentBarAppear()
    }
    
    init?(coder: NSCoder, note:Note) {
        self.note = note
        photos = note.photos.sorted(by: { p1, p2 in
            p1.orderNumber < p2.orderNumber
        })
        self.postComment = PostComment(noteId: note.id)
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        view.hero.id = noteDetalHeroID
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(slide(pan:)))
//        view.addGestureRecognizer(pan)
        setUI()
        config()
        setData()
        getComments()
        
        tableView.register(UINib(nibName: "CommentView", bundle: nil), forHeaderFooterViewReuseIdentifier: kCommentViewID)
        tableView.register(FooterView.self, forHeaderFooterViewReuseIdentifier: kCommentSectionFooterView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(goUserMine))
        userImageButton.addGestureRecognizer(tap)
        topicButton.addTarget(self, action: #selector(goTopicDetail), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
        starBUtton.addTarget(self, action: #selector(starAction), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        commontButton.addTarget(self, action: #selector(commentButtonActions), for: .touchUpInside)
        commenticonButton.addTarget(self, action: #selector(commentButtonActions), for: .touchUpInside)
        sendCommentButton.addTarget(self, action: #selector(sendCommentAction), for: .touchUpInside)
        avatarButton.addTarget(self, action: #selector(goMine), for: .touchUpInside)
        nicknameButton.addTarget(self, action: #selector(goMine), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fellow), name: NSNotification.Name(kFellow), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(commentToMine), name: NSNotification.Name(kGotoMine), object: nil)
    }

    override func viewDidLayoutSubviews() {
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = headerView.frame
        
        if frame.height != height{
            frame.size.height = height
            headerView.frame = frame
        }
    }
    
    func setData(){
        
        avatarButton.imageView?.contentMode = .scaleAspectFill
        
        if let url = note.user.avatar{
            let avatarURL = URL(string: url)
            avatarButton.kf.setImage(with: avatarURL, for: .normal)
        }else{
            avatarButton.setImage(defaultAvatar, for: .normal)
        }
        nicknameButton.setTitle(note.user.nickname, for: .normal)
        if let poi = note.poi{
            locationButton.setTitle(poi.name, for: .normal)
        }else{
            locationButton.isHidden = true
        }
        if let url = appDelegate.user?.avatar{
            let avatarURL = URL(string: url)
            userImageButton.kf.setImage(with: avatarURL)
        }else{
            userImageButton.image = defaultAvatar
        }
        if note.liked {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tintColor = .systemPink
            likeButton.setTitleColor(.label, for: .normal)
        }
        if note.star {
            starBUtton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            starBUtton.tintColor = .systemYellow
            starBUtton.setTitleColor(.label, for: .normal)
        }
        if note.user.fellow{
            fellowButton.tintColor = .secondaryLabel
            fellowButton.layer.borderColor = UIColor.secondaryLabel.cgColor
            fellowButton.setTitle("已关注", for: .normal)
        }
        likeButton.setTitle(note.likeNumber == 0 ? "点赞" : "\(note.likeNumber)", for: .normal)
        starBUtton.setTitle(note.starNumber == 0 ? "收藏" : "\(note.starNumber)", for: .normal)
        commenticonButton.setTitle(note.commentNumber == 0 ? "评论" : "\(note.commentNumber)", for: .normal)
        if let title = note.title{
            titleLabel.text = title
        }else{
            titleLabel.isHidden = true
        }
        
        if let content = note.content{
            contentLabel.text = content
        }else{
            contentLabel.isHidden = true
        }
        
        if let topic = note.topic{
            topicButton.setTitle(topic.name, for: .normal)
        }else{
            topicButton.isHidden = true
        }
        if note.createTime == note.updateTime{
            timeLabel.text = Date().formatDate(isoDate: note.createTime)
        }else{
            timeLabel.text = "编辑于 \(Date().formatDate(isoDate: note.updateTime))"
        }
        commentCountLabel.text = "\(note.commentNumber)"
    }
    
    func setUI(){
        fellowButton.layer.borderWidth = 1
        fellowButton.layer.borderColor = mainColor?.cgColor
        backeButton.setTitle("", for: .normal)
        shareButton.setTitle("", for: .normal)
        if appDelegate.user?.id == note.user.id{
            fellowButton.isHidden = true
        } else {
            shareButton.isHidden = true
            fellowButton.addTarget(self, action: #selector(fellow), for: .touchUpInside)
        }
    }
    
    func config(){
        Server.shared().noteAddView(noteId: note.id) { _ in
            print("added")
        }
        
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .systemGray6
        pageControl.currentPageIndicatorTintColor = mainColor
        photosShow.pageIndicator = pageControl
        
        let photoArr = self.photos.compactMap {KingfisherSource(urlString: $0.url)}
        
        photosShow.setImageInputs(photoArr)
        photosShow.backgroundColor = .white
        photosShow.currentSlideshowItem?.bounces = false
        
        photosShow.zoomEnabled = true
        photosShow.circular = false
        photosShow.contentScaleMode = .scaleAspectFit
        
        var imageRatio = note.ratio
        if imageRatio > 1.35 {
            imageRatio = 1.35
        }else if imageRatio < 2.0 / 3.0 {
            imageRatio = 2.0 / 3.0
        }
        let width = UIScreen.main.bounds.width
        let pheight = imageRatio * width
        imageHeight.constant = pheight
        
        commentTextView.textContainerInset = UIEdgeInsets(top: 11.5, left: 16, bottom: 11.5, right: 16)
        
        tableView.mj_footer = footer
        tableView.mj_footer?.setRefreshingTarget(self, refreshingAction:  #selector(loadMoreData))
    }
    
    @objc func loadMoreData(){
        if !isGotAllData{
            currentPage += 1
            getComments()
        }else{
            footer.endRefreshingWithNoMoreData()
        }
    }
    
    func getComments(){
        guard note.commentNumber != 0 else {footer.endRefreshingWithNoMoreData();return}
        
        Server.shared().fetchCommentsFromServer(noteId: note.id, page: currentPage) { [self] data in
            guard let comments = data else { self.showTextHUD(showView: self.view, "评论加载失败"); return}
            if comments.count == 0{
                isGotAllData = true
            }else{
                for comment in comments {
                    self.comments.append(comment)
                }
                if comments.count < eachPageCount{
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
    
    @objc func slide(pan: UIPanGestureRecognizer){
        let translationX = pan.translation(in: pan.view).x
        if translationX > 0 {
            let progress = translationX / (UIScreen.main.bounds.width)
            switch pan.state {
            case .began:
                    dismiss(animated: true)
                print("end")
            case .changed:
                Hero.shared.update(progress)
                    let position = CGPoint(x: translationX + self.view.center.x, y: pan.translation(in: pan.view).y + self.view.center.y)
                    Hero.shared.apply(modifiers: [.position(position)], to: self.view)
            default:
                    if progress > 0.5{
                        Hero.shared.finish()
                        
                    }else{
                        Hero.shared.cancel()
                    }
            }
        }
    }
    
    @objc func likeAction(){
        if note.liked{
            if note.user.id == appDelegate.user?.id{
                appDelegate.user?.likes -= 1
            }
            note.likeNumber -= 1
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            likeButton.tintColor = .label
            note.liked = false
        }else{
            if note.user.id == appDelegate.user?.id{
                appDelegate.user?.likes += 1
            }
            note.likeNumber += 1
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tintColor = .systemPink
            likeButton.setTitleColor(.label, for: .normal)
            note.liked = true
        }
        likeButton.setTitle(note.likeNumber <= 0 ? "点赞" : "\(note.likeNumber)", for: .normal)
        Server.shared().likeNote(noteId: note.id){ res in
            if let resoult = res{
                if resoult == "操作成功"{
                    if self.note.user.id == appDelegate.user?.id{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateuser), object: nil)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLikeSucceed), object: self.note)
                }
            }
        }
    }
    
    @objc func fellow(){
        if note.user.fellow{
            note.user.fans -= 1
            appDelegate.user?.fellowNumber -= 1
            fellowButton.tintColor = mainColor
            fellowButton.layer.borderColor = mainColor?.cgColor
            fellowButton.setTitle("关注", for: .normal)
            note.user.fellow = false
        }else{
            note.user.fans += 1
            appDelegate.user?.fellowNumber += 1
            fellowButton.tintColor = .secondaryLabel
            fellowButton.layer.borderColor = UIColor.secondaryLabel.cgColor
            fellowButton.setTitle("已关注", for: .normal)
            note.user.fellow = true
        }
        Server.shared().fellowUser(userId: note.user.id){ res in
            if let resoult = res{
                if resoult == "操作成功"{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateuser), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLikeSucceed), object: self.note)
                }
            }else{
                print("error")
            }
        }
    }
    
    @objc func starAction(){
        if note.star{
            note.starNumber -= 1
            starBUtton.setImage(UIImage(systemName: "star"), for: .normal)
            starBUtton.tintColor = .label
            note.star = false
        }else{
            note.starNumber += 1
            starBUtton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            starBUtton.tintColor = .systemYellow
            starBUtton.setTitleColor(.label, for: .normal)
            note.star = true
        }
        starBUtton.setTitle(note.starNumber <= 0 ? "收藏" : "\(note.starNumber)", for: .normal)
        Server.shared().starNote(noteId: note.id){ res in
            if let resoult = res{
                if resoult == "操作成功"{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLikeSucceed), object: self.note)
                }
            }
        }
    }
    
    @objc func shareAction(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "编辑笔记", style: .default){_ in
            self.editNote()
        }
        let delete = UIAlertAction(title: "删除笔记", style: .destructive){_ in
            self.deleteAction()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel){_ in
            
        }
        
        alert.addAction(edit)
        alert.addAction(delete)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    private func deleteAction(){
        let alert = UIAlertController(title: "确认删除吗", message: "该操作不可撤销", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel){_ in
            
        }
        let delete = UIAlertAction(title: "删除", style: .destructive){_ in
            Server.shared().deleteNote(noteId: self.note.id) { res in
                if let response = res {
                    if response == "操作成功"{
                        self.dismiss(animated: true)
                        NotificationCenter.default.post(name: NSNotification.Name(kDeleteNote), object: self.note.id)
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
    
    private func editNote(){
        
        var photos:[UIImage] = []
        for photo in note.photos{
            photos.append(ImageCache.default.retrieveImageInMemoryCache(forKey: photo.url) ?? imagePH)
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: kNoteEditingVC) as! NoteEditingVC
//        vc.modalPresentationStyle = .fullScreen
        vc.note = self.note
        vc.photos = photos
        vc.saveNoteOptions = {
            self.showTextHUD(showView: self.view, "笔记保存成功")
        }
        vc.publishNoteOptions = {
            self.showTextHUD(showView: self.view, "笔记发布成功")
        }
        present(vc, animated: true)
    }
    
    @objc func keyboardWillChangeFrame(_ noti:Notification){
        if let frame = (noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            let keyboardHeight = screenRect.height - frame.origin.y
            
            if keyboardHeight > 0{
                view.insertSubview(overlayView, belowSubview: commentBarView)
            }else{
                overlayView.removeFromSuperview()
                commentBarView.isHidden = true
                commentTextView.text = ""
            }
            
            commentBarBottom.constant = keyboardHeight
            view.layoutIfNeeded()
        }
    }
    
    @objc func commentButtonActions(){
        postComment.replyId = -1
        postComment.superCommentId = -1
        commentTextView.placeholder = "输入您的评论"
        commentBarAppear()
    }
    
    func commentBarAppear(){
        commentTextView.becomeFirstResponder()
        commentBarView.isHidden = false
    }
    
    @objc func sendCommentAction(){
        if commentTextView.text.isEmpty {
            showTextHUD(showView: view, "评论为空")
            return
        }
        showLoadHUD()
        postComment.content = commentTextView.text
        
        Server.shared().postCommentToServer(data: postComment) { [self]res in
            hideHUD()
            guard let resoult = res else { self.showTextHUD(showView: self.view, "发送失败"); return}
            if postComment.superCommentId == -1 {
                comments.insert( Comment(id: resoult, content: commentTextView.text, createTime:"刚刚", user: appDelegate.user!), at: 0)
                tableView.performBatchUpdates {
                    tableView.insertSections(IndexSet(integer: 0), with: .automatic)
                }
                
            }else{
                for i in 0 ..< comments.count{
                    if comments[i].id == postComment.superCommentId{
                        if comments[i].replies == nil {
                            comments[i].replies = []
                        }
                        comments[i].replies?.append(Comment(id: resoult, content: commentTextView.text, createTime:"刚刚", user: appDelegate.user!, replyId: postComment.replyId))
                        if comments[i].showAllreplies == true || comments[i].replies!.count == 1{
                            tableView.performBatchUpdates {
                                tableView.insertRows(at: [IndexPath(row: comments[i].replies!.count - 1, section: i)], with: .automatic)
                            }
                        }else{
                            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: i)) as! CommentReplyCell
                            let count = comments[i].replies!.count - 1
                            cell.showMoreButton.isHidden = false
                            cell.showMoreButton.setTitle("展开\(count)条回复", for: .normal)
                            tableView.reloadRows(at: [IndexPath(row: 0, section: i)], with: .automatic)
                        }
                        
                    }
                }
            }
            updateComment()
//            tableView.reloadData()
            dismissKeyboard()
        }
        
    }
    
    @objc func goTopicDetail(){
        let vc = TopicDetailVC()
        vc.topic = note.topic
        vc.modalPresentationStyle = .fullScreen
        vc.hero.isEnabled = true
        vc.hero.modalAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .pull(direction: .right))
        present(vc, animated: true)
    }
    
    @objc func goMine(){
        let vc = storyboard!.instantiateViewController(withIdentifier: kMeVCID) as! MeVC
        vc.user = note.user
        vc.isNoteUser = true
        vc.isTabIten = false
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.hero.isEnabled = true
        nav.hero.modalAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .pull(direction: .right))
        present(nav, animated: true)
    }
    
    @objc func goUserMine(){
        let vc = storyboard!.instantiateViewController(withIdentifier: kMeVCID) as! MeVC
        vc.isTabIten = false
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.hero.isEnabled = true
        nav.hero.modalAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .pull(direction: .right))
        present(nav, animated: true)
    }
    
    @objc func commentToMine(noti:NSNotification){
        guard let user = noti.object as? User else {return}
        let vc = storyboard!.instantiateViewController(withIdentifier: kMeVCID) as! MeVC
        vc.user = user
        vc.isNoteUser = user.id == note.user.id
        vc.isTabIten = false
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.hero.isEnabled = true
        nav.hero.modalAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .pull(direction: .right))
        present(nav, animated: true)
    }
  
    func updateComment(){
        var count = 0
        for commment in comments{
            count += 1
            count += commment.replies?.count ?? 0
        }
        note.commentNumber = count
        commenticonButton.setTitle("\(note.commentNumber)", for: .normal)
        commentCountLabel.text = "\(note.commentNumber)"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLikeSucceed), object: self.note)
    }
}

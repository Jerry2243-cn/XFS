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

class NoteDetailVC: UIViewController {

    var note:Note
    var noteDetalHeroID:String?
    var photos:[Photo]
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
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var commontButton: BigButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var starBUtton: UIButton!
    @IBOutlet weak var commenticonButton: UIButton!
    
    @IBOutlet weak var photosShow: ImageSlideshow!
    
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    init?(coder: NSCoder, note:Note) {
        self.note = note
        photos = note.photos.sorted(by: { p1, p2 in
            p1.orderNumber < p2.orderNumber
        })
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
      
        view.hero.id = noteDetalHeroID
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(slide(pan:)))
//        view.addGestureRecognizer(pan)
        setUI()
        config()
        
       
        let photoArr = self.photos.compactMap {KingfisherSource(urlString: $0.url)}
        
        photosShow.setImageInputs(photoArr)
        photosShow.backgroundColor = .white
        photosShow.currentSlideshowItem?.bounces = false
       
        var imageRatio = note.ratio
        if imageRatio > 1.35 {
            imageRatio = 1.35
        }else if imageRatio < 2.0 / 3.0 {
            imageRatio = 2.0 / 3.0
        }
        let width = UIScreen.main.bounds.width
        let pheight = imageRatio * width
        imageHeight.constant = pheight
        
       setData()
        if appDelegate.user?.id == note.user.id{
            fellowButton.isHidden = true
        } else {
            shareButton.isHidden = true
            fellowButton.addTarget(self, action: #selector(fellow), for: .touchUpInside)
        }
        likeButton.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
        starBUtton.addTarget(self, action: #selector(starAction), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
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
    }
    
    func config(){
        
        photosShow.zoomEnabled = true
        photosShow.circular = false
        photosShow.contentScaleMode = .scaleAspectFit
        
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .systemGray6
        pageControl.currentPageIndicatorTintColor = mainColor
        photosShow.pageIndicator = pageControl
        
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
}

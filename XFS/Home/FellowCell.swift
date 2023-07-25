//
//  FellowCell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/3.
//

import UIKit
import ImageSlideshow

class FellowCell: UICollectionViewCell {
    
    var note:Note?{
        didSet{
            guard let note = self.note else {return}
            var labelContent = ""
            if let title = note.title{
                labelContent = labelContent + title
            }
            if let content = note.content{
                labelContent = labelContent + content
            }
            if labelContent != ""{
                contentStack.isHidden = false
                titleAndContentLabel.text = labelContent
            }else{
                contentStack.isHidden = true
            }
            nicknameLable.text = note.user.nickname
            if let url = note.user.avatar{
                let avatarURL = URL(string: url)
                avatarImageView.kf.setImage(with: avatarURL)
            }else{
                avatarImageView.image = defaultAvatar
            }
            if note.createTime == note.updateTime{
                notePublishTime.text = Date().formatDate(isoDate: note.createTime)
            }else{
                notePublishTime.text = "编辑于 \(Date().formatDate(isoDate: note.updateTime))"
            }
            
            let photoArr = note.photos.compactMap {KingfisherSource(urlString: $0.url)}

            photosShow.setImageInputs(photoArr)
            photosShow.backgroundColor = .white
            photosShow.currentSlideshowItem?.bounces = false
            
            if note.liked {
                likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                likeButton.tintColor = .systemPink
                likeButton.setTitleColor(.label, for: .normal)
            }else{
                likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                likeButton.tintColor = .label
                likeButton.setTitleColor(.label, for: .normal)
            }
            if note.star {
                favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                favouriteButton.tintColor = .systemYellow
                favouriteButton.setTitleColor(.label, for: .normal)
            }else{
                favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
                favouriteButton.tintColor = .label
                favouriteButton.setTitleColor(.label, for: .normal)
            }
            likeButton.setTitle(note.likeNumber == 0 ? "点赞" : "\(note.likeNumber)", for: .normal)
            favouriteButton.setTitle(note.starNumber == 0 ? "收藏" : "\(note.starNumber)", for: .normal)
            commentButton.setTitle(note.commentNumber == 0 ? "评论" : "\(note.commentNumber)", for: .normal)
        }
    }
    
    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var topInfoStack: UIStackView!
    @IBOutlet weak var bottomInfoStack: UIStackView!
    @IBOutlet weak var shareButtonTop: UIButton!
    @IBOutlet weak var showCOntentButton: UIButton!
    @IBOutlet weak var titleAndContentLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var notePublishTime: UILabel!

    @IBOutlet weak var photosShow: ImageSlideshow!
    @IBOutlet weak var nicknameLable: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentStack.isHidden = true
        shareButton.text("")
        shareButtonTop.text("")
        config()
        likeButton.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
        favouriteButton.addTarget(self, action: #selector(starAction), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(showDetail), for: .touchUpInside)
        showCOntentButton.addTarget(self, action: #selector(showDetail), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickAction))
        avatarImageView.addGestureRecognizer(tap)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(clickAction))
        nicknameLable.addGestureRecognizer(tap1)
    }
    
    @objc func clickAction(){
        NotificationCenter.default.post(name: NSNotification.Name(kGotoMine), object: note?.user)
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
    
    @objc func showDetail(){
        let detaiNoteVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: kNoteDetailVCID) { coder in
            NoteDetailVC(coder: coder, note: self.note!)
        }
        detaiNoteVC.modalPresentationStyle = .fullScreen
        detaiNoteVC.hero.isEnabled = false
        NotificationCenter.default.post(name: NSNotification.Name(kShowNoteDetail), object: detaiNoteVC)
    }
    
    @objc func starAction(){
        guard var note = self.note else {return}
        if note.star{
            note.starNumber -= 1
            favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            favouriteButton.tintColor = .label
            note.star = false
        }else{
            note.starNumber += 1
            favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            favouriteButton.tintColor = .systemYellow
            favouriteButton.setTitleColor(.label, for: .normal)
            note.star = true
        }
        favouriteButton.setTitle(note.starNumber <= 0 ? "收藏" : "\(note.starNumber)", for: .normal)
        Server.shared().starNote(noteId: note.id){ res in
            if let resoult = res{
                if resoult == "操作成功"{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLikeSucceed), object: note)
                }
            }
        }
    }
    
    @objc func likeAction(){
        guard var note = self.note else {return}
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
                    if note.user.id == appDelegate.user?.id{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateuser), object: nil)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLikeSucceed), object: note)
                }
            }
        }
    }
}

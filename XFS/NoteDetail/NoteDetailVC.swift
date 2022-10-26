//
//  NoteDetailVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/19.
//

import UIKit
import ImageSlideshow
import Alamofire

class NoteDetailVC: UIViewController {

    var coverImage = UIImage(named: "1")!
    
    @IBOutlet weak var backeButton: UIButton!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nicknameButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var fellowButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var photosShow: ImageSlideshow!
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        config()
        photosShow.setImageInputs([
            ImageSource(image: coverImage),
            ImageSource(image: UIImage(named: "2")!),
            ImageSource(image: UIImage(named: "3")!)
        ])

        let size = coverImage.size
        let h = size.height
        let w = size.width
        let width = UIScreen.main.bounds.width
        let pheight = (h / w) * width
        imageHeight.constant = pheight
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = headerView.frame
        
        if frame.height != height{
            frame.size.height = height
            headerView.frame = frame
        }
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
    

}

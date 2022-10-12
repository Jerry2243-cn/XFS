//
//  NoteEditingVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/5.
//

import UIKit
import YPImagePicker
import SKPhotoBrowser
import AMapLocationKit

class NoteEditingVC: UIViewController, AMapLocationManagerDelegate, AMapSearchDelegate{
    
    var photos: [UIImage] = [
        UIImage(named: "1")!, UIImage(named: "2")!
    ]
    
    //计算属性
    var photosCount: Int{
        photos.count
    }
    var textViewAView: TextViewAView {
        contentTextView.inputAccessoryView as! TextViewAView
    }
    //坐标及POI信息
    lazy var latitude = 0.0
    lazy var longtitude = 0.0
    lazy var locations: [String] = []
    
    //询问地图权限
    let locationManagerM = CLLocationManager()
    
    //高德地图SDK相关引用
    let locationManager = AMapLocationManager()
    lazy var mapSearch = AMapSearchAPI()
    lazy var aroundSearchRequest: AMapPOIAroundSearchRequest = {
        let request = AMapPOIAroundSearchRequest()
        request.types = kPOITypes
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(latitude), longitude: CGFloat(longtitude))
        return request
    }()
    
    //布局相关outlet
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleCountLable: UILabel!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var topicImage: UIImageView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var topicTipLabel: UILabel!
    
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationTagsCollectionView: UICollectionView!

    //title及addLocationTag相关action
    @IBAction func titleTFBegin(_ sender: UITextField) {
        titleCountLable.isHidden = false
    }
    @IBAction func titleTFEnd(_ sender: UITextField) {
        titleCountLable.isHidden = true
    }
    @IBAction func titleTFChanged(_ sender: UITextField) {
        if sender.markedTextRange == nil {
            let remainWords = kMaxTitleCount - (sender.text?.count ?? 0)
            titleCountLable.text = "\(remainWords)"
            if remainWords < 0{
                let text = sender.text!
                let indexStart = text.startIndex
                let index = text.index(indexStart, offsetBy: kMaxTitleCount)
                let fixed = String(text[indexStart..<index])
                titleTextField.text = fixed
                titleCountLable.text = "0"
                showTextHUD(showView: view, "标题字数不能超过\(kMaxTitleCount)")
            }
        }
        
    }
    @IBAction func addLocation(_ sender: UIButton) {
        locationImage.tintColor = .link
        locationLabel.text = sender.titleLabel?.text
        locationLabel.textColor = .link
        locationTagsCollectionView.isHidden = true
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //定位相关
        locationConfig()
        mapSearch?.delegate = self
        locationTagsCollectionView.isHidden = true
        locationManagerM.requestWhenInUseAuthorization()
        
        //图片拖拽手势开启
        photoCollectionView.dragInteractionEnabled = true
        
        //标题label初始化
        titleCountLable.isHidden = true
        titleCountLable.text = "\(kMaxTitleCount)"
        hideKeyboardWhenTappedAround()
        
        //content相关配置
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let typingAttributes:[NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.secondaryLabel
        ]
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: -contentTextView.textContainer.lineFragmentPadding, bottom: 0, right: -contentTextView.textContainer.lineFragmentPadding)
        contentTextView.typingAttributes = typingAttributes
        contentTextView.tintColorDidChange()
        contentTextView.inputAccessoryView = Bundle.loadView(fromNIb: "TextViewAView", with: TextViewAView.self)
        textViewAView.OKButton.addTarget(self, action: #selector(resignTextView), for: .touchUpInside)
        textViewAView.textCountStack.isHidden = true
        
        
    }
    
    //高德地图相关配置
    func locationConfig(){
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        locationManager.locationTimeout = 5

        locationManager.reGeocodeTimeout = 5
        
        locationManager.requestLocation(withReGeocode: true, completionBlock: { [weak self] (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
                    
            if let error = error {
                let error = error as NSError
                
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
                    print("定位错误:{\(error.code) - \(error.localizedDescription)};")
                    return
                }
                else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                    || error.code == AMapLocationErrorCode.timeOut.rawValue
                    || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                    || error.code == AMapLocationErrorCode.badURL.rawValue
                    || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                    || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    
                    //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
                    print("逆地理错误:{\(error.code) - \(error.localizedDescription)};")
                }
                else {
                    //没有错误：location有返回值，regeocode是否有返回值取决于是否进行逆地理操作，进行annotation的添加
                }
            }
            
            guard let self = self else {return}
            
            if let location = location {
                self.latitude = location.coordinate.latitude
                self.longtitude = location.coordinate.longitude
                
                //搜索周边POI
                self.mapSearch?.aMapPOIAroundSearch(self.aroundSearchRequest)
                self.locationTagsCollectionView.reloadData()
            }
            
        })
    }
    
    //高德地图数据回调处理
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.count == 0 {
            return
        }
        locationTagsCollectionView.isHidden = false
        for poi in response.pois{
            self.locations.append(poi.name!)
        }
        locationTagsCollectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TopicSelectVC{
            vc.PVDelegate = self
        }
        if let vc = segue.destination as? POIVC{
            vc.POIDelegate = self
        }
    }

}

//反向传值获取定位信息处理
extension NoteEditingVC: POIViewControllerDelegate{
    
    func updateLocation(title: String, address: String) {
        let nolocation = title == "不显示位置"
        locationImage.tintColor = nolocation ? .secondaryLabel : .link
        locationLabel.text = nolocation ? "添加地点" : title
        locationLabel.textColor = nolocation ? .secondaryLabel : .link
        locationTagsCollectionView.isHidden = !nolocation
    }
    
    
}

//反向传值，将topictable中的值传入noteedidting
extension NoteEditingVC: TopicSelectViewControllerDelegate{
    func updateTopic(channel: String, topic: String) {
        topicTipLabel.isHidden = true
        topicLabel.text = topic
        topicLabel.textColor = .link
        topicImage.tintColor = .link
    }
}

//ContentTextView文字统计与完成按钮显示
extension NoteEditingVC: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.markedTextRange == nil {
            let count = textView.text?.count ?? 0
            textViewAView.textCountLabel.text = "\(count)"
            
            textViewAView.textCountStack.isHidden = count <= 1000
            textViewAView.OKButton.isHidden = count > 1000
            
        }
    }
    
}

//键盘上完成按钮舰艇
extension NoteEditingVC {
    @objc private func resignTextView(){
        contentTextView.resignFirstResponder()
    }
}

//图片预览
extension NoteEditingVC: UICollectionViewDelegate, SKPhotoBrowserDelegate{
    
    //图片预览
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 1. create SKPhoto Array from UIImage
        var images: [SKPhoto] = []
        for photo in photos{
            images.append(SKPhoto.photoWithImage(photo))
        }
        
        // 2. create PhotoBrowser Instance, and present from your viewController.
        let browser = SKPhotoBrowser(photos: images, initialPageIndex: indexPath.item)
        browser.delegate = self
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.displayDeleteButton = true
        present(browser, animated: true)
    }
    
    //预览界面的删除按钮
    func removePhoto(_ browser: SKPhotoBrowser, index: Int, reload: @escaping (() -> Void)) {
        
        if self.photosCount == 1 {
            self.showTextHUD(showView: browser.view, "至少发布1张照片")
        }else{
            let alert = UIAlertController(title: "确认删除？", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .cancel)
            let confirm = UIAlertAction(title: "删除", style: .destructive){ action in
                self.photos.remove(at: index)
                self.photoCollectionView.reloadData()
                reload()
            }
            alert.addAction(cancel)
            alert.addAction(confirm)
            browser.present(alert, animated: true, completion: nil)
        }
        
    }
}

//Collection数据初始化
extension NoteEditingVC: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photoCollectionView{
            return photosCount
        }
        if collectionView == locationTagsCollectionView{
            return locations.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == photoCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPhotoCellID, for: indexPath) as! PhotoCell
            cell.imageView.image = photos[indexPath.item]
            return cell
        }
        if collectionView == locationTagsCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kLocationTagCellID, for: indexPath) as! LocationTagCell
            cell.locationTagButton.setTitle(locations[indexPath.item], for: .normal)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kPhotoFooterID, for: indexPath) as! PhotoFooter
            footer.addPhotoButton.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
            return footer
            default:
                fatalError("collectionview的footer出问题")
        }
        
    }
    
    
}

//添加图片
extension NoteEditingVC{
    
    //监听添加照片按钮
    @objc private func addPhoto(sender: UIButton){
        if photosCount < kMaxPhotoCount{
            var config = YPImagePickerConfiguration()
            config.albumName = "小粉书"
            config.screens = [.library]
            
            config.library.defaultMultipleSelection = true
            config.library.maxNumberOfItems = kMaxPhotoCount - photosCount
            config.library.spacingBetweenItems = 1.5
            config.library.preSelectItemOnMultipleSelection = false
            
            let picker = YPImagePicker(configuration: config)
            
            picker.didFinishPicking { [unowned picker] items, _ in
               
                for item in items{
                    if case let .photo(photo) = item{
                        self.photos.append(photo.image)
                    }
                }
                self.photoCollectionView.reloadData()
                
                picker.dismiss(animated: true)
            }
            present(picker, animated: true)
            
        }else{
            self.showTextHUD(showView: view, "最多只能选择\(kMaxPhotoCount)张照片")
        }
    }
}

//图片拖拽
extension NoteEditingVC: UICollectionViewDragDelegate, UICollectionViewDropDelegate{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let photo = photos[indexPath.item]
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: photos[indexPath.item]))
        dragItem.localObject = photo
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag{
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        if coordinator.proposal.operation == .move,
           let item = coordinator.items.first,
           let sourceIndexPath = item.sourceIndexPath,
           let destinationIndexPath = coordinator.destinationIndexPath{
           
            collectionView.performBatchUpdates {
                photos.remove(at: sourceIndexPath.item)
                photos.insert(item.dragItem.localObject as! UIImage, at: destinationIndexPath.item)
                collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
            }
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
    
    
}

//标题TextField
extension NoteEditingVC: UITextFieldDelegate{
    
    //标题TF键盘完成消失
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

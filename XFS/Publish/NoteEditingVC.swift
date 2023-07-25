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
import Alamofire


class NoteEditingVC: UIViewController, AMapLocationManagerDelegate, AMapSearchDelegate{
    
    var note:Note?
    
    var photos: [UIImage] = [
        UIImage(named: "1")!, UIImage(named: "2")!
    ]
    
    var saveNoteOptions: (()->())?
    var publishNoteOptions: (()->())?
    var draftNote: DraftNote?

    var channel = ""
    var topic = ""
    
    //计算属性
    var photosCount: Int{
        photos.count
    }
    var textViewAView: TextViewAView {
        contentTextView.inputAccessoryView as! TextViewAView
    }
    
    // MARK: 坐标及POI信息
    lazy var myPOI = appDelegate.myPOI
    var selectedPOI:POI?
    lazy var locations: [POI] = []
    //询问地图权限
//    let locationManagerM = CLLocationManager()
    
    //MARK: 高德地图SDK相关引用
    let locationManager = AMapLocationManager()
    lazy var mapSearch = AMapSearchAPI()
    lazy var aroundSearchRequest: AMapPOIAroundSearchRequest = {
        let request = AMapPOIAroundSearchRequest()
        request.types = kPOITypes
        if let poi = self.myPOI{
            request.location = AMapGeoPoint.location(withLatitude: CGFloat(poi.latitude), longitude: CGFloat(poi.longitude))
        }
        return request
    }()
    
    //MARK: 布局相关outlet
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleCountLable: UILabel!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var topicImage: UIImageView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var claerTopicButton: UIButton!
    @IBOutlet weak var topicTipLabel: UILabel!
    
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationTagsCollectionView: UICollectionView!

    //MARK: title及addLocationTag相关action
    @IBAction func titleTFBegin(_ sender: UITextField) {
        titleCountLable.isHidden = false
        let remainWords = kMaxTitleCount - (sender.text?.count ?? 0)
        titleCountLable.text = "\(remainWords)"
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
    @IBAction func claerTopicAction(_ sender: Any) {
        topic = ""
        topicImage.tintColor = .secondaryLabel
        topicLabel.text = "参与话题"
        topicLabel.textColor = .secondaryLabel
        claerTopicButton.isHidden = true
    }
    
    //MARK: 发布与草稿按钮Action
    @IBAction func publishButton(_ sender: Any) {
        showLoadHUD()
        postNote(){ res in
            if res == "笔记上传成功"{
                if let _ = self.draftNote{
                    self.navigationController?.popViewController(animated: true)
                }else{
                    self.dismiss(animated: true)
                }
                self.publishNoteOptions?()
            }else{
                self.showTextHUD(showView: self.view, "上传失败")
            }
        }
        
    }
    
    @IBAction func saveButton(_ sender: Any) {
        guard contentTextView.text.count <= kMaxContentCount else {
            showTextHUD(showView: (parent?.view)!, "正文内容不得超过1000字")
            return
        }
       
        let draftNote = self.draftNote ?? DraftNote(context: context)
        
        draftNote.coverPhoto = photos[0].getJpeg(.medium)
        var photos: [Data] = []
        
        for photo in self.photos {
            if let pngData = photo.pngData(){
                photos.append(pngData)
            }
        }
        if let note = self.note{
            draftNote.id = Int16(note.id)
        }else{
            draftNote.id = -1
        }
        draftNote.photos = try? JSONEncoder().encode(photos)
        draftNote.title = titleTextField.text
        draftNote.content = contentTextView.text
        draftNote.poiName = selectedPOI?.name
        draftNote.poiAddress = selectedPOI?.address
        draftNote.latitude = selectedPOI?.latitude ?? 0
        draftNote.longtitude = selectedPOI?.longitude ?? 0
        draftNote.channel = channel
        draftNote.topic = topic
        draftNote.updatedAt = Date()
        appDelegate.saveContext()
        UserDefaults.increase(userDefaultsDraftNotesCount)
        NotificationCenter.default.post(name: NSNotification.Name(khaveDraftNote), object: nil)
        if let _ = self.draftNote{
            navigationController?.popViewController(animated: true)
        }else{
            dismiss(animated: true)
        }
        saveNoteOptions?()
    }
    
//    @objc func toppicDidUpdate(noti: Notification) {
//        print(noti.object)
//    }
//
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(toppicDidUpdate(noti:)), name: .init("updateTopic"), object: nil)
        loadDraftNoteData()
        loadEditNote()
        //定位相关
        locationConfig()
        mapSearch?.delegate = self
        locationTagsCollectionView.isHidden = selectedPOI != nil
//        locationManagerM.requestWhenInUseAuthorization()
        //图片拖拽手势开启
        photoCollectionView.dragInteractionEnabled = true
        
        //标题label初始化
        titleCountLable.isHidden = true
        titleCountLable.text = "\(kMaxTitleCount)"
        hideKeyboardWhenTappedAround()
        
        claerTopicButton.isHidden = true
        
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
    
    func postNote(completion:@escaping(String)->()){
        FileHelper.uploadImages(images: photos){photos in
            hideHUD()
            guard let uploadedPhotos = photos else {
                showTextHUD(showView: self.view, "发布失败，请重试")
                return
            }
            let postData = PostNote(
                id: note?.id ?? -1,
                title : titleTextField.text ?? "",
                content : contentTextView.text ?? "",
                coverPhoto: uploadedPhotos[0].url,
                photos: uploadedPhotos,
                poi : selectedPOI,
                topic: topic,
                ratio: self.photos[0].size.height / self.photos[0].size.width,
                likeNumber: note?.likeNumber ?? 0,
                starNumber: note?.starNumber ?? 0,
                commentNumber: note?.commentNumber ?? 0
            )
            
            Server.shared().postNoteToServer(data: postData){ res in
                if let resoult = res{
                    if resoult == "success"{
                        completion("笔记上传成功")
                        return
                    }
                }
                completion("上传失败")
            }
        }
    }
    
    func loadDraftNoteData(){
        guard let note = draftNote else { return }
            titleTextField.text = note.title
            contentTextView.text = note.content
            if note.topic != ""{
                updateTopic(channel: note.channel!, topic: note.topic!)
            }
        if note.poiName != "" && note.poiName != nil{
                let poi = POI(name: note.poiName!,address: note.poiAddress ?? "",latitude: note.latitude, longitude: note.longtitude)
                updateLocation(poi: poi)
            }
    }
    
    func loadEditNote(){
        guard let note = self.note else { return }
        titleTextField.text = note.title
        contentTextView.text = note.content
        if let topic = note.topic {
            updateTopic(topic: topic.name)
        }
        if let poi = note.poi{
            updateLocation(poi: poi)
        }
    }
    
    //MARK: 高德地图相关配置及获取坐标
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
//
//            if let location = location {
//                self.myPOI.latitude = location.coordinate.latitude
//                self.myPOI.longitude = location.coordinate.longitude
//                //搜索周边POI
                self.mapSearch?.aMapPOIAroundSearch(self.aroundSearchRequest)
                self.locationTagsCollectionView.reloadData()
//            }
            
//            if let reGeocode = reGeocode{
//                self.city = reGeocode.city
//            }
//
        })
    }
    
    //MARK: 高德地图数据回调处理
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.count == 0 {
            return
        }

        for poi in response.pois{
            
            let province = poi.province.description == poi.city.description ? "" : poi.province
            let address = poi.address.description == poi.district ? "" : poi.address
            let fixedAddress = "\(province!)\(poi.city!)\(poi.district!)\(address!)"
            
            self.locations.append(POI(id : poi.uid,
                                      name: poi.name,
                                      address: fixedAddress,
                                      city: poi.city,
                                      latitude: poi.location.latitude,
                                      longitude: poi.location.longitude))
        }
        locationTagsCollectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TopicSelectVC{
            view.endEditing(true)
            vc.PVDelegate = self
        }
        if let vc = segue.destination as? POIVC{
            vc.POIDelegate = self
            vc.selectedPOI = selectedPOI
        }
    }

}

//MARK: 反向传值获取定位信息处理
extension NoteEditingVC: POIViewControllerDelegate{
    
    func updateLocation(poi:POI) {
        
        let nolocation = poi.name == "不显示位置" || poi.name == ""
        
        selectedPOI = nolocation ? nil : poi
        locationImage.tintColor = nolocation ? .secondaryLabel : .link
        locationLabel.text = nolocation ? "添加地点" : selectedPOI?.name
        locationLabel.textColor = nolocation ? .secondaryLabel : .link
        locationTagsCollectionView.isHidden = locations.isEmpty ? true : !nolocation
        
    }
    
    
}

//MARK: 反向传值，将topictable中的值传入noteedidting
extension NoteEditingVC: TopicSelectViewControllerDelegate{
    func updateTopic(channel: String = "", topic: String) {
        let noTopic = topic == ""
        self.channel = channel
        self.topic = topic
        topicTipLabel.isHidden = true
        topicLabel.text = noTopic ? "参与话题" : topic
        topicLabel.textColor = noTopic ? .secondaryLabel : .link
        topicImage.tintColor = noTopic ? .secondaryLabel : .link
        claerTopicButton.isHidden = noTopic
    }
}

//MARK: ContentTextView文字统计与完成按钮显示
extension NoteEditingVC: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.markedTextRange == nil {
            let count = textView.text?.count ?? 0
            textViewAView.textCountLabel.text = "\(count)"
            
            textViewAView.textCountStack.isHidden = count <= kMaxContentCount
            textViewAView.OKButton.isHidden = count > kMaxContentCount
            
        }
    }
    
}

//MARK: 键盘上完成按钮舰艇
extension NoteEditingVC {
    @objc private func resignTextView(){
        contentTextView.resignFirstResponder()
    }
}


extension NoteEditingVC: UICollectionViewDelegate, SKPhotoBrowserDelegate{
    
    //MARK: 图片cell和POITag cell的选中处理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == locationTagsCollectionView{
            let cell = collectionView.cellForItem(at: indexPath) as! LocationTagCell
            selectedPOI = cell.poi!
            locationImage.tintColor = .link
            locationLabel.text = selectedPOI?.name
            locationLabel.textColor = .link
            locationTagsCollectionView.isHidden = true
        }
        
        if collectionView == photoCollectionView{
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
        
    }
    
    //MARK: 预览界面的删除按钮
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

//MARK: Collection数据初始化
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
            cell.poi = locations[indexPath.item]
//            cell.titleLabel.text = locations[indexPath.item].name
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

extension NoteEditingVC{
    
    //MARK: 监听添加照片按钮
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

//MARK: 图片拖拽
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

//MARK: 标题TextField
extension NoteEditingVC: UITextFieldDelegate{
    
    //标题TF键盘完成消失
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

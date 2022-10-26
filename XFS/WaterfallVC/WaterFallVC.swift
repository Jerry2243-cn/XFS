//
//  WaterFallVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/2.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import XLPagerTabStrip
import CoreData
import MJRefresh
import SegementSlide

class WaterFallVC: UICollectionViewController, SegementSlideContentScrollViewDelegate{
    
    @objc var scrollView: UIScrollView {
            return collectionView
        }
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    var popOpt: (()->())?
    
    lazy var myPOI = POI()
    var channel = ""
    var cellType: WaterfallCellType = .draftNote
    
    var dataList:[Any] = []
    var currentPage = 1
    var isGotAllData = false
    
    let testTitle = ["环可能看见你哭你健康你就",
                     "环可能看见你哭你健",
                     "sjsfjvisfjvoisfjisfvjfsi",
                     "sdsjjvkfvks",
                     "北京北京北京看北京北京北京看病就加不加班",
                     "",
                     "环可能看见你哭你健康你就",
                     "环可能看见你哭你健",
                     "sjsfjvisfjvoisfjisfvjfsi",
                     "北京北京北京看北京北京北京看病就加不加班",
                     "zxc",
                     "",
                     "s的陈年旧事"]
    
    lazy var footer = MJRefreshAutoNormalFooter()
    lazy var header = MJRefreshNormalHeader()
   
    override func viewDidLoad() {
        super.viewDidLoad()

        config()
        getData()
        
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //cell数量
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        switch cellType{
        case .discover:
            return 13
        case .draftNote:
            return dataList.count
        case .nearby:
            return 13
        }
    }
    
    //渲染cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cellType{
        case .discover:
            return loadDiscoverNoteCell(collectionView, indexPath)
        case .draftNote:
            return loadDraftNoteCell(collectionView, indexPath)
        case .nearby:
            return loadNearbyNoteCell(collectionView, indexPath)
        }
        
    }
    
    //cell点击事件
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch cellType{
        case .discover:
            discoverNoteCellTap(collectionView, indexPath)
        case .draftNote:
            draftNoteCellTap(collectionView, indexPath)
        case .nearby:
            nearbyNoteCellTap(collectionView, indexPath)
        }
    }

}

extension WaterFallVC: CHTCollectionViewDelegateWaterfallLayout{
    //定义cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size: CGSize
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kWaterFallCellID, for: indexPath) as! WaterFallwCell
        var lines = 1
        switch cellType{
        case .draftNote:
            let note = dataList[indexPath.item] as? DraftNote
            size = UIImage(note?.coverPhoto)!.size
            lines = cell.titleLabel.textToThisLabelLines(text: note?.title ?? "")
        default:
            size = UIImage(named: "\(indexPath.item + 1)")!.size
            lines = cell.titleLabel.textToThisLabelLines(text: testTitle[indexPath.item])
        }
        
        let cellW = (UIScreen.main.bounds.width - kWaterFallpadding * 3) / 2
        let h = size.height
        let w = size.width
        var imageRato = h / w
        if imageRato > 1.35 {
            imageRato = 1.35
        }else if imageRato < 2.0 / 3.0 {
            imageRato = 2.0 / 3.0
        }
        var cellH = cellW * imageRato + cell.infoStack.bounds.height + 20
        
//        if lines == 0{
            cellH -= lines == 0 ? cell.infoStack.spacing + 16.333333 : 0
//            cellH -= cell.titleLabel.bounds.height - 0.5
//            cellH -= 16.333333
//        }else if lines == 2{
//            cellH += cell.titleLabel.bounds.height
            cellH += lines == 2 ? 17 :0
//        }
        
        return CGSize(width: cellW, height: cellH )
    }
}

extension WaterFallVC{
    
    func config(){
        //collectionView配置
        let layout = collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
        layout.columnCount = 2
        layout.minimumColumnSpacing = kWaterFallpadding
        layout.minimumInteritemSpacing = kWaterFallpadding
        layout.sectionInset = UIEdgeInsets(top: kWaterFallpadding   , left: kWaterFallpadding, bottom: kWaterFallpadding, right: kWaterFallpadding)
        collectionView.backgroundColor = .secondarySystemBackground
        
        //加载首尾拉取加载
        collectionView.mj_footer = footer
        if cellType != .draftNote{
            collectionView.mj_header = header
        }
        collectionView.mj_header?.setRefreshingTarget(self, refreshingAction:  #selector(refreshData))
        collectionView.mj_footer?.setRefreshingTarget(self, refreshingAction:  #selector(loadMoreData))
        
        if cellType == .draftNote{
            navigationItem.title = "本地草稿"
            
            navigationItem.backButtonDisplayMode = .minimal
        }
    }
}

extension WaterFallVC: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        IndicatorInfo(title: channel)
    }
}

//数据加载controller处理
extension WaterFallVC{
    
    @objc func refreshData(){
        currentPage = 1
        isGotAllData = false
        dataList = []
        getData()
        collectionView.mj_footer?.resetNoMoreData()
        collectionView.mj_header?.endRefreshing()

    }
    
    @objc func loadMoreData(){
        if !isGotAllData{
            currentPage += 1
            getData()
        }else{
            footer.endRefreshingWithNoMoreData()
        }
    }
    
    func getData(){
        switch cellType{
        case .discover:
            loadDiscoverNotes()
        case .draftNote:
            loadDraftNotes(page: currentPage)
        case.nearby:
            loadNerbyNotes()
        }
    }
}


extension WaterFallVC{
    
    //获取草稿笔记
    func loadDraftNotes(page:Int){
        let request = DraftNote.fetchRequest() as NSFetchRequest<DraftNote>
        request.fetchLimit = 8
        request.fetchOffset = (page - 1) * 8
        request.propertiesToFetch = ["coverPhoto","updatedAt","title"]
        let draftNotes = try! context.fetch(request)
        if draftNotes.count == 0{
            isGotAllData = true
        }else{
            for draftNote in draftNotes{
                dataList.append(draftNote)
            }
            if draftNotes.count < 8{
                footer.endRefreshingWithNoMoreData()
            }else{
                footer.endRefreshing()
            }
            collectionView.reloadData()
        }
       
    }
    
    func loadNerbyNotes(){
        footer.endRefreshingWithNoMoreData()
//        collectionView.reloadData()
    }
    
    func loadDiscoverNotes(){
        footer.endRefreshingWithNoMoreData()
//        collectionView.reloadData()
    }
    
}

extension WaterFallVC{
    
    func loadDraftNoteCell(_ collectionView: UICollectionView,_ indexPath: IndexPath) -> DraftNoteWaterfallICell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kDraftNoteWaterfallID, for: indexPath) as! DraftNoteWaterfallICell
        cell.deleteButton.tag = indexPath.item
        cell.draftNote = dataList[indexPath.item] as? DraftNote
        cell.deleteButton.addTarget(self, action: #selector(deleteDraftNote), for: .touchUpInside)
        return cell
    }
    
    func loadDiscoverNoteCell(_ collectionView: UICollectionView,_ indexPath: IndexPath) -> WaterFallwCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kWaterFallCellID, for: indexPath) as! WaterFallwCell
        cell.photosImageView.image = UIImage(named: "\(indexPath.item + 1)")
        cell.avatarImage.image = UIImage(named: "5")
        cell.titleLabel.isHidden = testTitle[indexPath.item] == ""
        cell.titleLabel.text = testTitle[indexPath.item]
        cell.nicknameLabel.text = "🐔你太美"
        cell.likeButton.setTitle("11.4万", for: .normal)
        
        return cell
    }
    
    func loadNearbyNoteCell(_ collectionView: UICollectionView,_ indexPath: IndexPath) -> NearbyCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kNearbyCellID, for: indexPath) as! NearbyCell
    
        cell.imageView.image = UIImage(named: "\(indexPath.item + 1)")
        cell.avatarImage.image = UIImage(named: "5")
        cell.titleLabel.isHidden = testTitle[indexPath.item] == ""
        cell.titleLabel.text = testTitle[indexPath.item]
        cell.nicknameLabel.text = "🐔你太美"
        cell.distanceLabel.text = "11.4km"
        
        return cell
    }
}

extension WaterFallVC{
    
    @objc func deleteDraftNote(_ sender:UIButton){
        let index = sender.tag
        
        let alert = UIAlertController(title: "提示", message: "确认删除草稿吗？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        let deleteAction = UIAlertAction(title: "确认", style: .destructive){ _ in
            //数据
            let seletedNoote = self.dataList[index] as! DraftNote
            context.delete(seletedNoote)
            appDelegate.saveContext()
            self.dataList.remove(at: index)
            //视图
//            self.collectionView.performBatchUpdates {
//                self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
//            }
            self.collectionView.reloadData()
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }
}

extension WaterFallVC{
    
    func discoverNoteCellTap(_ collectionView: UICollectionView,_ indexPath: IndexPath){
        let detaiNoteVC = storyboard!.instantiateViewController(withIdentifier: kNoteDetailVCID) as! NoteDetailVC
        detaiNoteVC.coverImage = UIImage(named: "\(indexPath.item + 1)")!
        detaiNoteVC.modalPresentationStyle = .fullScreen
        present(detaiNoteVC, animated: true)
    }
    
    func nearbyNoteCellTap(_ collectionView: UICollectionView,_ indexPath: IndexPath){
        let detaiNoteVC = storyboard!.instantiateViewController(withIdentifier: kNoteDetailVCID) as! NoteDetailVC
        detaiNoteVC.coverImage = UIImage(named: "\(indexPath.item + 1)")!
        detaiNoteVC.modalPresentationStyle = .fullScreen
        present(detaiNoteVC, animated: true)
    }
    
    func draftNoteCellTap(_ collectionView: UICollectionView,_ indexPath: IndexPath){
        let note = dataList[indexPath.item] as! DraftNote
        if let photosData = note.photos,
           let photosDataArr = try? JSONDecoder().decode([Data].self, from: photosData){
            
            let photos = photosDataArr.map { UIImage($0) ?? imagePH }
            
            let vc = storyboard!.instantiateViewController(withIdentifier: kNoteEditingVC) as! NoteEditingVC
            vc.photos = photos
            vc.draftNote = note
            vc.saveNoteOptions = {
                self.showTextHUD(showView: self.view, "笔记保存成功")
                collectionView.reloadData()
            }
            vc.publishNoteOptions = {
                self.showTextHUD(showView: self.view, "笔记发布test")
            }
            navigationController?.pushViewController(vc, animated: true)
            
        }else{
            showTextHUD(showView: view, "加载草稿失败")
        }
    }
}

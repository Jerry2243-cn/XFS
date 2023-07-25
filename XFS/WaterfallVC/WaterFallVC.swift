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
import Hero

class WaterFallVC: UICollectionViewController, SegementSlideContentScrollViewDelegate{
    
    @objc var scrollView: UIScrollView {
            return collectionView
        }
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true)
    }
    
    var userId:Int?
    var topic:String?
    var seachKeyWord:String?
    
    var popOpt: (()->())?
    
    lazy var myPOI = POI()
    var channel = ""
    var cellType: WaterfallCellType = .discover
    
    var dataList:[Any] = []
    var currentPage = 0
    var isGotAllData = false
    var hasDraftNote = false
    
    lazy var footer = MJRefreshAutoNormalFooter()
    lazy var header = MJRefreshNormalHeader()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(WaterfallCodeCell.self, forCellWithReuseIdentifier: kWaterfallCodeCell)
        collectionView.register(NearbyCodeCell.self, forCellWithReuseIdentifier: kNearbyCodeCell)
        collectionView.register(UINib(nibName: "DraftCell", bundle: nil), forCellWithReuseIdentifier: kDraftCellID)
        config()
        getData()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name:NSNotification.Name(kRefreshNotes) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(likeOption(noti:)), name:NSNotification.Name(kLikeSucceed) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteOption(noti:)), name:NSNotification.Name(kDeleteNote) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFellow(noti:)), name:NSNotification.Name(kUpdateFellow) , object: nil)
        if cellType == .fellow{
            NotificationCenter.default.addObserver(self, selector: #selector(showDetail(noti:)), name:NSNotification.Name(kShowNoteDetail) , object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(goMine(noti:)), name:NSNotification.Name(kGotoMine) , object: nil)
        }
        if cellType == .mine{
            NotificationCenter.default.addObserver(self, selector: #selector(noDraftNoteAction), name:NSNotification.Name(kNoDraftNote) , object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(haveDraftNoteAction), name:NSNotification.Name(khaveDraftNote) , object: nil)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        if self.cellType == .like || self.cellType == .star{
            getData()
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //cell数量
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        dataList.count
    }
    
    //渲染cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cellType{
        case .draftNote:
            return loadDraftNoteCell(collectionView, indexPath)
        case .nearby:
            return loadNearbyNoteCell(collectionView, indexPath)
        case .fellow:
            return loadFellowNoteCell(collectionView, indexPath)
        default:
            return loadDiscoverNoteCell(collectionView, indexPath)
        }
        
    }
    
    //cell点击事件
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch cellType{
        case .discover:
            discoverNoteCellTap(collectionView, indexPath)
        case .draftNote:
            draftNoteCellTap(collectionView, indexPath)
        case .fellow:
            print("noAction")
        default:
            discoverNoteCellTap(collectionView, indexPath)
        }
    }

}

extension WaterFallVC: CHTCollectionViewDelegateWaterfallLayout{
    //定义cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if cellType == .mine && hasDraftNote && indexPath.item == 0{
            let width = (screenRect.width - kWaterFallpadding * 3) / 2
            return CGSize(width: width, height: 120 )
        }
        
        if cellType == .fellow {
            guard let note = dataList[indexPath.item] as? Note else{return CGSize()}
            let cellW = screenRect.width
            var imageRato = note.ratio
            if imageRato > 1.35 {
                imageRato = 1.35
            }else if imageRato < 2.0 / 3.0 {
                imageRato = 2.0 / 3.0
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kFellowCellID, for: indexPath) as! FellowCell
            var cellH = cellW * imageRato + cell.topInfoStack.bounds.height + cell.bottomInfoStack.bounds.height + 48//后续更改
            if note.title == nil && note.content == nil{
                cellH -= 29
            }
            return CGSize(width: cellW, height: cellH )
        }
        
        var size: CGSize
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kWaterfallCodeCell, for: indexPath) as! WaterfallCodeCell
        var lines = 1
        var imageRatio : Double
        switch cellType{
        case .draftNote:
            let note = dataList[indexPath.item] as? DraftNote
            size = UIImage(note?.coverPhoto)!.size
            let h = size.height
            let w = size.width
            imageRatio = h / w
            lines = cell.titleLabel.textToThisLabelLines(text: note?.title)
        default:
            if let note = dataList[indexPath.item] as? Note{
                imageRatio = note.ratio
                lines = cell.titleLabel.textToThisLabelLines(text: note.title)
            }else{
                size = imagePH.size
                let h = size.height
                let w = size.width
                imageRatio = h / w
            }
        }
        let cellW = (screenRect.width - kWaterFallpadding * 3) / 2
        if imageRatio > 1.35 {
            imageRatio = 1.35
        }else if imageRatio < 2.0 / 3.0 {
            imageRatio = 2.0 / 3.0
        }
        var cellH = cellW * imageRatio + 44 + 20
            cellH -= lines == 0 ? 9 + 16.333333 : 0
            cellH += lines == 2 ? 17 : 0
        return CGSize(width: cellW, height: cellH )
    }
}

extension WaterFallVC{
    
    func config(){
        //collectionView配置
        let layout = collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
        layout.minimumColumnSpacing = kWaterFallpadding
        layout.minimumInteritemSpacing = kWaterFallpadding
        if cellType == .fellow {
            layout.columnCount = 1
            layout.sectionInset = UIEdgeInsets(top: kWaterFallpadding   , left: 0, bottom: kWaterFallpadding, right: 0)
        }else{
            layout.columnCount = 2
            layout.sectionInset = UIEdgeInsets(top: kWaterFallpadding   , left: kWaterFallpadding, bottom: kWaterFallpadding, right: kWaterFallpadding)
            collectionView.backgroundColor = .secondarySystemBackground
        }
        
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
        currentPage = 0
        isGotAllData = false
        
        getData()
        collectionView.mj_footer?.resetNoMoreData()

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
            loadDiscoverNotes(page: currentPage)
        case .draftNote:
            loadDraftNotes(page: currentPage)
        case.nearby:
            loadNerbyNotes(page: currentPage)
        case.mine:
            loadMyNotes(page: currentPage)
        case.like:
            loadLikeNotes(page: currentPage)
        case .star:
            loadStarNotes(page: currentPage)
        case .fellow:
            loadFellowNotes(page: currentPage)
        case .topic:
            loadTopicNotes(page: currentPage)
        case .search:
            loadSearchNotes(page: currentPage)
        }
    }
}


extension WaterFallVC{
    
    //获取草稿笔记
    func loadDraftNotes(page:Int){
        hideHUD()
        let request = DraftNote.fetchRequest() as NSFetchRequest<DraftNote>
        request.fetchLimit = eachPageCount
        request.fetchOffset = page * eachPageCount
        request.propertiesToFetch = ["coverPhoto","updatedAt","title"]
        let draftNotes = try! context.fetch(request)
        if draftNotes.count == 0{
            isGotAllData = true
        }else{
            for draftNote in draftNotes{
                dataList.append(draftNote)
            }
            if draftNotes.count < eachPageCount{
                footer.endRefreshingWithNoMoreData()
            }else{
                footer.endRefreshing()
            }
            collectionView.reloadData()
        }
       
    }
    
    func loadNerbyNotes(page:Int){
        Server.shared().fetchNotesByCity(page: page) { data in
            self.loadedData(page: page, data: data)
        }
    }
    
    func loadDiscoverNotes(page:Int){
        Server.shared().fetchNotesByChannel(channel: self.channel, page: page) { data in
            self.loadedData(page: page, data: data)
        }
    }
    
    func loadLikeNotes(page:Int){
        Server.shared().fetchLikedNotes(userId: self.userId, page: page) {data in
            self.loadedData(page: page, data: data)
        }
    }
    
    func loadMyNotes(page:Int){
        footer.endRefreshingWithNoMoreData()
        Server.shared().fetchNotesByUser(userId: self.userId, page: page) {data in
            self.loadedData(page: page, data: data)
        }
    }
    
    func loadStarNotes(page:Int){
        Server.shared().fetchStarNotes(userId: self.userId, page: page) {data in
            self.loadedData(page: page, data: data)
        }
    }
    
    func loadFellowNotes(page:Int){
        Server.shared().fetchFellowNotes(page: page) { data in
            self.loadedData(page: page, data: data)
        }
    }
    
    func loadTopicNotes(page: Int){
        guard let topic = self.topic else {return}
        Server.shared().fetchtopicNotes(topic: topic, page: page) { data in
            self.loadedData(page: page, data: data)
        }
    }
    
    func loadSearchNotes(page: Int){
        guard let keyword = self.seachKeyWord else {return}
        Server.shared().searchNotes(keyword: keyword, page: page) { data in
            self.loadedData(page: page, data: data)
        }
    }
    
    func loadedData(page:Int, data:[Note]?){
        guard let notes = data else {
            showTextHUD(showView: self.view, "加载笔记失败")
            return
        }
        if page == 0{
            dataList = []
            if cellType == .mine && hasDraftNote{
                dataList.append(Data())
            }
        }
        if notes.count == 0{
            isGotAllData = true
            if cellType == .search && notes.count == 0{
                showTextHUD(showView: self.view, "没有找到相关笔记")
            }
            footer.endRefreshingWithNoMoreData()
        }else{
            for note in notes{
                dataList.append(note)
            }
            if notes.count < eachPageCount{
                footer.endRefreshingWithNoMoreData()
            }else{
                footer.endRefreshing()
            }
            
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        collectionView.mj_header?.endRefreshing()
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
    
    
    func loadDiscoverNoteCell(_ collectionView: UICollectionView,_ indexPath: IndexPath) -> UICollectionViewCell{
        if cellType == .mine && hasDraftNote && indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kDraftCellID, for: indexPath) as! DraftCell
            let request = DraftNote.fetchRequest() as NSFetchRequest<DraftNote>
            request.fetchLimit = 1
            request.propertiesToFetch = ["coverPhoto","updatedAt","title"]
            let draftNote = (try! context.fetch(request))[0]
            
            cell.notesCountLabel.text = "\(UserDefaults.standard.integer(forKey: userDefaultsDraftNotesCount))"
            cell.coverPhotoImageView.image = UIImage(draftNote.coverPhoto)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kWaterfallCodeCell, for: indexPath) as! WaterfallCodeCell
        cell.note = dataList[indexPath.item] as? Note
        if cellType == .mine && userId == appDelegate.user?.id{
            cell.isMine = true
        }
        cell.hero.id = "cover\(cell.note?.id ?? indexPath.item)\(cellType)"
        return cell
    }
    
    func loadFellowNoteCell(_ collectionView: UICollectionView,_ indexPath: IndexPath) -> FellowCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kFellowCellID, for: indexPath) as! FellowCell
        cell.note = dataList[indexPath.item] as? Note
        return cell
    }
    
    func loadNearbyNoteCell(_ collectionView: UICollectionView,_ indexPath: IndexPath) -> NearbyCodeCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kNearbyCodeCell, for: indexPath) as! NearbyCodeCell
        cell.note = dataList[indexPath.item] as? Note
        cell.hero.id = "cover\(cell.note?.id ?? indexPath.item)\(cellType)"
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
            UserDefaults.decrease(userDefaultsDraftNotesCount)
            //视图
            self.collectionView.performBatchUpdates {
                self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            }
            self.collectionView.reloadData()
            if self.dataList.isEmpty{
                self.dismiss(animated: true)
                NotificationCenter.default.post(name: NSNotification.Name(kNoDraftNote), object: nil)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }
}

extension WaterFallVC{
    
    func discoverNoteCellTap(_ collectionView: UICollectionView,_ indexPath: IndexPath){
        if cellType == .mine && hasDraftNote && indexPath.item == 0{
            let vc = storyboard!.instantiateViewController(withIdentifier: kWaterFallVCID) as! WaterFallVC
            vc.cellType = .draftNote
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            return
        }
        
        let detaiNoteVC = storyboard!.instantiateViewController(identifier: kNoteDetailVCID) { coder in
            NoteDetailVC(coder: coder, note: self.dataList[indexPath.item] as! Note)
        }
        detaiNoteVC.modalPresentationStyle = .fullScreen
        let note = dataList[indexPath.item] as! Note
        detaiNoteVC.noteDetalHeroID = "cover\(note.id)\(cellType)"
        detaiNoteVC.hero.isEnabled = true
        present(detaiNoteVC, animated: true)
    }
    
    func nearbyNoteCellTap(_ collectionView: UICollectionView,_ indexPath: IndexPath){
        let detaiNoteVC = storyboard!.instantiateViewController(identifier: kNoteDetailVCID) { coder in
            NoteDetailVC(coder: coder, note: self.dataList[indexPath.item] as! Note)
        }
        detaiNoteVC.modalPresentationStyle = .fullScreen
        let note = dataList[indexPath.item] as! Note
        detaiNoteVC.noteDetalHeroID = "cover\(note.id)\(cellType)"
        detaiNoteVC.hero.isEnabled = true
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
                self.collectionView.reloadData()
            }
            vc.publishNoteOptions = {
                self.showTextHUD(showView: self.view, "笔记发布成功")
                let seletedNoote = self.dataList[indexPath .item] as! DraftNote
                context.delete(seletedNoote)
                UserDefaults.decrease(userDefaultsDraftNotesCount)
                appDelegate.saveContext()
                self.dataList.remove(at: indexPath.item)
                self.collectionView.reloadData()
                if self.dataList.isEmpty{
                    self.dismiss(animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name(kNoDraftNote), object: nil)
                }
            }
            navigationController?.pushViewController(vc, animated: true)
            
        }else{
            showTextHUD(showView: view, "加载草稿失败")
        }
    }
}

extension WaterFallVC{
    
    @objc func likeOption(noti:NSNotification){
        let newNote = noti.object as! Note
        let start = hasDraftNote && cellType == .mine ? 1 : 0
        for i in start ..< self.dataList.count {
            var n = self.dataList[i] as! Note
            if n.user.id == newNote.user.id && n.user.fellow != newNote.user.fellow{
                n.user = newNote.user
                self.dataList[i] = n
            }
            if n.id == newNote.id {
                if !newNote.liked && self.cellType == .like{
                    self.dataList.remove(at: i)
                    self.collectionView.performBatchUpdates {
                        self.collectionView.deleteItems(at: [IndexPath(item: i, section: 0)])
                    }
                    return
                }else{
                    self.dataList[i] = newNote
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func deleteOption(noti:NSNotification){
        let deleteNoteId = noti.object as! Int
        let start = hasDraftNote && cellType == .mine ? 1 : 0
        for i in start ..< self.dataList.count {
            let note = self.dataList[i] as! Note
            if note.id == deleteNoteId{
                self.dataList.remove(at: i)
                self.collectionView.performBatchUpdates {
                    self.collectionView.deleteItems(at: [IndexPath(item: i, section: 0)])
                }
                return
            }
        }
    }
    
    @objc func showDetail(noti:NSNotification){
        let vc = noti.object as! NoteDetailVC
        present(vc, animated: true)
    }
    
    @objc func goMine(noti:NSNotification){
        guard let user = noti.object as? User else {return}
        let vc = storyboard!.instantiateViewController(withIdentifier: kMeVCID) as! MeVC
        vc.user = user
        vc.isTabIten = false
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.hero.isEnabled = true
        nav.hero.modalAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .pull(direction: .right))
        present(nav, animated: true)
    }
    
    @objc func updateFellow(noti:NSNotification){
        let id = noti.object as! Int
        let start = hasDraftNote && cellType == .mine ? 1 : 0
        for i in start ..< self.dataList.count {
            var note = self.dataList[i] as! Note
            if note.user.id == id{
                note.user.fellow.toggle()
                dataList[i] = note
            }
        }
    }
    
    @objc func noDraftNoteAction(){
        hasDraftNote = false
        if dataList[0] is Data {
            dataList.remove(at: 0)
            collectionView.reloadData()
        }
       
    }
    
    @objc func haveDraftNoteAction(){
        hasDraftNote = true
        if !(dataList[0] is Data){
            dataList.insert(Data(), at: 0)
        }
        collectionView.reloadData()
    }
}

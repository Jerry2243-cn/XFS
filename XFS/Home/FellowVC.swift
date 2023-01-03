//
//  FellowVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/3.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import XLPagerTabStrip
import SKPhotoBrowser
import MJRefresh

class FellowVC: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        let layout = collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
        
        layout.columnCount = 1
        layout.minimumColumnSpacing = kWaterFallpadding
        layout.minimumInteritemSpacing = kWaterFallpadding
        layout.sectionInset = UIEdgeInsets(top: kWaterFallpadding   , left: 0, bottom: kWaterFallpadding, right: 0)

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 13
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kFellowCellID, for: indexPath) as! FellowCell
    
//        cell.imageView.image = UIImage(named: "\(indexPath.item + 1)")
        cell.avatarImageView.image = UIImage(named: "5")
        cell.nicknameLable.text = "🐔你太美"
        cell.titleAndContentLabel.text = "全民制作人们大家好，我是练习时长两年半的个人练习生蔡徐坤，喜欢唱、跳、rap、篮球"
        cell.titleAndContentLabel.superview?.isHidden = indexPath.item % 4 == 1
        cell.likeButton.setTitle("11", for: .normal)
        cell.favouriteButton.setTitle("45", for: .normal)
        cell.commentButton.setTitle("14", for: .normal)
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension FellowVC: CHTCollectionViewDelegateWaterfallLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellW = UIScreen.main.bounds.width
        let size = UIImage(named: "\(indexPath.item + 1)")!.size
        let h = size.height
        let w = size.width
        var imageRato = h / w
        if imageRato > 1.35 {
            imageRato = 1.35
        }else if imageRato < 2.0 / 3.0 {
            imageRato = 2.0 / 3.0
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kFellowCellID, for: indexPath) as! FellowCell
        var cellH = cellW * imageRato + cell.topInfoStack.bounds.height + cell.bottomInfoStack.bounds.height + 48//后续更改
        if indexPath.item % 4 == 1{
            cellH -= 29
        }
        return CGSize(width: cellW, height: cellH )
    }
}

extension FellowVC: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        IndicatorInfo(title: "关注")
    }
}


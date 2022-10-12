//
//  WaterFallVC.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/2.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import XLPagerTabStrip

class WaterFallVC: UICollectionViewController{
    
    var channel = ""
    
    let testTitle = "今天也是打🏀的一天～"
   
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
        
        layout.columnCount = 2
        layout.minimumColumnSpacing = kWaterFallpadding
        layout.minimumInteritemSpacing = kWaterFallpadding
        layout.sectionInset = UIEdgeInsets(top: kWaterFallpadding   , left: kWaterFallpadding, bottom: kWaterFallpadding, right: kWaterFallpadding)
        collectionView.backgroundColor = .secondarySystemBackground
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kWaterFallCellID, for: indexPath) as! WaterFallwCell
    
        cell.photosImageView.image = UIImage(named: "\(indexPath.item + 1)")
    
        cell.avatarImageView.image = UIImage(named: "5")
        if indexPath.item % 3 == 1 {
            cell.titleLable.isHidden = true
        }else{
            cell.titleLable.text = testTitle
        }
        cell.nicknamLableView.text = "🐔你太美"
        cell.likeButton.setTitle("11.4万", for: .normal)
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

extension WaterFallVC: CHTCollectionViewDelegateWaterfallLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellW = (UIScreen.main.bounds.width - kWaterFallpadding * 3) / 2
        let size = UIImage(named: "\(indexPath.item + 1)")!.size
        let h = size.height
        let w = size.width
        var imageRato = h / w
        if imageRato > 1.35 {
            imageRato = 1.35
        }else if imageRato < 2.0 / 3.0 {
            imageRato = 2.0 / 3.0
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kWaterFallCellID, for: indexPath) as! WaterFallwCell
        var cellH = cellW * imageRato + cell.infoStack.bounds.height + 20
        if indexPath.item % 3 == 1 {
            cellH -= cell.titleLable.bounds.height + cell.infoStack.spacing
        }
        return CGSize(width: cellW, height: cellH )
    }
}

extension WaterFallVC: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        IndicatorInfo(title: channel)
    }
}


//
//  DraftNoteWaterfallICell.swift
//  XFS
//
//  Created by Jerry Zhu on 2022/10/16.
//

import UIKit

class DraftNoteWaterfallICell: UICollectionViewCell {
    
    var draftNote: DraftNote?{
        didSet{
            guard let draftNote = draftNote else {return}
            
            coverPhotoImageView.image = UIImage(draftNote.coverPhoto)
            titleLabel.text = draftNote.title
            titleLabel.isHidden = draftNote.title == ""
            updateTimeLabel.text = draftNote.updatedAt?.formatterDate
            
        }
    }
    
    @IBOutlet weak var coverPhotoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var infoStack: UIStackView!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        deleteButton.setTitle("", for: .normal)
    }
}

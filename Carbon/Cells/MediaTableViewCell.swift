//
//  MediaTableViewCell.swift
//  Carbon
//
//  Created by Mobile on 9/14/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit

class MediaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imvThumbnail: UIImageView!
    @IBOutlet weak var imvUserProfilePicture: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblLikesAndCommentCount: UILabel!
    @IBOutlet weak var imvType: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var btnCheckbox: UIButton!
    @IBOutlet weak var startingXPosConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  IAPItemTableViewCell.swift
//  Carbon
//
//  Created by Mobile on 9/23/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit

public protocol IAPItemTableViewCellDelegate : NSObjectProtocol {
    
    func purchase(_ indexPath: IndexPath)
}

class IAPItemTableViewCell: UITableViewCell {
    
    var indexPath: IndexPath!
    weak open var delegate: IAPItemTableViewCellDelegate?
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var btnPurchase: UIButton!
    @IBOutlet weak var lblPrice: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 0.2
        mainView.layer.shadowRadius = 6
        mainView.layer.shadowOffset = CGSize(width: -1, height: 2)
        
        tvDescription.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Actions
    @IBAction func purchaseBtnTapped(_ sender: AnyObject) {
        if delegate != nil {
            delegate?.purchase(indexPath)
        }
    }
}

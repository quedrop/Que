//
//  ManualStoreTotalCell.swift
//  QueDrop
//
//  Created by C100-174 on 29/05/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class ManualStoreTotalCell: UITableViewCell {
    @IBOutlet var viewManualTotal: UIView!
    @IBOutlet var lblManualStoreTotal: UILabel!
    @IBOutlet var constraintViewMnualStoreTotalHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

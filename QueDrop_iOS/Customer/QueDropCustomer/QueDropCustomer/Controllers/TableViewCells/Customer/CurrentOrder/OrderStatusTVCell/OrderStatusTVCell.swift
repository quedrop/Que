//
//  OrderStatusTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 30/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import FlexibleSteppedProgressBar

class OrderStatusTVCell: UITableViewCell {

	@IBOutlet var viewOrderStatus: FlexibleSteppedProgressBar!
	override func awakeFromNib() {
        super.awakeFromNib()
		self.viewOrderStatus.delegate = self
		viewOrderStatus.stepTextColor = THEME_COLOR
		viewOrderStatus.currentSelectedTextColor = THEME_COLOR
		viewOrderStatus.currentSelectedCenterColor = THEME_COLOR
		viewOrderStatus.selectedBackgoundColor = THEME_COLOR
		viewOrderStatus.lastStateCenterColor = THEME_COLOR
		viewOrderStatus.lastStateOuterCircleStrokeColor = THEME_COLOR
		viewOrderStatus.selectedOuterCircleStrokeColor = THEME_COLOR
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

		
	}

}
extension OrderStatusTVCell : FlexibleSteppedProgressBarDelegate{
		/*func progressBar(progressBar: FlexibleSteppedProgressBar,
						 textAtIndex index: Int, position: FlexibleSteppedProgressBarTextLocation) -> String {
			if position == FlexibleSteppedProgressBarTextLocation.bottom {
				switch index {
					
				case 0: return "Accepted"
				case 1: return "Dispatch For Delivery"
				case 2: return "Delivered"
				default: return ""
					
				}
			}
		return ""
		}*/
	func progressBar(_ progressBar: FlexibleSteppedProgressBar, textAtIndex index: Int, position: FlexibleSteppedProgressBarTextLocation) -> String {
		
		if position == FlexibleSteppedProgressBarTextLocation.bottom {
				switch index {
					
				case 0: return "Accepted"
				case 1: return "Dispatch For Delivery"
				case 2: return "Delivered"
				default: return ""
					
				}
			}
		return ""
	}
}

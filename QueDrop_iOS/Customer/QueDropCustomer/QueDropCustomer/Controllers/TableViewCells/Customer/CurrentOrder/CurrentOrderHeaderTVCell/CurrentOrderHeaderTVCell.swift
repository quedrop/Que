//
//  CurrentOrderHeaderTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 27/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class CurrentOrderHeaderTVCell: UITableViewCell {

	@IBOutlet var imgStoreLogo: UIImageView!
	@IBOutlet var lblStoreName: UILabel!
	@IBOutlet var lblStoreAddress: UILabel!
	@IBOutlet var viewTimer: UIView!
	@IBOutlet var lblTimerRunningTime: MZTimerLabel!
	@IBOutlet var viewTimerRound: UIView!
	@IBOutlet var outerView: UIView!
	@IBOutlet var innerView: UIView!
	@IBOutlet var btnReSchedule: UIButton!
	
	//Timer
	var timer = Timer()
	var min = "00"
	var second = 60
	var fromDetailScreen  = false
	//var delegate : CustomeTimerDelegate?
	var orderId = 0
	
	override func awakeFromNib() {
        super.awakeFromNib()
        if lblTimerRunningTime != nil
        {
            lblTimerRunningTime.timeFormat = "mm:ss"
            lblTimerRunningTime.timerType = MZTimerLabelTypeTimer
        }
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	func setBorderLayout(forLayout : String)
	{
		if forLayout == "top"
		{
			self.outerView.clipsToBounds = true
			self.outerView.layer.cornerRadius = 8
			self.outerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
			self.innerView.clipsToBounds = true
			self.innerView.layer.cornerRadius = 8
			self.innerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		}
	}
	func setTimer(_ fromDetailScreen : Bool)
	{
		self.fromDetailScreen = fromDetailScreen
		timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.tick) , userInfo: nil, repeats: true)
	}
	@objc func tick() {
		second = UserDefaults.standard.integer(forKey: "oneMinTimerSec_\(orderId)")
		if lblTimerRunningTime != nil
		{
			
			if second <= 0
			{
				timer.invalidate()
				self.lblTimerRunningTime.text = "00:00"
				self.viewTimer.isHidden = true
				self.btnReSchedule.isHidden  = fromDetailScreen
			}
			else
			{
				if second >= 10
				{
					lblTimerRunningTime.text = "\(min):\(second)"
				}
				else
				{
					lblTimerRunningTime.text = "\(min):0\(second)"
				}
			}
		}
	}
}

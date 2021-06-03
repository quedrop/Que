//
//  SupplierStoreTimingTVC.swift
//  QueDrop
//
//  Created by C100-105 on 12/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierStoreTimingTVC: BaseTableViewCell {

    @IBOutlet weak var constraintsWeekDayWidth: NSLayoutConstraint!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewStackContainer: UIView!
    
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var txtStartTime: UITextField!
    @IBOutlet weak var txtCloseTime: UITextField!
    @IBOutlet weak var switchOnOff: UISwitch!
    
    var callbackForOnOffChange: Callback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func switchValueChange(_ sender: Any) {
        callbackForOnOffChange?()
    }
    
    func setupONOff() {
        let isOffDay = !switchOnOff.isOn
        txtCloseTime.isHidden = isOffDay
        if isOffDay {
            txtStartTime.text = "Closed"
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        txtStartTime.showBorder(.lightGray, 5)
        txtCloseTime.showBorder(.lightGray, 5)
        switchOnOff.tintColor = .lightGray
        switchOnOff.onTintColor = #colorLiteral(red: 0.6941176471, green: 0.8980392157, blue: 0.8941176471, alpha: 1)
        switchOnOff.thumbTintColor = .appColor
    }
    
    func bindDetails(ofSchedule schedule: Schedule?, isEdit: Bool) {
        switchOnOff.isHidden = !isEdit
        switchOnOff.isOn = (schedule?.isClosed).asInt() == 0

        let dayName = schedule?.weekday.asString().prefix(3).description
        lblDay.text = dayName
        
        txtStartTime.text = schedule?.openingTime?.toDate(format: Schedule.TimeFormatDb)?.toString(format: Schedule.ResultFormatUI)
        txtCloseTime.text = schedule?.closingTime?.toDate(format: Schedule.TimeFormatDb)?.toString(format: Schedule.ResultFormatUI)
        
        constraintsWeekDayWidth.constant = isEdit ? 70 : 120
        
        setupONOff()
    }
}

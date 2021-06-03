//
//  termAndConditionTVC.swift
//  QueDrop
//
//  Created by C100-104 on 27/12/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class termAndConditionTVC: UITableViewCell {

	@IBOutlet var btnCheckBox: UIButton!
	@IBOutlet var lblTerms: TTTAttributedLabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLinkLabels()
        drawBorder(view: btnCheckBox, color: .gray, width: 1.0, radius: 2.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupLinkLabels()  {
           let strInfo = "By clicking this box I have read the Terms & Conditions for this app" as NSString
           lblTerms.text = strInfo
           lblTerms.numberOfLines = 0;
           
           let fullAttributedString = NSAttributedString(string:strInfo as String, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
               NSAttributedString.Key.font : UIFont.init(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 13.0)) as Any
               ])
           lblTerms.textAlignment = .left
           lblTerms.attributedText = fullAttributedString;
           
           let rangeTC = strInfo.range(of: "Terms & Conditions")
           
           let ppLinkAttributes: [String: Any] = [
               NSAttributedString.Key.foregroundColor.rawValue: THEME_COLOR.cgColor,
               NSAttributedString.Key.underlineStyle.rawValue: false,
               NSAttributedString.Key.font.rawValue : UIFont.init(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 13.0)) as Any
               ]
           let ppActiveLinkAttributes: [String: Any] = [
               NSAttributedString.Key.foregroundColor.rawValue: LINK_COLOR.cgColor,
               NSAttributedString.Key.underlineStyle.rawValue: false,
               NSAttributedString.Key.font.rawValue : UIFont.init(name: fFONT_REGULAR, size: calculateFontForWidth(size: 13.0)) as Any
               ]
           
           lblTerms.activeLinkAttributes = ppActiveLinkAttributes
           lblTerms.linkAttributes = ppLinkAttributes
           
           let urlTC = URL(string: "action://TC")!
           lblTerms.addLink(to: urlTC, with: rangeTC)
           
           lblTerms.textColor = UIColor.black;
           //lblTerms.delegate = self;
       }
}

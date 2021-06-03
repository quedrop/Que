//
//  StoreNumberInfoWindow.swift
//  GoferDriver
//
//  Created by C100-174 on 01/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class StoreNumberInfoWindow: BaseViewController {
    @IBOutlet var lblNumber: UILabel!
    @IBOutlet var viewContainer: UIView!
    
    var number : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        drawBorder(view: viewContainer, color: .white, width: 2.0, radius: Float(viewContainer.frame.width/2.0))
        lblNumber.textColor = .white
        lblNumber.font = UIFont(name: fFONT_BOLD, size: 15.0)
        lblNumber.text = self.number
    }


   func setValues(number : String )
    {
        self.number = number
    }

}

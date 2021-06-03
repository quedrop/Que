//
//  TimerViewVC.swift
//  QueDrop
//
//  Created by C100-104 on 03/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

protocol CustomeTimerDelegate{
	func dismissTimer()
}

class TimerViewVC: UIViewController {

	
	
	@IBOutlet var viewTimerPopUp: UIView!
	@IBOutlet var lblTime: MZTimerLabel!
	@IBOutlet var lbltext: UILabel!
	@IBOutlet var buttonOk: UIButton!
	
	var timer = Timer()
	var min = "00"
	var second = 180
	var delegate : CustomeTimerDelegate?
	var orderId = 0
	override func viewDidLoad() {
        super.viewDidLoad()
		nc.addObserver(self, selector: #selector(updateOrderStatus(notification:)), name: Notification.Name(notificationCenterKeys.orderAccepted.rawValue), object: nil)
        
        lblTime.timeFormat = "mm:ss"
        lblTime.timerType = MZTimerLabelTypeTimer
        lblTime.delegate = self
        lblTime.reset()
        lblTime.addTimeCounted(byTime: TimeInterval(second))
        lblTime.start()
      
    }
    
	@IBAction func actionOK(_ sender: Any) {
		self.dismiss(animated: false, completion: {
			self.delegate?.dismissTimer()
		})
	}
	
	
	@objc func updateOrderStatus(notification:Notification){
       print("finish")
       lblTime.pause()
       lblTime.reset()
       self.dismiss(animated: false, completion: {
           self.delegate?.dismissTimer()
       })

	}
    func setOrderId(orderId : Int, ServerTime :  String)
    {
        let dateStr = ServerTime
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var serverDate = dateFormatter.date(from:dateStr)!
        serverDate = serverDate.UTCtoLocal().toDate()!
        let difference = Calendar.current.dateComponents([.second], from: serverDate, to: Date())
        var seconds = difference.second ?? 0
        print("Timer Second ::::",seconds)
            seconds = AcceptOrderWaitingTime - seconds
        self.second = seconds
        
        
        
        self.orderId = orderId
        timer.invalidate()
    }
}
extension TimerViewVC : MZTimerLabelDelegate {
    func timerLabel(_ timerLabel: MZTimerLabel!, finshedCountDownTimerWithTime countTime: TimeInterval) {
        print("finish")
        lblTime.pause()
        lblTime.reset()
        self.dismiss(animated: false, completion: {
            self.delegate?.dismissTimer()
        })
       // UserDefaults.standard.removeObject(forKey: "oneMinTimerSec_\(orderId)")
    }
/*    func timerLabel(_ timerLabel: MZTimerLabel!, countingTo time: TimeInterval, timertype timerType: MZTimerLabelType) {
        print(timerLabel.text)
        
    }*/
}

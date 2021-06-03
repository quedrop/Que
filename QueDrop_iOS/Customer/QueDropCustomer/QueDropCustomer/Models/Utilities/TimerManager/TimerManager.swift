//
//  TimerManager.swift
//  QueDrop
//
//  Created by C100-104 on 28/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import Foundation
import UIKit

class TimerManager: NSObject {

    static var timer: Timer?
    static private var seconds = 0
    static var timeString: ((_ value: String?, _ ends: Bool) -> Void)?
    
    static func start(withSeconds: Int) -> Void {
        seconds = withSeconds
        timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(TimerManager.update), userInfo: nil, repeats: true)
    }
    
	@objc static func update() -> Void {
        if seconds == 0 {
            timer?.invalidate()
            timeString?(nil,true)
        } else {
            seconds -= 1
            let value = getString(from: TimeInterval(seconds))
            timeString?(value,false)
        }
    }
    
    static private func getString(from time: TimeInterval) -> String {
        _ = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
//        return String(format: "%02i:%02i:%02i", hours,minutes,seconds)
		return String(format: "%02i:%02i", minutes,seconds)
    }

    static func destroy() -> Void {
        timer?.invalidate()
        timer = nil
    }
    
}

//
//  Date.swift
//  Freddy
//
//  Created by C100-107 on 01/06/19.
//  Copyright © 2019 C100-107. All rights reserved.
//

import Foundation
let defaultDateFormat = "0000-00-00 00:00:00"
extension Date {
	
    init?(jsonDate: String) {
        let prefix = "/Date("
        let suffix = ")/"
        let scanner = Scanner(string: jsonDate)
        
        // Check prefix:
        guard scanner.scanString(prefix, into: nil)  else { return nil }
        
        // Read milliseconds part:
        var milliseconds : Int64 = 0
        guard scanner.scanInt64(&milliseconds) else { return nil }
        // Milliseconds to seconds:
        var timeStamp = TimeInterval(milliseconds)/1000.0
        
        // Read optional timezone part:
        var timeZoneOffset : Int = 0
        if scanner.scanInt(&timeZoneOffset) {
            let hours = timeZoneOffset / 100
            let minutes = timeZoneOffset % 100
            // Adjust timestamp according to timezone:
            timeStamp += TimeInterval(3600 * hours + 60 * minutes)
        }
        
        // Check suffix:
        guard scanner.scanString(suffix, into: nil) else { return nil }
        
        // Success! Create NSDate and return.
        self.init(timeIntervalSince1970: timeStamp)
    }
    func toString(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
	func daySuffix() -> String {
		let calendar = Calendar.current
		let dayOfMonth = calendar.component(.day, from: self)
		switch dayOfMonth {
		case 1, 21, 31: return "st"
		case 2, 22: return "nd"
		case 3, 23: return "rd"
		default: return "th"
		}
	}
    func localToUTC(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dt = dateFormatter.date(from: self.toString(format: format))
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormatter.string(from: dt!)
    }
    
    func UTCtoLocal(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: self.toString(format: format))
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: dt!)
    }
    
    func toString (format: String = "yyyy-MM-dd HH:mm:ss") -> String? {
        return DateFormatter(format: format).string(from: self)
    }
    
    func timeAgo() -> String? {
        let date: Date? = self
        let units:Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        var components: DateComponents? = nil
        if let aDate = date {
            components = Calendar.current.dateComponents(units, from: aDate, to: Date())
        }
        
        var strTimeAgo: String?
        
        if (components?.year ?? 0) > 0 {
            strTimeAgo = date?.toString(format: "yyyy-MM-dd")
        } else if (components?.month ?? 0) > 0 {
            strTimeAgo = date?.toString(format: "MM-dd hh:mm a")
        } else if (components?.weekOfYear ?? 0) > 0 {
            strTimeAgo = date?.toString(format: "MM-dd hh:mm a")
        } else if (components?.day ?? 0) > 0 {
            strTimeAgo = date?.toString(format: "MM-dd hh:mm a")
        } else if (components?.hour ?? 0 >= 1) {
            strTimeAgo = date?.toString(format: "hh:mm a")
        } else if (components?.minute ?? 0 >= 1) {
            strTimeAgo = "\(Int(components?.minute ?? 0)) m ago"
        } else if (components?.second ?? 0 >= 10) {
            strTimeAgo = "\(Int(components?.second ?? 0)) s ago"
        } else {
            strTimeAgo = "Just now"
        }
        
        return strTimeAgo
    }
    
    
    
    
}
extension DateFormatter {
    
    convenience init (format: String) {
        self.init()
        dateFormat = format
        locale = Locale.current
    }
}

extension String {
    
    func toDate (format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        return DateFormatter(format: format).date(from: self)
    }
    
    func toDateString (inputFormat: String = "yyyy-MM-dd HH:mm:ss", outputFormat: String) -> String? {
        if let date = toDate(format: inputFormat) {
            return DateFormatter(format: outputFormat).string(from: date)
        }
        return nil
    }
    
    func timeAgo() -> String? {
        
        let date = self.toDate()
        
        let units:Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        var components: DateComponents? = nil
        if let aDate = date {
            components = Calendar.current.dateComponents(units, from: aDate, to: Date())
        }
        
        var strTimeAgo: String?
        
        if (components?.year ?? 0) > 0 || (components?.month ?? 0) > 0 || (components?.weekOfYear ?? 0) > 0 {
            strTimeAgo = date?.toString(format: "dd-MM-yyyy")
        } else if (components?.day ?? 0) == 1 {
            strTimeAgo = "Yesterday"
        }  else if (components?.day ?? 0) > 0 {
            strTimeAgo = date?.toString(format: "dd/MM/yyyy")
        } else if (components?.hour ?? 0 >= 1) {
            strTimeAgo = date?.toString(format: "h:mm a")
        } else if (components?.minute ?? 0 >= 1) {
            strTimeAgo = "\(Int(components?.minute ?? 0))m ago"
        } else if (components?.second ?? 0 >= 10) {
            strTimeAgo = "\(Int(components?.second ?? 0))s ago"
        } else {
            strTimeAgo = "Just now"
        }
        
        return strTimeAgo
    }
}

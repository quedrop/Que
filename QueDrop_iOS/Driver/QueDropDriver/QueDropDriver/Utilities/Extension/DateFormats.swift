//
//  DateFormats.swift
//  SwiftDemo
//
//  Created by MPA on 18/04/16.
//  Copyright © 2016 Narolainfotech. All rights reserved.
//

import Foundation

public let ONLY_DOB_FORMAT: String = "yyyy/MM/dd"
public let ANSWER_DATE_FORMAT: String = "dd MMM yy"
public let PROFILE_DATE_FORMAT: String = "dd-MM-yyyy"
public let BIRTH_DATE_FORMAT: String = "dd MMMM yyyy"

public let GLOBAL_DATE_FORMAT: String = "yyyy-MM-dd HH:mm:ss"
public let TIMEZONE_DATE_FORMAT: String = "yyyy-MM-dd HH:mm:ss Z"
public let VIOLATION_DATE_FORMAT: String = "MM/DD/YYYY HH:mm:ss a"
public let HISTORY_DATE_FORMAT: String = "MMM DD YYYY HH:mma"
public let ONLY_DATE_FORMAT: String = "yyyy-MM-dd"
public let ONLY_TIME_FORMAT: String = "HH:mm:00"
public let ONLY_DATE_TIME_FORMAT: String = "yyyy-MM-dd HH:mm:00"

public let ONLY_DATE_MONTH_FORMAT: String = "dd/MM"
public let FULL_DATE_FORMAT: String = "dd MMM yyyy hh:mm a"
public let FB_BIRTH_DATE_FORMAT: String = "MM/dd/yyyy"
public let DIFF_DATE_FORMAT: String = "EEE d MMM yyyy"
public let ONLY_TIME_FORMAT_12HRS: String = "hh:mm a"

class DateFormater {
    
    private static let sharedInstance = DateFormater()
    private var gameScore: Int = 0
    
    var sharedDateFormat : DateFormatter? = nil
    
    struct once {
      //  static var onceToken: dispatch_once_t = 0
    }
    
    
    
    // METHODS
    private init() {
//        dispatch_once(&once.onceToken) {
            self.sharedDateFormat = DateFormatter()
            self.sharedDateFormat!.timeZone = NSTimeZone.system
            let enUSPOSIXLocale: NSLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        self.sharedDateFormat!.locale = enUSPOSIXLocale as Locale?
        //}
    }
    //    class func displayGameScore() {
    //        DLog(message: "\(__FUNCTION__) \(self.sharedInstance.gameScore)")
    //    }
    //    class func incrementGameScore(scoreInc: Int) {
    //        self.sharedInstance.gameScore += scoreInc
    //    }
    //
    
    //MARK:- Convert To Local TimeZone
    func convertDateAccordingDeviceTime(dategiven:String) -> NSDate
    {
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        let inputTimeZone = NSTimeZone(abbreviation: "UTC")
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.timeZone = inputTimeZone as TimeZone?
        inputDateFormatter.dateFormat = dateFormat
        let date = inputDateFormatter.date(from: dategiven)
        let outputTimeZone = NSTimeZone.local
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.timeZone = outputTimeZone
        outputDateFormatter.dateFormat = dateFormat
        let outputString = outputDateFormatter.string(from: date!)
        return outputDateFormatter.date(from: outputString)! as NSDate
    }
    func convertDateAccordingDeviceTimeString(dategiven:String) -> String
    {
        let inputDateFormatter = DateFormatter()
        let outputDateFormatter = DateFormatter()
        
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        let inputTimeZone = NSTimeZone(abbreviation: "UTC")
        
        inputDateFormatter.timeZone = inputTimeZone as TimeZone?
        inputDateFormatter.dateFormat = dateFormat
        let date = inputDateFormatter.date(from: dategiven)
        let outputTimeZone = NSTimeZone.local
        
        outputDateFormatter.timeZone = outputTimeZone
        outputDateFormatter.dateFormat = dateFormat
        let outputString = outputDateFormatter.string(from: date!)
        return outputString
    }
    class func convertDateToLocalTimeZone(givenDate: String) -> String {
        var final_date: String
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        //SET TIME ZONE FORMAT OF SERVER HERE
        let ts_utc: NSDate = self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        final_date = self.sharedInstance.sharedDateFormat!.string(from: ts_utc as Date)
        return final_date
    }
    
    class func convertDateToLocalTimeZoneForDate(givenDate: NSDate) -> NSDate {
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        //SET TIME ZONE FORMAT OF SERVER HERE
        let strDate: String = self.sharedInstance.sharedDateFormat!.string(from: givenDate as Date)
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.local
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.date(from: strDate)! as NSDate
    }
    
    class func convertDateToLocalTimeZoneForDateFromString(givenDate: String) -> NSDate {
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        //SET TIME ZONE FORMAT OF SERVER HERE
        return self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
    }
    
    class func convertLocalDateTimeToServerTimeZone(givenDate: String) -> String {
        let final_date: String
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        let ts_utc: NSDate = self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        final_date = self.sharedInstance.sharedDateFormat!.string(from: ts_utc as Date)
        return final_date
    }
    
    class func generateDateForGivenDateToServerTimeZone(givenDate: NSDate) -> String {
        self.sharedInstance.sharedDateFormat!.dateFormat = ONLY_DATE_TIME_FORMAT
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        //SET TIME ZONE FORMAT OF SERVER HERE
        return self.sharedInstance.sharedDateFormat!.string(from: givenDate as Date)
    }
    
    class func getUTCDateFromUTCString(givenDate: String) -> NSDate {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
    }
    
    //MARK:- Common Formats
    class func getStringFromDateString(givenDate: String) -> String {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        let date: NSDate = self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.string(from: date as Date)
    }
    
    class func getStringFromDate(givenDate: NSDate) -> String {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.string(from: givenDate as Date)
    }
    
    class func getFullDateStringFromDate(givenDate: NSDate) -> String {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = FULL_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.string(from: givenDate as Date)
    }
    
    class func getFullDateStringFromString(givenDate: String) -> String {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        let date: NSDate = self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
        self.sharedInstance.sharedDateFormat!.dateFormat = FULL_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.string(from: date as Date)
    }
    
    class func getDateFromString(givenDate: String) -> NSDate
    {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.local
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
    }
    
    class func getTimeDateFromString(givenDate: String) -> NSDate
    {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        self.sharedInstance.sharedDateFormat!.dateFormat = TIMEZONE_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
    }
    class func getDateFromStringMMDDYYHHMMSS(givenDate: String) -> NSDate {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = VIOLATION_DATE_FORMAT
        var returnDate = self.sharedInstance.sharedDateFormat!.date(from: givenDate)
        if(returnDate == nil)
        {
            self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
            self.sharedInstance.sharedDateFormat!.dateFormat = HISTORY_DATE_FORMAT
            returnDate = self.sharedInstance.sharedDateFormat!.date(from: givenDate)
            return returnDate! as NSDate
        }
        else
        {
            return returnDate! as NSDate
        }
        //return self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
    }
    
    class func getDateFromJustDateString(givenDate: String) -> NSDate {
        
        self.sharedInstance.sharedDateFormat!.dateFormat = ONLY_DATE_FORMAT
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        
        let newDate:NSDate =  self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
        
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        
        let newDateString:String = self.getStringFromDate(givenDate: newDate)
        
        return self.sharedInstance.sharedDateFormat!.date(from: newDateString)! as NSDate
    }
    
    class func getDateFromDate(givenDate: NSDate) -> NSDate {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        let strDate: String = self.sharedInstance.sharedDateFormat!.string(from: givenDate as Date)
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.date(from: strDate)! as NSDate
    }
    
    //MARK:- Timestamp Formats
    class func getTimestampUTC() -> String {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone(name:"UTC") as TimeZone?
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.string(from: NSDate() as Date)
    }
    
    class func getTimestampFromGivenDate(givenDate: String) -> NSDate {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone(name:"UTC") as TimeZone?
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
    }
    
    //MARK:- Generate Date
    class func generateDateForGivenDate(strDate: NSDate, andTime strTime: NSDate) -> String {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = ONLY_DATE_FORMAT
        let dt: String = self.sharedInstance.sharedDateFormat!.string(from: strDate as Date)
        self.sharedInstance.sharedDateFormat!.dateFormat = ONLY_TIME_FORMAT
        let tm: String = self.sharedInstance.sharedDateFormat!.string(from: strTime as Date)
        return "\(dt) \(tm)"
    }
    
    //MARK:- Generate Date
    class func generateTimeForGivenDate(strDate: NSDate) -> String {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = ONLY_TIME_FORMAT_12HRS
        let tm: String = self.sharedInstance.sharedDateFormat!.string(from: strDate as Date)
        return "\(tm)"
    }
        
    class func generateDateForGivenDate(strDate: NSDate) -> String {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = ONLY_DATE_TIME_FORMAT
        return self.sharedInstance.sharedDateFormat!.string(from: strDate as Date)
    }
    
    class func generateOnlyDateForGivenDate(strDate: NSDate) -> String {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = ONLY_DOB_FORMAT
        return self.sharedInstance.sharedDateFormat!.string(from: strDate as Date)
    }
    
    class func generateAnswerDateForGivenDate(strDate: NSDate) -> String {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = ANSWER_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.string(from: strDate as Date)
    }
    
    class func generateProfileDateForGivenDate(strDate: NSDate) -> String {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = BIRTH_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.string(from: strDate as Date)
    }
    
    class func generateProfileDateForGivenString(strDate: String) -> Date {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = BIRTH_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.date(from: strDate)!
    }
    
    //MARK:- Birth Date
    class func getBirthDateFromString(givenDate: String) -> NSDate {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = ONLY_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
    }
    
    class func getBirthDateStringFromDateString(givenDate: String) -> String {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = ONLY_DATE_FORMAT
        let date: NSDate = self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
        self.sharedInstance.sharedDateFormat!.dateFormat = DIFF_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.string(from: date as Date)
    }

    
    class func birthdayConstraintForUser(givenDate: NSDate) -> NSDate {
        
        let dateComponents: NSDateComponents = NSDateComponents()
        dateComponents.year = -3
        
        let expirationDate = NSCalendar.current.date(byAdding: dateComponents as DateComponents, to: givenDate as Date)
        return expirationDate! as NSDate
    }
    
    class func minBirthdayConstraintForUser(givenDate: NSDate) -> NSDate {
        let dateComponents: NSDateComponents = NSDateComponents()
        dateComponents.year = -100
        let expirationDate = NSCalendar.current.date(byAdding: dateComponents as DateComponents, to: givenDate as Date)
        return expirationDate! as NSDate
    }
    
    class func minViolationDateConstraintForUser(givenDate: NSDate) -> NSDate {
        let dateComponents: NSDateComponents = NSDateComponents()
        dateComponents.year = -1
        let expirationDate = NSCalendar.current.date(byAdding: dateComponents as DateComponents, to: givenDate as Date)
        return expirationDate! as NSDate
    }

    class func generateBirthDateForGivenDate(strDate: NSDate) -> String {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = BIRTH_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.string(from: strDate as Date)
    }
    
    class func generateBirthDateForGivenFacebookDate(strDate: String) -> NSDate {
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = FB_BIRTH_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.date(from: strDate)! as NSDate
    }
    
    /*class func calculateAgeForDOB(DOB: String) -> Int {
        self.sharedInstance.sharedDateFormat!.dateFormat = ONLY_DATE_FORMAT
        let birthday: NSDate = self.sharedInstance.sharedDateFormat!.date(from: DOB)! as NSDate
        let now: NSDate = NSDate()
        let ageComponents: NSDateComponents = NSCalendar.currentCalendar.components(.Year, fromDate: birthday, toDate: now, options: [])
        
        let age: Int = ageComponents.year
        return age
    }*/
    
    class func getStringDateWithSuffix(givenDate: String) -> String {
        //Convert EEE dd MMM yyyy formate
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = GLOBAL_DATE_FORMAT
        let date: NSDate = self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
        self.sharedInstance.sharedDateFormat!.dateFormat = DIFF_DATE_FORMAT
        var strDate: String = self.sharedInstance.sharedDateFormat!.string(from: date as Date)
        //To get only date from string
        let monthDayFormatter: DateFormatter = DateFormatter()
        monthDayFormatter.formatterBehavior = .behavior10_4
        
        monthDayFormatter.dateFormat = "d"
        let date_day: Int = Int(monthDayFormatter.string(from: date as Date))!
        monthDayFormatter.dateFormat = "yyyy"
        let date_year: Int = Int(monthDayFormatter.string(from: date as Date))!
        strDate = strDate.replacingOccurrences(of: "\(date_year)", with: "")
        //Add suffix
        var suffix: NSString?
        let ones: Int = date_day % 10
        let tens: Int = (date_day / 10) % 10
        if tens == 1 {
            suffix = "th"
        }
        else if ones == 1 {
            suffix = "st"
        }
        else if ones == 2 {
            suffix = "nd"
        }
        else if ones == 3 {
            suffix = "rd"
        }
        else {
            suffix = "th"
        }
        
        strDate = strDate.replacingOccurrences(of: "\(date_day)", with: "\(date_day)\(suffix ?? "")")
        strDate = "\(strDate)\(date_year)"
        return strDate
        
    }
    
    
    class func convertFaceBookDateIntoString(givenDate: String) -> String {
        
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        self.sharedInstance.sharedDateFormat!.dateFormat = FB_BIRTH_DATE_FORMAT
        let date: NSDate = self.sharedInstance.sharedDateFormat!.date(from: givenDate)! as NSDate
        self.sharedInstance.sharedDateFormat!.dateFormat = ONLY_DATE_FORMAT
        return self.sharedInstance.sharedDateFormat!.string(from: date as Date)
    }
    
    class func convertdateIntoArabic(givenDate: String) -> String {
        
        self.sharedInstance.sharedDateFormat!.timeZone = NSTimeZone.system
        
        // initialize formatter and set input date format
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // read input date string as NSDate instance
        let date = DateFormater.getDateFromString(givenDate: givenDate)
            
            // set locale to "ar_DZ" and format as per your specifications
        formatter.locale = NSLocale(localeIdentifier: "ar_DZ") as Locale?
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let outputDate = formatter.string(from: date as Date)
            
            return outputDate
        
    }
}

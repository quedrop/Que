//
//  Schedule.swift
//
//  Created by C100-104 on 08/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class Schedule: NSObject, NSCoding,JSONable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kScheduleScheduleIdKey: String = "schedule_id"
    private let kScheduleWeekdayKey: String = "weekday"
    private let kScheduleOpeningTimeKey: String = "opening_time"
    private let kScheduleClosingTimeKey: String = "closing_time"
    private let kScheduleIsClosedKey: String = "is_closed"
    
    // MARK: Properties
    public var scheduleId: Int?
    public var weekday: String?
    public var openingTime: String?
    public var closingTime: String?
    public var isClosed: Int?
    
    // MARK: SwiftyJSON Initalizers
    /**
     Initates the instance based on the object
     - parameter object: The object of either Dictionary or Array kind that was passed.
     - returns: An initalized instance of the class.
     */
    
    public override init() {
        super.init()
    }
    convenience public init(object: Any) {
        self.init(json: JSON(object))
    }
    
    /**
     Initates the instance based on the JSON that was passed.
     - parameter json: JSON object from SwiftyJSON.
     - returns: An initalized instance of the class.
     */
    required public init(json: JSON) {
        scheduleId = json[kScheduleScheduleIdKey].int
        weekday = json[kScheduleWeekdayKey].string
        openingTime = json[kScheduleOpeningTimeKey].string
        closingTime = json[kScheduleClosingTimeKey].string
        isClosed = json[kScheduleIsClosedKey].int
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = scheduleId { dictionary[kScheduleScheduleIdKey] = value }
        if let value = weekday { dictionary[kScheduleWeekdayKey] = value }
        if let value = openingTime { dictionary[kScheduleOpeningTimeKey] = value }
        if let value = closingTime { dictionary[kScheduleClosingTimeKey] = value }
        if let value = isClosed { dictionary[kScheduleIsClosedKey] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.scheduleId = aDecoder.decodeObject(forKey: kScheduleScheduleIdKey) as? Int
        self.weekday = aDecoder.decodeObject(forKey: kScheduleWeekdayKey) as? String
        self.openingTime = aDecoder.decodeObject(forKey: kScheduleOpeningTimeKey) as? String
        self.closingTime = aDecoder.decodeObject(forKey: kScheduleClosingTimeKey) as? String
        self.isClosed = aDecoder.decodeObject(forKey: kScheduleIsClosedKey) as? Int
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(scheduleId, forKey: kScheduleScheduleIdKey)
        aCoder.encode(weekday, forKey: kScheduleWeekdayKey)
        aCoder.encode(openingTime, forKey: kScheduleOpeningTimeKey)
        aCoder.encode(closingTime, forKey: kScheduleClosingTimeKey)
        aCoder.encode(isClosed, forKey: kScheduleIsClosedKey)
    }
    
}

//
//  CDMessages+CoreDataProperties.swift
//  
//
//  Created by C100-174 on 05/05/20.
//
//

import Foundation
import CoreData


extension CDMessages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMessages> {
        return NSFetchRequest<CDMessages>(entityName: "CDMessages")
    }

    @NSManaged public var createdDate: Date?
    @NSManaged public var message: String?
    @NSManaged public var messageId: Int16
    @NSManaged public var messageStatus: Int16
    @NSManaged public var modifiedDate: Date?
    @NSManaged public var receiverId: Int16
    @NSManaged public var senderId: Int16
    @NSManaged public var orderId: Int16

}

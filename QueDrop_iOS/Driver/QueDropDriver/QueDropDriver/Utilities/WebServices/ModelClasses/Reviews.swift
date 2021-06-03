//
//  Reviews.swift
//
//  Created by C100-104 on 14/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class Reviews: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kReviewsReviewKey: String = "review"
  private let kReviewsOrderIdKey: String = "order_id"
  private let kReviewsLastNameKey: String = "last_name"
  private let kReviewsFirstNameKey: String = "first_name"
  private let kReviewsCreatedAtKey: String = "created_at"
  private let kReviewsReviewIdKey: String = "review_id"
  private let kReviewsRatingKey: String = "rating"
  private let kReviewsUserIdKey: String = "user_id"
  private let kReviewsUserNameKey: String = "user_name"
  private let kReviewsUserImageKey: String = "user_image"

  // MARK: Properties
  public var review: String?
  public var orderId: Int?
  public var lastName: String?
  public var firstName: String?
  public var createdAt: String?
  public var reviewId: Int?
  public var rating: Float?
  public var userId: Int?
  public var userName: String?
  public var userImage: String?

  // MARK: SwiftyJSON Initalizers
  /**
   Initates the instance based on the object
   - parameter object: The object of either Dictionary or Array kind that was passed.
   - returns: An initalized instance of the class.
  */
  convenience public init(object: Any) {
    self.init(json: JSON(object))
  }

  /**
   Initates the instance based on the JSON that was passed.
   - parameter json: JSON object from SwiftyJSON.
   - returns: An initalized instance of the class.
  */
  required public init(json: JSON) {
    review = json[kReviewsReviewKey].string
    orderId = json[kReviewsOrderIdKey].int
    lastName = json[kReviewsLastNameKey].string
    firstName = json[kReviewsFirstNameKey].string
    createdAt = json[kReviewsCreatedAtKey].string
    reviewId = json[kReviewsReviewIdKey].int
    rating = json[kReviewsRatingKey].float
    userId = json[kReviewsUserIdKey].int
    userName = json[kReviewsUserNameKey].string
    userImage = json[kReviewsUserImageKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = review { dictionary[kReviewsReviewKey] = value }
    if let value = orderId { dictionary[kReviewsOrderIdKey] = value }
    if let value = lastName { dictionary[kReviewsLastNameKey] = value }
    if let value = firstName { dictionary[kReviewsFirstNameKey] = value }
    if let value = createdAt { dictionary[kReviewsCreatedAtKey] = value }
    if let value = reviewId { dictionary[kReviewsReviewIdKey] = value }
    if let value = rating { dictionary[kReviewsRatingKey] = value }
    if let value = userId { dictionary[kReviewsUserIdKey] = value }
    if let value = userName { dictionary[kReviewsUserNameKey] = value }
    if let value = userImage { dictionary[kReviewsUserImageKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.review = aDecoder.decodeObject(forKey: kReviewsReviewKey) as? String
    self.orderId = aDecoder.decodeObject(forKey: kReviewsOrderIdKey) as? Int
    self.lastName = aDecoder.decodeObject(forKey: kReviewsLastNameKey) as? String
    self.firstName = aDecoder.decodeObject(forKey: kReviewsFirstNameKey) as? String
    self.createdAt = aDecoder.decodeObject(forKey: kReviewsCreatedAtKey) as? String
    self.reviewId = aDecoder.decodeObject(forKey: kReviewsReviewIdKey) as? Int
    self.rating = aDecoder.decodeObject(forKey: kReviewsRatingKey) as? Float
    self.userId = aDecoder.decodeObject(forKey: kReviewsUserIdKey) as? Int
    self.userName = aDecoder.decodeObject(forKey: kReviewsUserNameKey) as? String
    self.userImage = aDecoder.decodeObject(forKey: kReviewsUserImageKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(review, forKey: kReviewsReviewKey)
    aCoder.encode(orderId, forKey: kReviewsOrderIdKey)
    aCoder.encode(lastName, forKey: kReviewsLastNameKey)
    aCoder.encode(firstName, forKey: kReviewsFirstNameKey)
    aCoder.encode(createdAt, forKey: kReviewsCreatedAtKey)
    aCoder.encode(reviewId, forKey: kReviewsReviewIdKey)
    aCoder.encode(rating, forKey: kReviewsRatingKey)
    aCoder.encode(userId, forKey: kReviewsUserIdKey)
    aCoder.encode(userName, forKey: kReviewsUserNameKey)
    aCoder.encode(userImage, forKey: kReviewsUserImageKey)
  }

}

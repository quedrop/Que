//
//  DriverDetail.swift
//
//  Created by C100-174 on 15/04/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class DriverDetail: NSObject, NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let licencePhoto = "licence_photo"
    static let driverPhoto = "driver_photo"
    static let registrationProof = "registration_proof"
    static let identityId = "identity_id"
    static let userId = "user_id"
    static let vehicleType = "vehicle_type"
    static let numberPlate = "number_plate"
  }

  // MARK: Properties
  public var licencePhoto: String?
  public var driverPhoto: String?
  public var registrationProof: String?
  public var identityId: Int?
  public var userId: Int?
  public var vehicleType: String?
  public var numberPlate: String?

  // MARK: SwiftyJSON Initializers
  /// Initiates the instance based on the object.
  ///
  /// - parameter object: The object of either Dictionary or Array kind that was passed.
  /// - returns: An initialized instance of the class.
  public convenience init(object: Any) {
    self.init(json: JSON(object))
  }

  /// Initiates the instance based on the JSON that was passed.
  ///
  /// - parameter json: JSON object from SwiftyJSON.
  public required init(json: JSON) {
    licencePhoto = json[SerializationKeys.licencePhoto].string
    driverPhoto = json[SerializationKeys.driverPhoto].string
    registrationProof = json[SerializationKeys.registrationProof].string
    identityId = json[SerializationKeys.identityId].int
    userId = json[SerializationKeys.userId].int
    vehicleType = json[SerializationKeys.vehicleType].string
    numberPlate = json[SerializationKeys.numberPlate].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = licencePhoto { dictionary[SerializationKeys.licencePhoto] = value }
    if let value = driverPhoto { dictionary[SerializationKeys.driverPhoto] = value }
    if let value = registrationProof { dictionary[SerializationKeys.registrationProof] = value }
    if let value = identityId { dictionary[SerializationKeys.identityId] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = vehicleType { dictionary[SerializationKeys.vehicleType] = value }
    if let value = numberPlate { dictionary[SerializationKeys.numberPlate] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.licencePhoto = aDecoder.decodeObject(forKey: SerializationKeys.licencePhoto) as? String
    self.driverPhoto = aDecoder.decodeObject(forKey: SerializationKeys.driverPhoto) as? String
    self.registrationProof = aDecoder.decodeObject(forKey: SerializationKeys.registrationProof) as? String
    self.identityId = aDecoder.decodeObject(forKey: SerializationKeys.identityId) as? Int
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? Int
    self.vehicleType = aDecoder.decodeObject(forKey: SerializationKeys.vehicleType) as? String
    self.numberPlate = aDecoder.decodeObject(forKey: SerializationKeys.numberPlate) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(licencePhoto, forKey: SerializationKeys.licencePhoto)
    aCoder.encode(driverPhoto, forKey: SerializationKeys.driverPhoto)
    aCoder.encode(registrationProof, forKey: SerializationKeys.registrationProof)
    aCoder.encode(identityId, forKey: SerializationKeys.identityId)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(vehicleType, forKey: SerializationKeys.vehicleType)
    aCoder.encode(numberPlate, forKey: SerializationKeys.numberPlate)
  }

}

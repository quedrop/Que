//
//  SliderImages.swift
//
//  Created by C100-104 on 08/02/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class SliderImages: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kSliderImagesSliderImageIdKey: String = "slider_image_id"
  private let kSliderImagesSliderImageKey: String = "slider_image"

  // MARK: Properties
  public var sliderImageId: Int?
  public var sliderImage: String?

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
    sliderImageId = json[kSliderImagesSliderImageIdKey].int
    sliderImage = json[kSliderImagesSliderImageKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = sliderImageId { dictionary[kSliderImagesSliderImageIdKey] = value }
    if let value = sliderImage { dictionary[kSliderImagesSliderImageKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.sliderImageId = aDecoder.decodeObject(forKey: kSliderImagesSliderImageIdKey) as? Int
    self.sliderImage = aDecoder.decodeObject(forKey: kSliderImagesSliderImageKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(sliderImageId, forKey: kSliderImagesSliderImageIdKey)
    aCoder.encode(sliderImage, forKey: kSliderImagesSliderImageKey)
  }

}

//
//  CartTermNotes.swift
//
//  Created by C100-104 on 24/03/20
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class CartTermNotes: NSObject, NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kCartTermNotesTermNoteIdKey: String = "term_note_id"
  private let kCartTermNotesNoteTypeKey: String = "note_type"
  private let kCartTermNotesNoteKey: String = "note"

  // MARK: Properties
  public var termNoteId: Int?
  public var noteType: String?
  public var note: String?

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
    termNoteId = json[kCartTermNotesTermNoteIdKey].int
    noteType = json[kCartTermNotesNoteTypeKey].string
    note = json[kCartTermNotesNoteKey].string
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = termNoteId { dictionary[kCartTermNotesTermNoteIdKey] = value }
    if let value = noteType { dictionary[kCartTermNotesNoteTypeKey] = value }
    if let value = note { dictionary[kCartTermNotesNoteKey] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.termNoteId = aDecoder.decodeObject(forKey: kCartTermNotesTermNoteIdKey) as? Int
    self.noteType = aDecoder.decodeObject(forKey: kCartTermNotesNoteTypeKey) as? String
    self.note = aDecoder.decodeObject(forKey: kCartTermNotesNoteKey) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(termNoteId, forKey: kCartTermNotesTermNoteIdKey)
    aCoder.encode(noteType, forKey: kCartTermNotesNoteTypeKey)
    aCoder.encode(note, forKey: kCartTermNotesNoteKey)
  }

}

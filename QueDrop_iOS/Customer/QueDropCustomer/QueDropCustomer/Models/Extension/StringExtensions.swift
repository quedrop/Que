//
//  String.swift
//  Ketch
//
//  Created by C110 on 15/12/17.
//  Copyright © 2017 C110. All rights reserved.
//

import UIKit

extension String: Error {}

extension String {
    
//    func fromBase64() -> String? {
//        guard let data = Data(base64Encoded: self) else {
//            return ""
//        }
//        
//        return String(data: data, encoding: .utf8)
//    }
//    
//    func toBase64() -> String {
//        return Data(self.utf8).base64EncodedString()
//    }
//    
    
    func charAt(at: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy: at)
        return self[charIndex]
    }
    
    func isBegin(with string:NSString) -> Bool {
        return self.hasPrefix(string as String) ? true : false
    }
    
    func isEnd(With string : NSString) -> Bool {
        return self.hasSuffix(string as String) ? true : false
    }
    
    /**
     Check email
     */
    public var isEmail: Bool {
        let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let firstMatch = dataDetector?.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: 0, length: length))
        return (firstMatch?.range.location != NSNotFound && firstMatch?.url?.scheme == "mailto")
    }
    public var length: Int {
        return self.count
    }
    
    /**
     phone number
     */
    func isValidPhoneNumber() -> Bool {
        let regex : NSString = "[235689][0-9]{6}([0-9]{3})?"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return predicate.evaluate(with: self)
    }
    
    /**
     url
     */
    func getUserImageURL() -> URL {
      
         if isValidUrl() {
           return URL(string: self)!
         }else {
           return URL(string: "\(URL_USER_IMAGES)\(self)")!
         }
    
     }
    func isValidUrl() -> Bool {
      let regex : NSString = "^((http|https)?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$" //"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
      let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
      return predicate.evaluate(with: self)
    }
    
//    func substring(_ startIndex: Int, length: Int) -> String {
//        let start = self.characters.index(self.startIndex, offsetBy: startIndex)
//        let end = self.characters.index(self.startIndex, offsetBy: startIndex + length)
//        return String(self[start..<end])
//    }
}

//Attributed text with Bullete


public func add(stringList: [String],
         font: UIFont,
		 bulletfont: UIFont = UIFont(name: "Montserrat-Regular", size: 7.0)!,
         bullet: String = "⬤",
         indentation: CGFloat = 20,
         lineSpacing: CGFloat = 2,
         paragraphSpacing: CGFloat = 12,
         textColor: UIColor = .gray,
         bulletColor: UIColor = .gray,
         forSingleNote : Bool = false) -> NSAttributedString {

	let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
	let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: bulletfont, NSAttributedString.Key.foregroundColor: bulletColor]

    let paragraphStyle = NSMutableParagraphStyle()
    let nonOptions = [NSTextTab.OptionKey: Any]()
    paragraphStyle.tabStops = [
        NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
    paragraphStyle.defaultTabInterval = indentation
    //paragraphStyle.firstLineHeadIndent = 0
    //paragraphStyle.headIndent = 20
    //paragraphStyle.tailIndent = 1
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.paragraphSpacing = paragraphSpacing
    paragraphStyle.headIndent = indentation

    let bulletList = NSMutableAttributedString()
    for string in stringList {
        let formattedString = "\(bullet)\t\(string)\n"
        let attributedString = NSMutableAttributedString(string: formattedString)

        attributedString.addAttributes(
			[NSAttributedString.Key.paragraphStyle : paragraphStyle],
            range: NSMakeRange(0, attributedString.length))

        attributedString.addAttributes(
            textAttributes,
            range: NSMakeRange(0, attributedString.length))

        let string:NSString = NSString(string: formattedString)
        let rangeForBullet:NSRange = string.range(of: bullet)
        attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
        bulletList.append(attributedString)
    }
    if forSingleNote
    {
        let noteStr = NSMutableAttributedString(string: "Note\n\n")
        noteStr.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_SEMIBOLD, size: 17.0)!, range: NSMakeRange(0, noteStr.length))
        noteStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, noteStr.length))
        noteStr.append(bulletList)
        return noteStr
    }
    else
    {
        return bulletList
    }
}

public func addDriverNote(stringList: [String],
         font: UIFont,
         bulletfont: UIFont = UIFont(name: "Montserrat-Regular", size: 7.0)!,
         bullet: String = "⬤",
         indentation: CGFloat = 20,
         lineSpacing: CGFloat = 2,
         paragraphSpacing: CGFloat = 12,
         textColor: UIColor = .gray,
         bulletColor: UIColor = .gray,
         forSingleNote : Bool = false) -> NSAttributedString {

    let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
    let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: bulletfont, NSAttributedString.Key.foregroundColor: bulletColor]

    let paragraphStyle = NSMutableParagraphStyle()
    let nonOptions = [NSTextTab.OptionKey: Any]()
    paragraphStyle.tabStops = [
        NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
    paragraphStyle.defaultTabInterval = indentation
    //paragraphStyle.firstLineHeadIndent = 0
    //paragraphStyle.headIndent = 20
    //paragraphStyle.tailIndent = 1
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.paragraphSpacing = paragraphSpacing
    paragraphStyle.headIndent = indentation

    let bulletList = NSMutableAttributedString()
    for string in stringList {
        let formattedString = "\(bullet)\t\(string)\n"
        let attributedString = NSMutableAttributedString(string: formattedString)

        attributedString.addAttributes(
            [NSAttributedString.Key.paragraphStyle : paragraphStyle],
            range: NSMakeRange(0, attributedString.length))

        attributedString.addAttributes(
            textAttributes,
            range: NSMakeRange(0, attributedString.length))

        let string:NSString = NSString(string: formattedString)
        let rangeForBullet:NSRange = string.range(of: bullet)
        attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
        bulletList.append(attributedString)
    }
    if forSingleNote
    {
        let noteStr = NSMutableAttributedString(string: "Driver Note\n\n")
        noteStr.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_SEMIBOLD, size: 17.0)!, range: NSMakeRange(0, noteStr.length))
        noteStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, noteStr.length))
        noteStr.append(bulletList)
        return noteStr
    }
    else
    {
        return bulletList
    }
}

/*
 Will generate radom string based on length
 */
public func randomString(length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    var randomString = ""
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    return randomString
}

public func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}
extension Date
{

  func dateAt(hours: Int, minutes: Int) -> Date
  {
    let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!

    //get the month/day/year componentsfor today's date.


    var date_components = calendar.components(
      [NSCalendar.Unit.year,
       NSCalendar.Unit.month,
       NSCalendar.Unit.day],
      from: self)

    //Create an NSDate for the specified time today.
    date_components.hour = hours
    date_components.minute = minutes
    date_components.second = 0

    let newDate = calendar.date(from: date_components)!
    return newDate
  }
}

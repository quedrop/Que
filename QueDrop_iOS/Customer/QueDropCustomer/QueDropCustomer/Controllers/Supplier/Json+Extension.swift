//
//  Json+Extension.swift
//  GoferDelivery
//
//  Created by C100-104 on 28/01/20.
//  Copyright © 2019 C100-107. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import UIKit
extension JSON {
    func to<T>(type: T?) -> Any? {
        if let baseObj = type as? JSONable.Type {
            if self.type == .array {
                var arrObject: [Any] = []
                for obj in self.arrayValue {
					let object = baseObj.init(json: obj)
                    arrObject.append(object!)
                }
                return arrObject
            } else {
				let object = baseObj.init(json: self)
                return object!
            }
        }
        return nil
    }
}
protocol JSONable {
    init?(json: JSON)
}

extension JSONable {
    func toDict() -> [String:Any] {
        var dict = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        return dict
    }
}


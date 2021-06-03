//
//  Optional+Extensions.swift
//  TKontak
//
//  Created by C211 on 14/07/18.
//  Copyright © 2018 Harjeet Singh. All rights reserved.
//

import Foundation

extension Optional {
    
    func asString() -> String {
        switch self {
        case .some(let value):
            return String(describing: value)
        case _:
            return ""
        }
    }
    
    func asInt() -> Int {
        switch self {
        case .some(let value):
            return value as! Int
        case _:
            return 0
        }
    }
    
    func asFloat() -> Float {
        switch self {
        case .some(let value):
            return Float(String(describing: value))!
        case _:
            return 0.0
        }
    }
}

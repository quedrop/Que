//
//  EnumTypes.swift
//  QueDrop
//
//  Created by C100-105 on 01/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import Foundation

enum Enum_ItemEditingType: Int {
    case add = 0
    case edit
    case show
}

enum Enum_OrderType: Int {
    case all = 0
    case current
    case past
}

enum Enum_NotificationType: Int {
    case Order_Request = 1
    case Order_Accept
    case Order_Reject
    case Order_Request_Timeout
    case Recurring_Order_Placed
    case Rating
    case Near_By_Place
    case Driver_verification
    case Order_receipt
    case order_dispatch
    case order_delivered
    case order_cancelled
    case chat
    case driverWeeklyPayment
    case supplierWeeklyPayment
    case manualStorePayment
    case productVerification
    case recurringOrderAccepted
    case storeVerification
    case unKnownType
}

enum Enum_BankAccountType: String {
    case Saving
    case Current
}

enum screens{
    case login
    case signUp
    case home
    case notification
    case cart
    case currentOrder
    case profile
    case editProfile
    case settings
}

//
//  Supplier+WebService-Prefix.swift
//  QueDrop
//
//  Created by C100-105 on 30/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import Foundation

typealias SucessCallback<T> = (_ item: T) -> Void where T: JSONable
typealias SucessCallbackList<T> = (_ item: [T], _ isLoadMore: Bool) -> Void where T: JSONable
typealias ErrorCallback = (_ isDone: Bool, _ message: String) -> Void

let URL_BANKS_LOGO = "\(MEDIA_URL)BankLogo/"

let APIGetSupplierCategories = "\(WEBSERVICE_PATH)GetSupplierCategories"
let APIAddSupplierCategory = "\(WEBSERVICE_PATH)AddSupplierCategory"
let APIEditSupplierCategory = "\(WEBSERVICE_PATH)EditSupplierCategory"
let APIDeleteSupplierCategory = "\(WEBSERVICE_PATH)DeleteSupplierCategory"
let APIGetSupplierFreshProduceCategories = "\(WEBSERVICE_PATH)GetSupplierFreshProduceCategory"
let APIGetFreshProducedCategory = "\(WEBSERVICE_PATH)GetFreshProduces"
let APIAddFreshProducedCategory = "\(WEBSERVICE_PATH)AddFreshProduceCategory"

let APIGetSupplierProduct = "\(WEBSERVICE_PATH)GetSupplierProduct"
let APIAddSupplierProduct = "\(WEBSERVICE_PATH)AddSupplierProduct"
let APIEditSupplierProduct = "\(WEBSERVICE_PATH)EditSupplierProduct"
let APIDeleteSupplierProduct = "\(WEBSERVICE_PATH)DeleteSupplierProduct"
let APISearchSupplierProduct = "\(WEBSERVICE_PATH)SearchSupplierProduct"

let APIGetSupplierOrders = "\(WEBSERVICE_PATH)GetSupplierOrders"

let APIGetAllProductOffers = "\(WEBSERVICE_PATH)GetAllProductOffers"
let APIDeleteProductOffer = "\(WEBSERVICE_PATH)DeleteProductOffer"
let APIEditProductOffer = "\(WEBSERVICE_PATH)EditProductOffer"
let APIAddProductOffer = "\(WEBSERVICE_PATH)AddProductOffer"

//GetNotifications :- Common api for customer and supplier
let APIGetNotifications = "\(WEBSERVICE_PATH)GetNotifications"
//let APIGetNotifications = "\(WEBSERVICE_PATH)GetSupplierNotification"

let APIGetSingleSupplierOrderDetail = "\(WEBSERVICE_PATH)GetSingleSupplierOrderDetail"

let APIEditProfile = "\(WEBSERVICE_PATH)EditProfile"
let APIChangePassword = "\(WEBSERVICE_PATH)ChangePassword"

let APIEditStoreDetails = "\(WEBSERVICE_PATH)EditStoreDetails"
let APIGetBankDetails = "\(WEBSERVICE_PATH)GetBankDetails"
let APIAddBankDetail = "\(WEBSERVICE_PATH)AddBankDetail"
let APIEditBankDetail = "\(WEBSERVICE_PATH)EditBankDetail"
let APIDeleteBankDetail = "\(WEBSERVICE_PATH)DeleteBankDetail"
let APIGetBankNameList = "\(WEBSERVICE_PATH)GetBankNameList"
let API_GET_WEEKLY_EARNING = "\(WEBSERVICE_PATH)GetSupplierWeekleyPaymentDetail"
let API_CREATE_STORE = "\(WEBSERVICE_PATH)CreateSupplierStore"

let APISocketSupplierJoin = "supplier_join_socket"
let APISocketSupplierChangeAcknowldge = "supplier_change_acknowledge"
let APISocketWeeklyPayment = "supplier_weekly_payment_acknowledge"

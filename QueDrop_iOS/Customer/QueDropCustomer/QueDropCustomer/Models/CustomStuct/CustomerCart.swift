//
//  CustomerCart.swift
//  QueDrop
//
//  Created by C100-104 on 14/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import Foundation

struct CustomerTempCart {
	var storeId : Int?							//StoreId
	var store : StoreDetail?  					//StoresObj
	var productId : Int?						//ProductId
	var product : Products? 					//ProductObj
	var productQty : Int = 1
	var productAddons : [[Int : Addons]] = []	//ProductId : AddonsObj
	var productAddonsIds : [Int] = [] // AddonsId
	var ItemFinalAmmount : Float  = 0
	var selectedOptions : ProductOption?
}
struct CustomCart{
	var CartItemsAry : [CustomerTempCart] = []
}
struct CustomerFinalCart {
	var storeId : [Int]?					//StoreId
	var stores : [StoreDetail]?  			//StoresObj
	var productIds : [[Int:Int]]?				//StoreId : ProductId
	var products : [Int: Products]? 		//StoreId : ProductObj
	var productAddons : [Int : Addons]?		//ProductId : AddonsObj
}


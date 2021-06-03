//
//  SocketIOHandler.swift
//  QueDrop
//
//  Created by C100-104 on 03/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import Foundation
import SocketIO
import SwiftyJSON

@objc protocol SocketIOHandlerDelegate {
    func connectionStatus(status:SocketIOStatus)
    @objc optional func newMessage(array:[CDMessages])
    @objc optional func InitialMessage(array:[CDMessages])
    @objc optional func loadMoreMessage(array:[CDMessages])
    @objc optional func reloadMessages()
}

class SocketIOManager: NSObject{
       
	static let shared = SocketIOManager()
	var socket: SocketIOClient!

    // defaultNamespaceSocket and swiftSocket both share a single connection to the server
    let manager = SocketManager(socketURL: URL(string: SOCKET_SERVER_PATH)!, config: [.log(true), .compress])

    override init() {
        super.init()
        socket = manager.defaultSocket
	}
	
	func connectSocket() {
		//let token = UserDefaults.standard.getAccessToken()

		self.manager.config = SocketIOClientConfiguration(
			arrayLiteral: .connectParams(["user_id": USER_ID]), .secure(true)
			)
			socket.connect()
	}
	func receiveMsg() {
		socket.on("new message here") { (dataArray, ack) in

			print(dataArray.count)

		}
	}
}


class SocketIOHandler: NSObject {
    
    var delegate:SocketIOHandlerDelegate?
	   
	   var manager: SocketManager?
	   var socket: SocketIOClient?
	   var isHandlerAdded:Bool = false
	   var isJoinSocket:Bool = false
    
    override init() {
        super.init()
        connectWithSocket()
    }
    
    //MARK:- ConnectWithSocket
	
    func connectWithSocket() {
        if manager==nil && socket == nil {
            manager = SocketManager(socketURL: URL(string: SOCKET_SERVER_PATH)!, config: [.log(true), .compress])
            socket = manager?.defaultSocket
            connectSocketWithStatus()
        }else if socket?.status == .connected {
            self.callFunctionsAfterConnection()
        }
    }
    
    func connectSocketWithStatus(){
        
        socket?.on(clientEvent: .connect) {data, ack in
            
        }
        
        socket?.on(clientEvent: .statusChange) {data, ack in
            let val = data.first as! SocketIOStatus
            self.delegate?.connectionStatus(status: val)
            switch val {
            case .connected:
                self.callFunctionsAfterConnection()
                break
                
            default:
                break
            }
        }
        
        socket?.connect()
        print(socket?.status)
    }
    
    func callFunctionsAfterConnection()  {
        print("Connected")
        if UserType == .Supplier {
            supplierJoinSocket()
        } else {
            //    if(!(isGuest)  && !isJoinSocket){
            let dict:NSMutableDictionary = NSMutableDictionary()
            dict.setValue(USER_OBJ?.userId, forKey: "user_id")
            joinSocketWithData(data: dict)
            //    }
            //    AddHandlers()
            
        }
    }
    
	func background(){
      isJoinSocket = false
        isHandlerAdded = false
        APP_DELEGATE.socketHandlersAdded = false
	}
	func foreground(){
	  callFunctionsAfterConnection()
    }
    
    func disconnectSocket() {
        APP_DELEGATE.socketHandlersAdded = false
        socket?.removeAllHandlers()
        
        socket?.disconnect()
        
        manager?.removeSocket(socket!)
    }
	//MARK:- Join Socket With User
	  func joinSocketWithData(data:NSDictionary) {
		  /*
		   In order to join the socket
		   */
		  
		//   if(!isGuest && !isJoinSocket) {
			   print("USER JOIN SOCKET")
			   socket?.emit(APISocketJoin_Socket, data)
			   isJoinSocket = true
			   isHandlerAdded = true
			if !APP_DELEGATE.socketHandlersAdded{
                
				   APP_DELEGATE.socketHandlersAdded = true
				   AddHandlers()
			  }
		//   }
	  }
      //MARK:- DISCONNECT SOCKET MANUALLY
    func disconenctSocketManually(id : Int) {
          let dic = ["user_id" : id]
          socket?.emitWithAck(APISOCKETDisconnectManually, dic).timingOut(after: 0, callback: { (result) in
              if (result[0] as! [String : Any])["status"] as! Bool  {
                  print("Disconnected")
              }
          })
      }
	//MARK:- Add Handlers
	func AddHandlers()
	{
		//EVENT FOR UPDATE ORDER STATUS
		socket?.on(APISocketOrderStatusChanged, callback: { (data, ack) in
			if let dic = data[0] as? NSDictionary {
				//POST NOTIFICATION
				
				//if dic["order_id"] as? Int == arrCurrentOrder[0].orderId {
				/*	if let currStatus = dic["order_"] as? String
				{
				
				}
				*/
				//}
                
                var d = [String : Any]()
                d["order_id"] = "\(dic["order_id"] ?? 0)"
                d["driver_id"] = "\(dic["driver_id"] ?? 0)"
                d["order_status"] = "\(dic["order_status"] ?? "")"
                
                APP_DELEGATE.scheduleNotification(notificationType: .orderStatusUpdate,userInfo: d )//"Order Status Updated.")
				postNotification(withName: notificationCenterKeys.orderStatus.rawValue, userInfo: dic as! [AnyHashable : Any])
			}
		})
		socket?.on(APISocketOrderAccepted, callback: { (data, ack) in
			if let dic = data[0] as? NSDictionary {
				//POST NOTIFICATION
                var d = [String : Any]()
               d["order_id"] = "\(dic["order_id"] ?? 0)"
               d["driver_id"] = "\(dic["driver_id"] ?? 0)"
               d["customer_id"] = "\(dic["customer_id"] ?? 0)"
                
                APP_DELEGATE.scheduleNotification(notificationType: .orderAccepted,userInfo: d)
				postNotification(withName: notificationCenterKeys.orderAccepted.rawValue, userInfo: dic as! [AnyHashable : Any])
			}
		})
        socket?.on(APISocketDriverLocationChanged, callback: { (data, ack) in
            if let dic = data[0] as? NSDictionary {
                //POST NOTIFICATION
                //APP_DELEGATE.scheduleNotification(notificationType: .driverLocationUpdated)
                postNotification(withName: notificationCenterKeys.driverLocationChanged.rawValue, userInfo: dic as! [AnyHashable : Any])
            }
        })
		/*socket?.on(APISocketCancelOrder, callback: { (data, ack) in
			if let dic = data[0] as? NSDictionary {
				//POST NOTIFICATION
				APP_DELEGATE.scheduleNotification(notificationType: .orderRejected) //"Order cancelled.")
				postNotification(withName: notificationCenterKeys.orderAccepted.rawValue, userInfo: dic as! [AnyHashable : Any])
			}
		})*/
        
       //EVENT FOR RECEIVE NEW CHAT MESSAGE
         socket?.on(APISOCKETGetNewMessage, callback: { data, ack in
           let array:NSArray = (data[0] as! NSDictionary).value(forKey: "chat_message") as! NSArray
           let arrayObjMessage = CoreDataAdaptor.sharedDataAdaptor.saveMessage(array: array)
           if arrayObjMessage.count != 0 {
               self.delegate?.InitialMessage?(array: arrayObjMessage)
           }
             
             var isGenerateLocalNotification : Bool = false
             if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
                 if visibleViewCtrl.isKind(of: CustomerChatVC.self) {
                     if let chatvc = visibleViewCtrl as? CustomerChatVC {
                         if Int16(chatvc.orderId) == arrayObjMessage.first?.orderId  && Int16(chatvc.sender_id) == arrayObjMessage.first?.receiverId  && Int16(chatvc.receiver_id) == arrayObjMessage.first?.senderId {
                             isGenerateLocalNotification = false
                         } else {
                             isGenerateLocalNotification = true
                         }
                     }
                 } else {
                     isGenerateLocalNotification = true
                 }
             }
             
             if isGenerateLocalNotification {
                 if arrayObjMessage.count != 0 {
                     let title = "New Meesage In Order #\(arrayObjMessage.first?.orderId ?? 0)"
                         let body = arrayObjMessage.first?.message
                         
                     var dic = [String : Any]()
                     dic["sender_id"] = "\(arrayObjMessage.first?.senderId ?? 0)"
                     dic["receiver_id"] = "\(arrayObjMessage.first?.receiverId ?? 0)"
                     dic["order_id"] = "\(arrayObjMessage.first?.orderId ?? 0)"
                     dic["message"] = "\(arrayObjMessage.first?.message ?? "")"
                     dic["is_delete"] = "\(arrayObjMessage.first?.isDeleted ?? false)"
                     dic["modified_date"] = "\(arrayObjMessage.first?.modifiedDate ?? Date())"
                     dic["id"] = "\(arrayObjMessage.first?.messageId ?? 0)"
                     dic["created_date"] = "\(arrayObjMessage.first?.createdDate ?? Date())"
                     
                     generateChatLocalNotification(title: title, body: body!, userInfo: /*array[0] as! [String:Any]*/ dic, identifier:"ChatNotification")
                 }
             }
        })
        
        //EVENT WHEN PAYMENTS CONFIRM FROM ADMIN PANEL
       socket?.on(APISocketWeeklyPayment, callback: { data, ack in
           if let dic = data[0] as? NSDictionary {
               if dic["status"] as! Int == 1 {
                   //GENERATE LOCAL NOTIFICATION
                   var d = [String : Any]()
                   d["store_id"] = dic["store_id"]
                   d["message"] = dic["message"]
                   d["user_id"] = dic["user_id"]
                   d["title"] = dic["title"]
                   d["week_start_date"] = dic["week_start_date"]
                   d["week_end_date"] = dic["week_end_date"]
                   d["weekly_payment_id"] = dic["weekly_payment_id"]
                   
                   generateChatLocalNotification(title: dic["title"] as! String, body: dic["message"] as! String, userInfo: d , identifier: "WeeklyPaymentNotification")
                   postNotification(withName: ncNOTIFICATION_WEEKLY_PAYMENT, userInfo: d)
               }
           }
           
       })
    
        //EVENT WHEN ADMIN VERIFY/UNVERIFY STORE
        socket?.on(APISocketStoreVerificationACK, callback: { data, ack in
            if let dic = data[0] as? NSDictionary {
                if dic["status"] as! Int == 1 {
                    //GENERATE LOCAL NOTIFICATION
                    var d = [String : Any]()
                    d["store_id"] = "\(dic["store_id"] ?? 0)"
                    d["message"] = "\(dic["message"] ?? "")"
                    d["user_id"] = "\(dic["user_id"] ?? 0)"
                    d["title"] = "\(dic["title"] ?? "")"
                    d["is_verfied"] = "\(dic["is_verfied"] ?? 0)"
                    
                    generateChatLocalNotification(title: dic["title"] as! String, body: dic["message"] as! String, userInfo: d , identifier: "StoreVerificationNotification")
                    postNotification(withName: ncNOTIFICATION_STORE_VERIFICATION, userInfo: d)
                }
            }
            
        })
	}
    
	
    func StartDriverLocationUpdate(dic : [String : Any])
    {
        socket?.emitWithAck(APISocketStartDriverLocationUpdate, dic).timingOut(after: 0, callback: { (result) in
                   print(result)
                    //NotificationCenter.default.post(name: NSNotification.Name("NewOrder"), object: nil, userInfo: result[0] as? [AnyHashable : Any])
               })
    }
    func StopDriverLocationUpdate(dic : [String : Any])
      {
          socket?.emitWithAck(APISocketStopDriverLocationUpdate, dic).timingOut(after: 0, callback: { (result) in
                     print(result)
                      //NotificationCenter.default.post(name: NSNotification.Name("NewOrder"), object: nil, userInfo: result[0] as? [AnyHashable : Any])
                 })
      }
    func getCartCount(dic : [String : Any], completion:@escaping (Int) -> ())  {
        socket?.emitWithAck(APISOCKETGetCartItemCount, dic).timingOut(after: 0, callback: { (result) in
                   print(result)
                if let data = [result[0] as? NSDictionary][0]{
                        if let status = data["status"] as? Int{
                            if status == 1{
                                let count  = data["total_items"] as! Int
                                BADGE_COUNT = count
                            }
                            else{
                                BADGE_COUNT = 0
                            }
                            completion(BADGE_COUNT)
                    }
                }
            
//                   postNotification(withName: notificationCenterKeys.updateCartBadge.rawValue, userInfo: result[0] as! [AnyHashable : Any])
               })
    }
    func PlaceOrder(dic : [String : Any])  {
        socket?.emitWithAck(APISocketPlaceOrder, dic).timingOut(after: 0, callback: { (result) in
            print(result)
             //NotificationCenter.default.post(name: NSNotification.Name("NewOrder"), object: nil, userInfo: result[0] as? [AnyHashable : Any])
        })
    }

	func CompleteOrder(dic : [String : Any])  {
        socket?.emitWithAck(APISocketCompleteOrder, dic).timingOut(after: 0, callback: { (result) in
            print(result)
             //NotificationCenter.default.post(name: NSNotification.Name("NewOrder"), object: nil, userInfo: result[0] as? [AnyHashable : Any])
        })
    }
    
    func CompleteOrderNew(dic : [String : Any], completion:@escaping (NSDictionary) -> ())  {
        socket?.emitWithAck(APISocketCompleteOrder, dic).timingOut(after: 0, callback: { (result) in
            print(result)
            let dic:NSDictionary = (result[0] as! NSDictionary)
            completion(dic)
             //NotificationCenter.default.post(name: NSNotification.Name("NewOrder"), object: nil, userInfo: result[0] as? [AnyHashable : Any])
        })
    }
    
    func UpdateTimer(dic : [String : Any])  {
        socket?.emitWithAck(APISOCKETGetUpdatedEstimatedTime, dic).timingOut(after: 0, callback: { (result) in
            print(result)
            postNotification(withName: notificationCenterKeys.timerValueUpdated.rawValue, userInfo: dic as [AnyHashable : Any])
        })
    }
    
    //MARK: - Chat Module
    func sendMessage(data:NSDictionary){

        socket?.emitWithAck(APISOCKETSendNewMessage, data).timingOut(after: 0) {data in
            let dic:NSDictionary = (data[0] as! NSDictionary)
            print(dic)
            let arrMessage = dic.value(forKey: "chat_message") as! NSMutableArray
            let dictMessage = arrMessage[0] as! NSMutableDictionary
            let msgId = dictMessage.value(forKey: "id")
            if (CoreDataAdaptor.sharedDataAdaptor.updateMessageID(messageID: "\(msgId!)",createdDate :dictMessage.value(forKey: "created_date") as! String ,modifiedDate : dictMessage.value(forKey: "modified_date") as! String)) {
                print("Yes")
                self.delegate?.reloadMessages?()
            }
        }


    }
    //GET SINGLE USER DETAILS
       func GetSingleUserDetails(userID : Int, completion:@escaping (User) -> ())  {
           let dic = ["user_id" : userID] as [String : Any]
          socket?.emitWithAck(APISOCKETGetUserDetails, dic).timingOut(after: 0, callback: { (result) in
              let data = result[0] as! [String:Any]
              if data["status"] as! Int == 1 {
                   let dicDetail = data["user"] as! NSDictionary
                   let objUser: User = User(json: JSON(dicDetail))
                   completion(objUser)
              }
          })
       }
    func fetchNewMessagesOfSender(data:NSDictionary)  {
        socket?.emitWithAck (APISocketFetchMessages, data).timingOut(after: 0, callback: { data in
              let array:NSArray = (data[0] as! NSDictionary).value(forKey: "chat_message") as! NSArray
              let arrayObjMessage = CoreDataAdaptor.sharedDataAdaptor.saveMessage(array: array)
              if arrayObjMessage.count != 0 {
                    self.delegate?.InitialMessage?(array: arrayObjMessage)
              }  else {
                self.delegate?.reloadMessages?()
            }
        })
       }
    
    func checkNewMessage(data:NSDictionary) {
        socket?.emit(APISOCKETGetNewMessage, data)
    }
    
    //MARK:- GET NEARBY DRIVER FOR CART SCREEN
    func getNearestDrivers(deliveryOption : String, completion:@escaping ([NearbyDrivers], FathestStoreDetails) -> ()) {
        let dic = ["user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0, "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0, "delivery_latitude": defaultAddress?.latitude ?? "0.0", "delivery_longitude" : defaultAddress?.longitude ?? "0.0", "delivery_option" : deliveryOption] as [String : Any]
        socket?.emitWithAck(APISOCKETGetAvailableDrivers, dic).timingOut(after: 0, callback: { (result) in
            let data = result[0] as! [String:Any]
            if data["status"] as! Int == 1 {
                let dicDetail = data["data"] as! [String:Any]
                if let dict = dicDetail["nearby_drivers"], let objSDetail = dicDetail["fathest_store_details"]{
                     let arrDrivers = JSON(dict).to(type: NearbyDrivers.self) as! [NearbyDrivers]
                     let objStoreDetail = JSON(objSDetail).to(type: FathestStoreDetails.self) as! FathestStoreDetails
                    completion(arrDrivers, objStoreDetail)
                }
                 
            }
        })
    }
   
}


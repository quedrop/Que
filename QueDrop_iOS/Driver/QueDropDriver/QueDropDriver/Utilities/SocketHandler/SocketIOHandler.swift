//
//  SocketIOHandler.swift
//  QueDropDeliveryCustomer
//
//  Created by C100-104 on 03/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import Foundation
import SocketIO
import SwiftyJSON
import AudioToolbox

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
            print("SOCKET CONNECTED")
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
        if(getIsUserLoggedIn() /* && !isJoinSocket*/){
            let dict:NSMutableDictionary = NSMutableDictionary()
            dict.setValue(USER_OBJ?.userId, forKey: "user_id")
            joinSocketWithData(data: dict)
        }
    }
    
	func background(){
        isJoinSocket = false
        isHandlerAdded = false
        APP_DELEGATE!.socketHandlersAdded = false
   }
   
   func foreground(){
       callFunctionsAfterConnection()
   }
   
   func disconnectSocket() {
      APP_DELEGATE!.socketHandlersAdded = false
        socket?.removeAllHandlers()
        
        socket?.disconnect()
        
       // manager?.removeSocket(socket!)
   }
   
   //MARK:- Join Socket With User
   func joinSocketWithData(data:NSDictionary) {
       /*
        In order to join the socket
        */
       
        if(getIsUserLoggedIn() /*&& !isJoinSocket*/) {
            print("USER JOIN SOCKET")
            socket?.emit(APISocketJoin_Socket, data)
            isJoinSocket = true
            
           // if !APP_DELEGATE!.socketHandlersAdded{
                APP_DELEGATE!.socketHandlersAdded = true
                addHandlers()
         //  }
        }
        
   }

   //MARK:- DISCONNECT SOCKET MANUALLY
    func disconenctSocketManually() {
        let dic = ["user_id" : USER_OBJ?.userId ?? 0]
        socket?.emitWithAck(APISOCKETDisconnectManually, dic).timingOut(after: 0, callback: { (result) in
            
            if (result[0] as! [String : Any])["status"] as! Bool  {
                print("Disconnected")
            }
        })
    }
   //MARK:- GET DRIVER ONLINE/OFFLINE STATUS
    func getDriverWorkingStatus() {
        let dic = ["user_id" : USER_ID]
        socket?.emitWithAck(APISocketGetDriverStatus, dic).timingOut(after: 0, callback: { (result) in
            
            if (result[0] as! [String : Any])["status"] as! Bool  {
                postNotification(withName: ncNOTIFICATION_SOCKET_DRIVER_STATUS, userInfo: (result[0] as? [AnyHashable : Any])!)
            }
        })
    }
    
    //MARK:- CHANGE DRIVER WORKING STATUS
    func ChangeDriverWorkingStatus(isOnline : Bool) {
        let dic = ["user_id" : USER_ID, "is_online" : isOnline ? 1 : 0]
        socket?.emitWithAck(APISocketChangeDriverStatus, dic).timingOut(after: 0, callback: { (result) in
            if (result[0] as! [String : Any])["status"] as! Bool  {
                postNotification(withName: ncNOTIFICATION_SOCKET_CHANGE_DRIVER_STATUS, userInfo: (result[0] as? [AnyHashable : Any])!)
                print((result[0] as! [String : Any])["message"] as! String)
            } else {
                //ShowToast(message: (result[0] as! [String : Any])["message"] as! String)
            }
            print(result)
        })
    }

    //MARK:- UPDATE DRIVER LOCATION
    func updateDriverLocation() {
        let dic = ["user_id" : USER_ID, "latitude" : "\(CURRENT_LATITUDE)", "longitude" : "\(CURRENT_LONGITUDE)"] as [String : Any]
        socket?.emitWithAck(APISocketUpdateDriverLocation, dic).timingOut(after: 0, callback: { (result) in
        })
    }
    
    //MARK:- FETCH ORDER DETAIL BY ORDER ID
    func fetchOrderDetails(orderId : Int, completion:@escaping (OrderDetail) -> ())  {
        let dic = ["order_id" : orderId]
        socket?.emitWithAck(APISocketGetOrderDetail, dic).timingOut(after: 0, callback: { (result) in
            let data = result[0] as! NSDictionary
            let dicDetail = data["order_detail"] as! NSDictionary
            let objOrderDetail: OrderDetail = OrderDetail(json: JSON(dicDetail))
            completion(objOrderDetail)
        })
    }
    
    //MARK:- JOIN ORDER ROOM
    func joinOrderRoom(orderId : Int) {
        let dic = ["order_id" : orderId]
        socket?.emitWithAck(APISocketJoinOrderRoom, dic).timingOut(after: 0, callback: { (result) in
            //ORDER ROOM JOINED
        })
    }
    
    //MARK:- LEAVE ORDER ROOM
    func leaveOrderRoom(orderId : Int) {
        let dic = ["order_id" : orderId]
        socket?.emitWithAck(APISocketLeaveOrderRoom, dic).timingOut(after: 0, callback: { (result) in
            //ORDER ROOM LEFT
        })
    }
    
    //MARK:- REJECT ORDER REQUEST
    func rejectOrder(orderId : Int, customerId : Int, completion:@escaping (Bool) -> ()) {
        let isaccept : Int = 0
        let dic = ["is_accept" : isaccept, "user_id" : USER_OBJ?.userId! ?? 0, "order_id" : orderId , "customer_id" : customerId, "driver_ids"  : ""] as [String : Any]
        socket?.emitWithAck(APISocketAcceptRejectOrder, dic).timingOut(after: 0, callback: { (result) in
            print("Order Rejected")
            //REMOVE CURRENT REQUEST ID AND FROM QUEUE ALSO
            removeCurrentOrderRequest(orderId: orderId)
            removeOrderFromRequestQueue(orderId: orderId)
            completion(true)
        })
    }
    
    //MARK:- ACCEPT ORDER REQUEST
    func acceptOrderRequest(orderId : Int, customerId : Int, driverIds : String, completion:@escaping ([String:Any]) -> ()) {
        let isaccept : Int = 1
        let dic = ["is_accept" : isaccept, "user_id" : USER_OBJ?.userId! ?? 0, "order_id" : orderId , "customer_id" : customerId, "driver_ids"  : driverIds] as [String : Any]
        socket?.emitWithAck(APISocketAcceptRejectOrder, dic).timingOut(after: 0, callback: { (result) in
            print("Order Accepted")
            let data = result[0] as! [String:Any]
            //REMOVE ALL REQUEST FROM CURRENT QUEUE AND LEFT THE GROUP
            removeCurrentOrderRequest(orderId: orderId)
            self.clearRequestQueue()
            completion(data)
        })
    }
    
    //MARK:- CHANGE ORDER STATUS
    func updateOrderStatus(orderStatus : String, orderId : Int, customerId : Int, completion:@escaping (Bool) -> ()) {
        let dic = ["order_id" : orderId, "user_id" : USER_OBJ?.userId! ?? 0, "order_status" : orderStatus , "customer_id" : customerId] as [String : Any]
        socket?.emitWithAck(APISocketUpdateOrderStatus, dic).timingOut(after: 0, callback: { (result) in
            print("Order Status Chnaged")
            let data = result[0] as! [String:Any]
            if data["status"] as! Int == 1 {
                completion(true)
            }
            
        })
    }
    
    //REMOVE ALL REQUEST FROM CURRENT QUEUE AND LEFT THE GROUP
    func clearRequestQueue()  {
        for dic in getOrderRequestQueue() {
            leaveOrderRoom(orderId: dic["order_id"] as! Int )
        }
        removeAllOrderFromRequestQueue()
    }
    
    //LOAD NEXT ORDER
    func loadNextOrderIfThere() {
        //CHECK FOR THE OTHER REQUEST IS THERE OR NOT
       if getOrderRequestQueue().count > 0 {
           //LOAD NEXT REQUEST
           let dic = getOrderRequestQueue()[0]
           let dicDetail = dic["order_details"] as! NSDictionary
           let objOrderDetail: OrderDetail = OrderDetail(json: JSON(dicDetail))
           if getCurrentOrderRequest() == 0 {
              setCurrentOrderReequest(orderId: objOrderDetail.orderId!)
              postNotification(withName: ncNOTIFICATION_NEW_ORDER_REQUEST, userInfo: ["order_detail" : objOrderDetail])
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
    //MARK: - Chat Module
    func sendMessage(data:NSDictionary){

        socket?.emitWithAck(APISOCKETSendNewMessage, data).timingOut(after: 0) {data in
            let dic:NSDictionary = (data[0] as! NSDictionary)
            print(dic)
            let arrMessage = dic.value(forKey: "chat_message") as! NSMutableArray
            let dictMessage = arrMessage[0] as! NSMutableDictionary
            let msgId = dictMessage.value(forKey: "id")
            if (CoreDataAdaptor.sharedDataAdaptor.updateMessageID(messageID: "\(msgId!)",createdDate: dictMessage.value(forKey: "created_date") as! String ,modifiedDate : dictMessage.value(forKey: "modified_date") as! String)) {
                print("Yes")
                self.delegate?.reloadMessages?()
            }
        }

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
    
    //MARKS:- RECURRING ORDER
    func acceptRejectFutureOrderRequest(recurringOrderId : Int, recurringEntryId : Int, isAccept : Int, completion:@escaping ([String:Any]) -> ()) {
        let dic = ["is_accept" : isAccept   , "user_id" : USER_OBJ?.userId! ?? 0, "recurring_order_id" : recurringOrderId , "recurring_entry_id" : recurringEntryId] as [String : Any]
        socket?.emitWithAck(APISocketAcceptRejectRecurringOrder, dic).timingOut(after: 0, callback: { (result) in
            let data = result[0] as! [String:Any]
            completion(data)
        })
    }
    
    //MARK:- EVENTS
    func addHandlers() {
        //EVENT FOR DRIVER VERIFICATION CHANGE
        socket?.on(APISocketDriverVerificationChanged, callback: { (data, ack) in
            if let dic = data[0] as? [String : Any] {
                updateUserObjectForDriverVerification(is_verified: (dic["is_driver_verified"] as? Int)!)
                //GENERATE LOCAL NOTIFICATION TO INFORM DRIVER THAT HIS IDENTITY DETAILS ARE VERIFIED
                var msg = ""
                if (USER_OBJ?.isDriverVerified == 0) {
                    var d = dic
                    d["is_online"] = 0
                    postNotification(withName: ncNOTIFICATION_SOCKET_CHANGE_DRIVER_STATUS, userInfo: d)
                    msg = "Your identity details are refute by admin. Please check it and resubmit it."
                } else {
                    msg = "Your identity details are verified by admin. Now you can go online."
                }
                generateLocalNotification(title: "Identity verification", body: msg, identifier: "Notification.driver_verifiy")
            }
        })
    
        //EVENT FOR ORDER REQUEST
        socket?.on(APISocketOrderRequest, callback: { (data, ack) in
            if let dic = data[0] as? NSDictionary {
               //ORDER REQUEST DETAILS
               let dicDetail = dic["order_details"] as! NSDictionary
               let objOrderDetail: OrderDetail = OrderDetail(json: JSON(dicDetail))
                //JOIN ROOM
                self.joinOrderRoom(orderId: objOrderDetail.orderId!)
                //ADD INTO THE ORDER REQUEST QUEUE
                addOrderRequestToQueue(dic: dic as! [String:Any])
                
                //ADD VIBRATION EFFECT WHEN NEW REQUEST COMES
                AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
                
               
                //CHECK IF ALREADY CURRENT REQUEST IS THERE. IF NOT STORE, ORDER ID IN CUURENT ORDER REQUEST AND POST NOTIFICATION. IF NOT THEN CREATE LOCAL NOTIFICATION
                if getCurrentOrderRequest() == 0 {
                    //TEMPORARY DISPLAY ALERT
//                    let str = "Current Date: \(Date()) \nOrder Request : \(serverToLocal(date: objOrderDetail.requestDate!) ?? Date())\nDiffernce In seconds : \(getSecondsBetweenDates(date1: Date(), date2: serverToLocal(date: objOrderDetail.requestDate!)!))"
//                                   showAlertController(title: "", message: str) { (done) in
//                                       
//                                   }
                    
                    setCurrentOrderReequest(orderId: objOrderDetail.orderId!)
                    postNotification(withName: ncNOTIFICATION_NEW_ORDER_REQUEST, userInfo: ["order_detail" : objOrderDetail])
                    
                }else {
                    //GENERATE LOCAL NOTIICATION
                }
            }
        })
        
        //EVENT FOR SOME OTHER DRIVER ACCEPTED ORDER REQUEST
        socket?.on(APISocketOrderAcceptResult, callback: { (data, ack) in
            if let dic = data[0] as? NSDictionary {
                if dic["status"] as! Int == 1 {
                    if USER_OBJ?.userId == dic["driver_id"] as? Int{
                        
                    } else {
                        let orderId =  (dic["order_id"] as? Int)!
                        self.leaveOrderRoom(orderId: orderId)
                        //REMOVE CURRENT REQUEST ID AND FROM QUEUE ALSO
                        removeCurrentOrderRequest(orderId: orderId)
                        removeOrderFromRequestQueue(orderId: orderId)
                        //POST NOTIFICATION
                        postNotification(withName: ncNOTIFICATION_ORDER_ACCEPTED_RESULT, userInfo: dic as! [AnyHashable : Any])
                    }
                }
            }
        })
        
        //EVENT FOR ORDER REQUEST TIME OUT
        socket?.on(APISocketOrderRequestTimeout, callback: { (data, ack) in
           // if let dic = data[0] as? NSDictionary {
                //POST NOTIFICATION
                 //postNotification(withName: ncNOTIFICATION_ORDER_REQUEST_TIMEOUT, userInfo: dic as! [AnyHashable : Any])
            //}
        })
        
        //EVENT FOR ORDER DELIVERED ACKNOWLEDGE
        socket?.on(APISocketOrderDeliveredAck, callback: { (data, ack) in
           if let dic = data[0] as? NSDictionary {
                print(dic)
                //POST NOTIFICATION
                postNotification(withName: ncNOTIFICATION_ORDER_DELIVERED, userInfo: dic as! [AnyHashable : Any])
                let title = "Order Delivered"
            let body = "Your current order #\(dic["order_id"] ?? "") has been \(dic["order_status"] ?? "")"
            
            var d = [String : Any]()
           d["order_status"] = "\(dic["order_status"] ?? "")"
           d["order_id"] = "\(dic["order_id"] ?? 0)"
           d["driver_id"] = "\(dic["driver_id"] ?? 0)"
           d["customer_id"] = "\(dic["customer_id"] ?? 0)"
            
            generateChatLocalNotification(title: title, body: body, userInfo: d, identifier:"OrderDelieverNotification")
            }
        })
        
        //EVENT FOR RECEIVE NEW CHAT MESSAGE
        socket?.on(APISOCKETGetNewMessage, callback: { data, ack in
          let array:NSArray = (data[0] as! NSDictionary).value(forKey: "chat_message") as! NSArray
          let arrayObjMessage = CoreDataAdaptor.sharedDataAdaptor.saveMessage(array: array)
          if arrayObjMessage.count != 0 {
              self.delegate?.InitialMessage?(array: arrayObjMessage)
          }
            
            var isGenerateLocalNotification : Bool = false
            if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
                if visibleViewCtrl.isKind(of: DriverChatVC.self) {
                    if let chatvc = visibleViewCtrl as? DriverChatVC {
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
        socket?.on(APISocketManualStorePayment, callback: { data, ack in
            if let dic = data[0] as? NSDictionary {
                if dic["status"] as! Int == 1 {
                    //GENERATE LOCAL NOTIFICATION
                    var d = [String : Any]()
                    d["order_id"] = dic["order_id"]
                    d["message"] = dic["message"]
                    d["driver_id"] = dic["driver_id"]
                    d["title"] = dic["title"]
                    generateChatLocalNotification(title: dic["title"] as! String, body: dic["message"] as! String, userInfo: d , identifier: "ManualStorePaymentNotification")
                    postNotification(withName: ncNOTIFICATION_MANUAL_PAYMENT, userInfo: d)
                }
            }
            
        })
        socket?.on(APISocketWeeklyPayment, callback: { data, ack in
            if let dic = data[0] as? NSDictionary {
                if dic["status"] as! Int == 1 {
                    //GENERATE LOCAL NOTIFICATION
                    var d = [String : Any]()
                    d["order_id"] = dic["order_id"]
                    d["message"] = dic["message"]
                    d["driver_id"] = dic["driver_id"]
                    d["title"] = dic["title"]
                    d["week_start_date"] = dic["week_start_date"]
                    d["week_end_date"] = dic["week_end_date"]
                    d["weekly_payment_id"] = dic["weekly_payment_id"]
                    
                    generateChatLocalNotification(title: dic["title"] as! String, body: dic["message"] as! String, userInfo: d , identifier: "WeeklyPaymentNotification")
                    postNotification(withName: ncNOTIFICATION_WEEKLY_PAYMENT, userInfo: d)
                }
            }
            
        })
    }
   
}



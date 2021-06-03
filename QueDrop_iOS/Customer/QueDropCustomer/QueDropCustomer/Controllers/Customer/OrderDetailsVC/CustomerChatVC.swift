//
//  CustomerChatVC.swift
//  QueDrop
//
//  Created by C100-132 on 11/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import GrowingTextView
import SocketIO

class CustomerChatVC: BaseViewController {
    
      enum MessageVCMessageStatus: Int {
          case MessageVCMessageStatusFailed=0
          case MessageVCMessageStatusSent
          case MessageVCMessageStatusDelivered
          case MessageVCMessageStatusRead
          case MessageVCMessageStatusSending
          case MessageVCMessageStatusUploading
          case MessageVCMessageStatusDownloading
      }
    
    @IBOutlet var imgDriverProfile: UIImageView!
    @IBOutlet var lblDriverName: UILabel!
    @IBOutlet var tblChat: UITableView!
    @IBOutlet var txtMessage: GrowingTextView!
    @IBOutlet var btnSend: UIButton!
    @IBOutlet var lblInfo: UILabel!
    
    
    var sender_id = 0
    var receiver_id  = 0
    var receiver_name = ""
    var receiver_profile = ""
    var orderId = 0
    var orderStatus = ""
    var arrayMessage = [CDMessages]()
    var refresh:UIRefreshControl! = UIRefreshControl()
    var is_fromReload = false
    var isFromNotification : Bool = false
    
     //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tblChat.register(UINib(nibName: "SenderMessageCell", bundle: nil), forCellReuseIdentifier: "idSenderTextCell")
        tblChat.register(UINib(nibName: "ReceiverMessageCell", bundle: nil), forCellReuseIdentifier: "idReceiverTextCell")
        tblChat.tableFooterView = UIView()
        
        sender_id = USER_ID
        lblDriverName.text = receiver_name
        imgDriverProfile.sd_setImage(with: URL(string: receiver_profile), placeholderImage: USER_AVTAR, context: nil)
        imgDriverProfile.layer.cornerRadius = imgDriverProfile.frame.height / 2
        imgDriverProfile.layer.masksToBounds = true
        
        lblInfo.textColor = .darkGray
        lblInfo.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 13))
        
        if orderStatus == enumOrderStatus.delivered.rawValue || orderStatus == enumOrderStatus.cancelled.rawValue{
            lblInfo.text = "You can't send message to this conversation because order is already \(orderStatus)"
            lblInfo.isHidden = false
            txtMessage.isHidden = true
            btnSend.isHidden = true
        } else {
            lblInfo.isHidden = true
            txtMessage.isHidden = false
            btnSend.isHidden = false
        }
        
        
        setupRefreshData()
        if(isFromNotification){
            getUserDetails()
        }
    }
    
    override func viewWillLayoutSubviews() {
        
        txtMessage.backgroundColor = UIColor(red: 236/255, green: 235/255, blue: 235/255, alpha: 1)
        txtMessage.placeholderColor = UIColor(red: 134/255, green: 134/255, blue: 134/255, alpha: 1)
        txtMessage.layer.cornerRadius = 20
        txtMessage.layer.masksToBounds = true
       txtMessage.setLeftRightPadding(8, 8)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        APP_DELEGATE.socketIOHandler?.delegate = self
        getMessagesFromLocal()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.txtMessage.resignFirstResponder()
    }
    func getMessagesFromLocal()
    {
        let dict = NSMutableDictionary()
        
        if sender_id == USER_ID
        {
            dict.setValue(sender_id, forKey: "sender_id")
            dict.setValue(receiver_id, forKey: "receiver_id")
        }
        else
        {
            dict.setValue(receiver_id, forKey: "sender_id")
            dict.setValue(sender_id, forKey: "receiver_id")
            
        }
        
//        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
//        let strPredicate = NSString(format: "(senderId = %d AND receiverId = %d) OR (senderId = %d AND receiverId = %d)",sender_id,receiver_id,receiver_id,sender_id)
//        let arrayMessage1 = CoreDataAdaptor.sharedDataAdaptor.fetchMessageWhere(predicate: NSPredicate (format: strPredicate as String), sort: [sortDescriptor], limit: 20)
        
        if !is_fromReload {
            dict.setValue(0, forKey: "last_message_id")
        } else {
            dict.setValue(CoreDataAdaptor.sharedDataAdaptor.getLastMessageId(sender_id: sender_id, receiver_id: receiver_id, order_id: orderId), forKey: "last_message_id")
        }
        
        dict.setValue(20, forKey: "limit")
        dict.setValue(orderId, forKey: "order_id")
        
        APP_DELEGATE.socketIOHandler?.fetchNewMessagesOfSender(data: dict)
    }
    
    func setupRefreshData() {
        self.refresh.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tblChat.addSubview(refresh)
    }
    
    @objc func refreshData() {
        
        self.refresh.beginRefreshing()
        is_fromReload = true
        if arrayMessage.count != 0  {
            getMessagesFromLocal()
        }
    }
    
    func stopRefresh() {
        self.refresh.endRefreshing()
    }
    func getUserDetails()  {
          if isNetworkConnected {
              switch APP_DELEGATE.socketIOHandler?.socket?.status{
                  case .connected?:
                   APP_DELEGATE.socketIOHandler?.GetSingleUserDetails(userID: receiver_id, completion: { (objUser) in
                       let name = "\(objUser.firstName ?? "") \(objUser.lastName ?? "")"
                       let imgUrl = (objUser.userImage?.isValidUrl())! ? objUser.userImage ?? "" : "\(URL_USER_IMAGES)\(objUser.userImage ?? "")"
                       
                       self.receiver_name = name
                       self.receiver_profile = imgUrl
                       
                       self.lblDriverName.text = self.receiver_name
                       self.imgDriverProfile.sd_setImage(with: URL(string: self.receiver_profile), placeholderImage: USER_AVTAR, context: nil)
                   })
                    
                   break
                  default:
                     print("Socket Not Connected")
              }
          } else {
              ShowToast(message: kCHECK_INTERNET_CONNECTION)
          }
      }
    //MARK: - Button Click Event
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendClicked(_ sender: UIButton) {
        if txtMessage.text?.count == 0
        {
            //displayBanner(title: "", message: "Please Enter Your Text", type: BannerType.Error.rawValue)
        }
        else
        {
           // let strRandomId = String(format:"%d",(randomString(length: 20)))
            let dictMsg = NSMutableDictionary()
            dictMsg.setValue(0, forKey: "id")
           // dictMsg.setValue(strRandomId, forKey: "message_id")
            dictMsg.setValue(txtMessage.text.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "message")
            dictMsg.setValue(sender_id, forKey: "sender_id")
            dictMsg.setValue(receiver_id, forKey: "receiver_id")
            dictMsg.setValue("", forKey: "media_name")
            dictMsg.setValue("\(CustomerChatVC.MessageVCMessageStatus.MessageVCMessageStatusSending.rawValue)", forKey: "status")
            dictMsg.setValue(orderId, forKey: "order_id")
           // dictMsg.setValue(localToUTC(format: "yyyy-MM-dd HH:mm:ss"), forKey: "created_date")
            // dictMsg.setValue(localToUTC(format: "yyyy-MM-dd HH:mm:ss"), forKey: "modified_date")
            
            let arrayChat = NSMutableArray()
            arrayChat.add(dictMsg)
            
            _ = CoreDataAdaptor.sharedDataAdaptor.saveMessage(array: arrayChat)
            
            let dict = NSMutableDictionary()
            dict.setValue(txtMessage.text.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "message")
            dict.setValue(sender_id, forKey: "sender_id")
            dict.setValue(receiver_id, forKey: "receiver_id")
            dict.setValue(orderId, forKey: "order_id")
            APP_DELEGATE.socketIOHandler?.sendMessage(data: dict)
          
           txtMessage.text = ""
        }
    }
    
    func reloadMessagesFromLocal(){
        if is_fromReload {
            is_fromReload = false
            let strPredicate = NSString(format: "((senderId = %d AND receiverId = %d) OR (senderId = %d AND receiverId = %d)) AND messageId < %d AND orderId = %d",sender_id,receiver_id,receiver_id,sender_id,(arrayMessage.first?.messageId)!, orderId)
            let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
            
            var arrayMessageTemp = CoreDataAdaptor.sharedDataAdaptor.fetchMessageWhere(predicate: NSPredicate (format: strPredicate as String), sort: [sortDescriptor], limit: 20)
            
            if arrayMessageTemp.count != 0 {
                arrayMessageTemp = arrayMessageTemp.reversed()
                arrayMessage.insert(contentsOf: arrayMessageTemp, at: 0)
                stopRefresh()
                tblChat.reloadData()
            }
            else
            {
                stopRefresh()
            }
        } else {
            stopRefresh()
            let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
            let strPredicate = NSString(format: "((senderId = %d AND receiverId = %d) OR (senderId = %d AND receiverId = %d)) AND orderId = %d",sender_id,receiver_id,receiver_id,sender_id, orderId)
            arrayMessage.removeAll()
            arrayMessage = CoreDataAdaptor.sharedDataAdaptor.fetchMessageWhere(predicate: NSPredicate (format: strPredicate as String), sort: [sortDescriptor], limit: 20)
            arrayMessage = arrayMessage.reversed()
            tblChat.reloadData()
            if arrayMessage.count > 0
            {
                  self.tblChat.scrollToRow(at: (IndexPath(row:self.arrayMessage.count-1, section:0)) as IndexPath, at:.bottom, animated:true)
             }
        }
    }
}

//MARK: - Socket  Delegate
extension CustomerChatVC:SocketIOHandlerDelegate {
    
    func connectionStatus(status: SocketIOStatus) {
        
    }
    
    func reloadMessages() {
        reloadMessagesFromLocal()
    }
    
    func InitialMessage(array: [CDMessages]) {
        reloadMessagesFromLocal()
    }
}

//MARK: - UITableview Delegate Method
extension CustomerChatVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMessage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let objMessage = arrayMessage[indexPath.row]
            
            if objMessage.senderId == USER_ID {
            
                let cell = tableView.dequeueReusableCell(withIdentifier: "idSenderTextCell", for: indexPath) as! SenderMessageCell
              
//                let dateFormate = DateFormatter()
//                dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                dateFormate.timeZone = NSTimeZone.local
//                let cdate = dateFormate.string(from: objMessage.modifiedDate!)
//                let strDate = getChatDateFromServer(strDate:cdate)
                                                       
                               let dateFormatter = DateFormatter()
                                              dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                              let dateStr = dateFormatter.string(from: objMessage.modifiedDate!)
                                              var date = dateFormatter.date(from:dateStr)!
                                              date = date.UTCtoLocal().toDate()!
                                               let cdate = dateFormatter.string(from: date)
                                              let strDate = getChatDateFromServer(strDate:cdate)
                
                cell.lblMessageText.text = objMessage.message
                cell.lblDateTime.isHidden = false
                cell.vwDateHeight.constant = 20
                
               // if indexPath.row == arrayMessage.count - 1 {
                    cell.lblDateTime.text = "\(strDate) \(timeAgoSinceDate(date: DateFormater.getDateFromString(givenDate: "\(cdate)") as Date, numericDates: false))"
    //            } else {
    //                if indexPath.row == 0 {
    //                    cell.lblDateTime.isHidden = true
    //                    cell.vwDateHeight.constant = 0
    //                } else {
    //                    let objPrevious = arrayMessage[indexPath.row - 1]
    //                    let objNext = arrayMessage[indexPath.row + 1]
    //                    if objPrevious.senderId == objMessage.senderId {
    //                        cell.lblDateTime.isHidden = true
    //                        cell.vwDateHeight.constant = 0
    //                    }  else if objMessage.senderId == objNext.senderId {
    //                        cell.lblDateTime.isHidden = true
    //                        cell.vwDateHeight.constant = 0
    //                    } else {
    //                        cell.lblDateTime.text = "\(strDate) \(timeAgoSinceDate(date: DateFormater.getDateFromString(givenDate: "\((objMessage.createdDate)!)") as Date, numericDates: false))"
    //                    }
    //                }
    //            }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "idReceiverTextCell", for: indexPath) as! ReceiverMessageCell
//
//                        let dateFormate = DateFormatter()
//                        dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                        dateFormate.timeZone = NSTimeZone.local
//                        let cdate = dateFormate.string(from: objMessage.modifiedDate!)
//                        let strDate = getChatDateFromServer(strDate:cdate)
                                     
                let dateFormatter = DateFormatter()
                               dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                               let dateStr = dateFormatter.string(from: objMessage.modifiedDate!)
                               var date = dateFormatter.date(from:dateStr)!
                               date = date.UTCtoLocal().toDate()!
                                let cdate = dateFormatter.string(from: date)
                               let strDate = getChatDateFromServer(strDate:cdate)
                
                           cell.lblMessageText.text = objMessage.message
                           cell.lblDateTime.isHidden = false
                           cell.vwDateHeight.constant = 20
                           
                          // if indexPath.row == arrayMessage.count - 1 {
                               cell.lblDateTime.text = "\(strDate) \(timeAgoSinceDate(date: DateFormater.getDateFromString(givenDate: "\(cdate)") as Date, numericDates: false))"
    //                       } else {
    //                           if indexPath.row == 0 {
    //                               cell.lblDateTime.isHidden = true
    //                               cell.vwDateHeight.constant = 0
    //                           } else {
    //                               let objPrevious = arrayMessage[indexPath.row - 1]
    //                               let objNext = arrayMessage[indexPath.row + 1]
    //                               if objPrevious.senderId == objMessage.senderId {
    //                                   cell.lblDateTime.isHidden = true
    //                                   cell.vwDateHeight.constant = 0
    //                               } else if objMessage.senderId == objNext.senderId {
    //                                    cell.lblDateTime.isHidden = true
    //                                    cell.vwDateHeight.constant = 0
    //                               } else {
    //                                   cell.lblDateTime.text = "\(strDate) \(timeAgoSinceDate(date: DateFormater.getDateFromString(givenDate: "\((objMessage.createdDate)!)") as Date, numericDates: false))"
    //                               }
    //                           }
    //                       }
                           return cell
            }
        }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        let objMessage = arrayMessage[indexPath.row]
//        switch Int(objMessage.messageType) {
//        case MessageVC.MessageVCMessageType.MessageVCMessageTypeText.rawValue:
//            if Int(objMessage.senderId) == APP_DELEGATE.objUser?.id {
                return 90
//            }else {
//                return 80
//            }
//
//        case MessageVC.MessageVCMessageType.MessageVCMessageTypeImage.rawValue,MessageVC.MessageVCMessageType.MessageVCMessageTypeVideo.rawValue:
//            if Int(objMessage.senderId) == APP_DELEGATE.objUser?.id {
//                return 170
//            }else {
//                return 170
//            }
//
//
//        default:
//            return 0
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

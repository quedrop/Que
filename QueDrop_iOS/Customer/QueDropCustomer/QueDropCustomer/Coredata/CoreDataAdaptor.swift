//
//  CoreDataAdaptor.swift
//  Kideo
//
//  Created by NC2-38 on 15/12/17.
//  Copyright © 2017 NC2-38. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class CoreDataAdaptor: NSObject {
 
    static let sharedDataAdaptor = CoreDataAdaptor()
    var managedContext = CoreDBManager.sharedDatabase.persistentContainer.viewContext
    
    //MARK:- Save
    
    //MARK:- Message
    func saveMessage(array:NSArray) -> [CDMessages]
    {
        var arrayObjMessage:[CDMessages] = []
        
        for data in array {
            
            let obj = data as! NSDictionary
            let strPredicate = "messageId = \(obj.value(forKey: "id")!)"
           // let strPredicate1 = NSString(format: "messageId = %d",obj.value(forKey: "id"))
            
            let arrayMessage = fetchMessageWhere(predicate: NSPredicate (format: strPredicate as String))
            
            var objMessage  = CDMessages()
            if arrayMessage.count == 0 {
                objMessage = CDMessages(entity: CDMessages.entity(), insertInto: managedContext)
            
            if let amount = obj.value(forKey: "id") as? String {
                objMessage.messageId = Int16(amount)!
            }
            else if let amount = obj.value(forKey: "id") as? Int {
                objMessage.messageId = Int16(amount)
            }
           
            objMessage.message = obj.value(forKey: "message") as? String
            
            if let amount = obj.value(forKey: "sender_id") as? String {
                objMessage.senderId = Int16(amount)!
            }
            else if let amount = obj.value(forKey: "sender_id") as? Int {
                objMessage.senderId = Int16(amount)
            }
            if let amount = obj.value(forKey: "order_id") as? String {
                objMessage.orderId = Int16(amount)!
            }
            else if let amount = obj.value(forKey: "order_id") as? Int {
                objMessage.orderId = Int16(amount)
            }
            if let amount = obj.value(forKey: "receiver_id") as? String {
                objMessage.receiverId = Int16(amount)!
            }else if let amount = obj.value(forKey: "receiver_id") as? Int {
                objMessage.receiverId = Int16(amount)
            }
           
            if let amount = obj.value(forKey: "status") as? String {
                objMessage.messageStatus = Int16(amount)!
            } else if let amount = obj.value(forKey: "status") as? Int {
                objMessage.messageStatus = Int16(amount)
            }
                
                if (obj.value(forKey: "created_date") as? String) != nil && (obj.value(forKey: "modified_date") as? String) != nil {
                
                    let dateFormate = DateFormatter()
                    dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let cdate = dateFormate.date(from: obj.value(forKey: "created_date") as! String)
                    let mdate = dateFormate.date(from: obj.value(forKey: "modified_date") as! String)
            
                    objMessage.createdDate = cdate
                    objMessage.modifiedDate = mdate
                }
         
            arrayObjMessage.append(objMessage)

            CoreDBManager.sharedDatabase.saveContext()
            
            }
        }
        
        return arrayObjMessage
    }
  
    
    func fetchAllMessage() -> [CDMessages] {
        
        var arrayMessage:[CDMessages] = []
        let fetchRequest: NSFetchRequest<CDMessages> = CDMessages.fetchRequest()
        do {
            arrayMessage = (try managedContext.fetch(fetchRequest))
        } catch {
            print("Cannot fetch")
        }
        return arrayMessage
    }
    
    func fetchMessageWhere(predicate:NSPredicate?, sort:[NSSortDescriptor] = [], limit:Int = 0) -> [CDMessages] {
        
        var arrayMessage:[CDMessages] = []
        let fetchRequest: NSFetchRequest<CDMessages> =
            CDMessages.fetchRequest()
        fetchRequest.predicate = predicate
        (limit != 0) ? (fetchRequest.fetchLimit = limit) : nil
        (sort.count != 0) ? (fetchRequest.sortDescriptors = sort) : nil
        do {
            arrayMessage = (try managedContext.fetch(fetchRequest))
        } catch {
            print("Cannot fetch")
        }
       
        return arrayMessage
    }
   
    
    func deleteAllMessage () {
        
        let deleteAll = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "CDMessages"))
        do {
            try managedContext.execute(deleteAll)
        }
        catch {
            print(error)
        }
        
        CoreDBManager.sharedDatabase.saveContext()
    }
    
    
     func getLastMessageId(sender_id:Int,receiver_id:Int,order_id:Int) -> String {
           let sortDescriptor = NSSortDescriptor(key: "messageId", ascending: true)
           let strPredicate = NSString(format: "senderId = %d AND receiverId = %d AND orderId = %d",sender_id,receiver_id,order_id)
           let arrayMessage = fetchMessageWhere(predicate:NSPredicate (format: strPredicate as String), sort:[sortDescriptor], limit:1)
           if arrayMessage.count == 0 {return "0"}
           let objMessage = arrayMessage.first
           let str = "\(objMessage!.messageId)"
           return str
       }
    func getMinMessageId(sender_id:String,receiver_id:String) -> String {
        let sortDescriptor = NSSortDescriptor(key: "messageId", ascending: true)
        let strPredicate = NSString(format: "senderId = %@ AND receiverId = %@",sender_id,receiver_id)
        let arrayMessage = fetchMessageWhere(predicate:NSPredicate (format: strPredicate as String), sort:[sortDescriptor], limit:1)
        if arrayMessage.count == 0 {return "0"}
        let objMessage = arrayMessage.first
        let str = "\(objMessage!.messageId)"
        return str
    }
    
    func getLastMessageId1() -> String {
        let sortDescriptor = NSSortDescriptor(key: "messageId", ascending: false)
        let arrayMessage = fetchMessageWhere(predicate:nil, sort:[sortDescriptor], limit:1)
        if arrayMessage.count == 0 {return "0"}
        let objMessage = arrayMessage.first
        let str = "\(objMessage!.messageId)"
        return str
    }
    
//    func getOnGoingConvertation() -> [CDMessages] {
//        var arrayMessage:[CDMessages] = []
//        //let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDMessages")
//        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "CDMessages", in: self.managedContext)!
//        fetchRequest.entity = disentity
//        fetchRequest.propertiesToFetch = ["receiverId"]
//        fetchRequest.returnsDistinctResults = true
//        fetchRequest.resultType = .dictionaryResultType
//
//        let strUserIDs = getUniqueUserIDs()
//        let arrayUserIDs = strUserIDs.components(separatedBy: ",")
//        let predicate = NSPredicate(format: "receiverId IN %@",arrayUserIDs)
//        fetchRequest.predicate = predicate
//
//        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        do {
//            let results = (try managedContext.fetch(fetchRequest))
//            for data in results {
//                let dic = data as! [String:Int]
//                let arrayTemp = fetchMessageWhere(predicate: NSPredicate (format: "receiverId == %d", dic["receiverId"]!), sort:[sortDescriptor])
//                if arrayTemp.count != 0 {
//                    arrayMessage.append(arrayTemp.first!)
//                }
//            }
//        } catch {
//            print("Cannot fetch")
//        }
//
//        arrayMessage .sort(by: { $0.createdDate! > $1.createdDate! })
//
//        return arrayMessage
//    }
    
    func getMessageCount(userid:Int) -> Int {
      //  let arrayMessage = self.fetchMessageWhere(predicate: NSPredicate (format: "(receiver_id = %d AND sender_id = %d) AND status != 3",(APP_DELEGATE.objUser?.userid)!, userid))
      //  return arrayMessage.count
        return 0
    }
    
    func getUnreadMessageCount() -> Int {
        
        return 0
//        let strUserIDs = getUniqueUserIDs()
//        let arrayUserIDs = strUserIDs.components(separatedBy: ",")
//        let arrayMessage = self.fetchMessageWhere(predicate: NSPredicate (format: "receiver_id = %d AND status != 3 AND sender_id IN %@",(APP_DELEGATE.objUser?.userid)!,arrayUserIDs))
//        return arrayMessage.count
    }
    
    func readMessageOfUser(userid:Int){
//        let predicate = NSPredicate(format: "(receiver_id = %d AND sender_id = %d) AND status != 3 AND status != 5",(APP_DELEGATE.objUser?.userid)!, userid)
//        let fetchRequest = NSBatchUpdateRequest(entityName: "Message")
//        fetchRequest.propertiesToUpdate = ["status":"3"]
//        fetchRequest.predicate = predicate
//        fetchRequest.resultType = .updatedObjectIDsResultType
//
//        do {
//            let result = try  managedContext.execute(fetchRequest) as! NSBatchUpdateResult
//            let objectIDArray = result.result as? [NSManagedObjectID]
//            let changes = [NSUpdatedObjectsKey : objectIDArray]
//            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as Any as! [AnyHashable : Any], into: [self.managedContext])
//
//            CoreDBManager.sharedDatabase.saveContext()
//        }catch {
//        }
    }
    
    func updateMessageID(messageID:String,createdDate : String,modifiedDate : String) -> Bool {

        let predicate = NSPredicate(format: "messageId = '0'")
        var arrayMessage:[CDMessages] = []
        let fetchRequest: NSFetchRequest<CDMessages> = CDMessages.fetchRequest()
        fetchRequest.predicate = predicate
        do {
            arrayMessage = (try managedContext.fetch(fetchRequest))
            if arrayMessage.count != 0 {
                let objMessage = arrayMessage.first
                objMessage?.messageId = Int16(messageID)!
                
                let dateFormate = DateFormatter()
                dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let cdate = dateFormate.date(from: createdDate)
                let mdate = dateFormate.date(from: modifiedDate)

                objMessage?.modifiedDate = mdate
                objMessage?.createdDate = cdate
                
               // objMessage?.messageStatus = Double(MessageVC.MessageVCMessageStatus.MessageVCMessageStatusSent.rawValue)
                CoreDBManager.sharedDatabase.saveContext()
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
 
    func updateMessageStatus(status:Double,messageID:String) -> Bool {
//        let predicate = NSPredicate(format: "id = %@",messageID)
//        var arrayMessage:[Message] = []
//        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
//        fetchRequest.predicate = predicate
//        do {
//            arrayMessage = (try managedContext.fetch(fetchRequest))
//            if arrayMessage.count != 0 {
//                let objMessage = arrayMessage.first
//                objMessage?.status = status
//                CoreDBManager.sharedDatabase.saveContext()
//                return true
//            } else {
//                return false
//            }
//        } catch {
//            return false
//        }
        
        return false
    }
    
    
    
}


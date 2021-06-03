//
//  Ext+SocketIOHandler.swift
//  QueDrop
//
//  Created by C100-105 on 14/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import Foundation
import SocketIO

extension SocketIOHandler {
    
    func supplierJoinSocket()  {
        let dic: NSDictionary = [
            "store_id" : (USER_OBJ?.storeId).asInt(),
            "user_id" : USER_ID
        ]
        socket?.emitWithAck(APISocketSupplierJoin, dic).timingOut(after: 0) { result in
            self.checkForRevoke(result: result, isCallFromJoinSocket: true)
        }
    }
    
    func supplierChangeAcknowldge()  {
        socket?.on(
            APISocketSupplierChangeAcknowldge,
            callback: { (data, ack) in
                self.checkForRevoke(result: data, isCallFromJoinSocket: false)
        })
    }
    
    func checkForRevoke(result: [Any], isCallFromJoinSocket: Bool) {
        if let dic = result[0] as? NSDictionary {
            var isRevoke = false
            if let revoke = dic["is_revoke"] as? Int {
                isRevoke = revoke == 1
            } else if let revokeStr = dic["is_revoke"] as? String, let revoke = Int(revokeStr) {
                isRevoke = revoke == 1
            }
            
            var message = "Your current store ownership has been revoked by admin. Please contact to GOFER support team for this."
            if let messageStr = dic["message"] as? String {
                message = messageStr
            }
            
            if isRevoke {
                if let vc = APP_DELEGATE.window?.rootViewController {
                    vc.showOkAlert(message) {
                        vc.ReinitializeApp()
                    }
                }
            } else if isCallFromJoinSocket {
                self.supplierChangeAcknowldge()
            }
        }
    }
}

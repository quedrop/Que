package com.quedrop.driver.socket

import io.socket.client.Socket

class SocketConstants {


    companion object {
        // private const val SOCKET_PORT = "3005"
        private const val SOCKET_PORT = "8081"

        //      const val SOCKET_URL = "http://clientapp.narola.online:".plus(SOCKET_PORT)
        const val SOCKET_URL = "http://34.204.81.189:30080"

        var isSocketConnecting: Boolean = false
        var socketIOClient: Socket? = null

        var request: String = "request"

        /*
        * Params
        * */
        var status: String = "status"
        var KeyUserId = "user_id"
        var message = "message"
        var KeyLongitude = "longitude"
        var KeyLatitude = "latitude"
        var KeyIsOnline = "is_online"
        var KeyOrderId = "order_id"
        var KeyOrderStatus = "order_status"
        var KeyCustomerId = "customer_id"
        var KeyIsAccept = "is_accept"
        var KeyDriverIds = "driver_ids"
        var KeyRecurringOrderId = "recurring_order_id"
        var KeyRecurringEntryId = "recurring_entry_id"

        /****
         * Socket Events Name
         */
        var SocketJoinSocket = "join_socket"
        var SocketChangeDriverStatus = "changeDriverWorkingStatus"
        var SocketGetDriverWorkingStatus = "getDriverWorkingStatus"
        var SocketUpdateDriverLocation = "updateDriverLocation"
        var SocketGetOrderDetail = "getOrderDetail"
        var SocketGetOrderRequest = "order_request"
        var SocketAcceptRejectOrder = "AcceptRejectOrder"
        var SocketJoinOrderRoom = "JoinOrderRoom"
        var SocketLeaveOrderRoom = "LeaveOrderRoom"
        var SocketUpdateOrderStatus = "update_order_status"
        var SocketOrderDeliveryAcknowledge = "order_delivered_acknowledge"
        var SocketDriverVerificationChange = "driver_verification_change"
        var SocketGetUserDetails = "get_user_details"
        var SocketManualStorePaymentAcknowledge = "manual_store_payment_acknowledge"
        var SocketDriverWeeklyPaymentAcknowledge = "driver_weekly_payment_acknowledge"
        var SocketAcceptRejectRecurringOrder = "accept_reject_recurring_order"
        var SocketOrderAccepted = "order_accepted"
    }
}
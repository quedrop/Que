package com.quedrop.customer.socket

import io.socket.client.Socket

class SocketConstants {


    companion object {
        // private const val SOCKET_PORT = "3005"
        private const val SOCKET_PORT = "8081"
        const val SOCKET_URL = "http://34.204.81.189:30080"


        var isSocketConnecting: Boolean = false
        var socketIOClient: Socket? = null
        var socketListener: SocketListener? = null

        var request: String = "request"

        /*
        * Params
        * */


        //        var status: String = "status"
        var KeyUserId = "user_id"
        var KeySupplier = "user_id"
        var KeyStoreId = "store_id"

        //        var message = "message"
        var keyGuestId = "guest_user_id"

        //        var message = "message"
//        var KeyLongitude = "longitude"
//        var KeyLatitude = "latitude"
//        var KeyIsOnline = "is_online"
        var keyDriverIdForRoute = "driver_id"
        var KeyOrderId = "order_id"
        var KeyDriverId = "driver_ids"
        var KeyDriverIds = "driver_id"
        var KeyPaymentType = "payment_type"
        var KeyTotalAmount = "total_amount"
        var KeyTransactionToken = "transaction_token"
        var KeyPaymentNetwork = "payment_network"
        var KeyPaymentMethod = "payment_method"
        var KeyPaymentDate = "payment_date"
        var KeyBillingAddress = "billing_address"
        var KeyTip = "tip"
        var KeyTransactionId = "transaction_id"

        /*Payment key constants*/

        var keyBankCode = "bank_code"
        var KeyPaymentReference = "payment_reference"
        var KeyRetrievalReferenceNumber = "retrieval_reference_number"
        var KeyMerchantReference = "merchant_reference"
        var KeyCardNumber = "card_number"
        var KeyTransactionDate = "transaction_date"
        var KeyTransactionAmount = "transaction_amount"
        var KeyResponseCode = "response_code"
        var KeyResponseDesc = "response_desc"

        /*  View nearby driver*/

        var KeyDeliveryOption = "delivery_option"
        var KeyDeliveryLatitude = "delivery_latitude"
        var KeyDeliveryLongitude = "delivery_longitude"


        /****
         * Socket Events Name
         */
        var SocketJoinSocket = "join_socket"
        var SocketPlaceOrder = "placeOrder"
        var SocketOrderAccepted = "order_accepted"
        var SocketStatusChanged = "order_status_changed"
        var SocketStartDriverLocation = "start_driver_location_update"
        var SocketStopDriverLocation = "stop_driver_location_update"
        var SocketDriverLocationChanged = "driver_location_changed"
        var SocketGetCartCount = "get_cart_items_count"
        var SocketDisconnectManually = "disconnect_manually"
        var SocketGetUserDetails = "get_user_details"
        var SocketGetUpdatedEstimatedTime = "get_updated_estimated_time"
        var SocketCompleteOrder = "complete_order"
        var SocketGetDriverList = "get_driver_list"
//        var SocketChangeDriverStatus = "changeDriverWorkingStatus"
//        var SocketGetDriverWorkingStatus = "getDriverWorkingStatus"
//        var SocketUpdateDriverLocation = "updateDriverLocation"
//        var SocketGetOrderDetail = "getOrderDetail"


        //Socket supplier contants

        var SocketSupplierJoinSocket = "supplier_join_socket"
        var SocketSupplierChangeAcknowledge = "supplier_change_acknowledge"
        var SocektSupplierWeeklyPaymentAcknowledge = "supplier_weekly_payment_acknowledge"
        var SocketSupplierStoreVerification = "store_verification_ack"

    }
}
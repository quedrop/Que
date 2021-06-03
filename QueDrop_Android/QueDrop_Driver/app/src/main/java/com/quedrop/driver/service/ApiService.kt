package com.quedrop.driver.service

import com.quedrop.driver.service.model.*
import com.quedrop.driver.service.request.*
import com.quedrop.driver.service.model.BankDetailModel
import com.google.gson.JsonObject
import com.google.gson.annotations.SerializedName
import io.reactivex.Single
import okhttp3.MultipartBody
import okhttp3.RequestBody
import retrofit2.http.*


interface ApiService {

    @POST("QueDropService.php?Service=RefreshToken")
    fun getNewToken(@Body tokenRequest: TokenRequest): Single<TokenResponse>

    @POST("QueDropService.php?Service=Login")
    fun loginUSer(@Body loginRequest: LoginRequest): Single<LoginResponse>

    @POST("QueDropService.php?Service=Register")
    fun registerUser(@Body registerRequest: RegisterRequest): Single<LoginResponse>

    @POST("QueDropService.php?Service=SendOTP")
    fun sendOTP(@Body sendOTPRequest: SendOTPRequest): Single<LoginResponse>

    @POST("QueDropService.php?Service=VerifyOTP")
    fun verifyOTP(@Body verifyOTPRequest: VerifyOTPRequest): Single<LoginResponse>

    @POST("QueDropService.php?Service=SocialRegister")
    fun socialRegister(@Body socialRegisterRequest: SocialRegisterRequest): Single<LoginResponse>

    @POST("QueDropService.php?Service=ForgotPassword")
    fun forgotPassword(@Body socialRegisterRequest: ForgotPasswordRequest): Single<LoginResponse>

    @POST("QueDropService.php?Service=UpdateDriverIdentityDetail")
    @Multipart
    fun updateIdentity(
        @Part("secret_key") secretKey: RequestBody,
        @Part("access_key") userName: RequestBody,
        @Part("user_id") userId: RequestBody,
        @Part("vehicle_type") vehicleType: RequestBody,
        @Part licencePhoto: MultipartBody.Part?,
        @Part driverPhoto: MultipartBody.Part,
        @Part registrationProof: MultipartBody.Part?,
        @Part numberPlate: MultipartBody.Part?

    ): Single<IdentityResponse>

    @POST("QueDropService.php?Service=UploadOrderReceipt")
    @Multipart
    fun uploadOrderReceipt(
        @Part("order_id") orderId: RequestBody,
        @Part("order_store_id") orderStoreId: RequestBody,
        @Part("secret_key") secretKey: RequestBody,
        @Part("access_key") accessKey: RequestBody,
        @Part receipt: MultipartBody.Part?,
        @Part("user_id") userId: RequestBody,
        @Part("bill_amount") billAmount: RequestBody
    ): Single<IdentityResponse>

    @POST("QueDropService.php?Service=RemoveOrderReceipt")
    fun removeOrderReceipt(@Body removeOrderReceiptRequest: RemoveOrderReceiptRequest): Single<UserOrderData>

    @GET("https://maps.googleapis.com/maps/api/directions/json?")
    fun getMapRoute(@QueryMap data: HashMap<String, String>): Single<GoogleMapDirection>

    @POST("QueDropService.php?Service=GetDriverOrders")
    fun getCurrentAndPastOrder(@Body ordersRequest: OrdersRequest): Single<UserOrderData>

    @POST("QueDropService.php?Service=GetSingleOrderDetail")
    fun getSingleOrderDetail(@Body ordersRequest: SingleOrderRequest): Single<MainOrderResponse>

    @POST("QueDropService.php?Service=GetFutureOrderDates")
    fun getFutureOrderDates(@Body ordersRequest: FutureDatesRequest): Single<FutureOrderDatesResponse>

    @POST("QueDropService.php?Service=GiveRateReview")
    fun giveRateAndReview(@Body giveRateRequest: GiveRateRequest): Single<MainOrderResponse>

    @POST("QueDropService.php?Service=GetNotifications")
    fun getNotifications(@Body notificationListRequest: NotificationListRequest): Single<NotificationResponse>

    @POST("QueDropService.php?Service=Logout")
    fun logOut(@Body logOut: LogOutRequest): Single<SettingResponse>

    @POST("QueDropService.php?Service=ChangePassword")
    fun changePassword(@Body changePasswordRequest: ChangePasswordRequest): Single<SettingResponse>

    @POST("QueDropService.php?Service=GetRatingReview")
    fun getRatingReview(@Body rateReviewDriverRequest: RateReviewDriverRequest): Single<SettingResponse>

    @POST("QueDropService.php?Service=GetDriverIdentityDetail")
    fun getIndentityDetails(@Body rateReviewDriverRequest: RateReviewDriverRequest): Single<IdentityResponse>

    @POST("QueDropService.php?Service=GetBankDetails")
    fun getBankDetails(@Body rateReviewDriverRequest: RateReviewDriverRequest): Single<BankDetailsResponse>

    @POST("QueDropService.php?Service=DeleteBankDetail")
    fun deleteBanksDetail(@Body deleteBankDetailRequest: DeleteBankDetailRequest): Single<BankDetailsResponse>

    @POST("QueDropService.php?Service=GetUserProfileDetail")
    fun getUserProfileDetail(@Body rateReviewDriverRequest: RateReviewDriverRequest): Single<LoginResponse>


    @Multipart
    @POST("QueDropService.php?Service=Register")
    fun registerUser(
        @Part("secret_key") secretKey: RequestBody,
        @Part("access_key") accessKey: RequestBody,
        @Part user_image: MultipartBody.Part?,
        @Part("firstname") firstname: RequestBody,
        @Part("lastname") lastname: RequestBody,
        @Part("password") password: RequestBody,
        @Part("login_as") login_as: RequestBody,
        @Part("referral_code") referral_code: RequestBody,
        @Part("email") email: RequestBody,
        @Part("device_type") device_type: RequestBody,
        @Part("timezone") timezone: RequestBody,
        @Part("latitude") latitude: RequestBody,
        @Part("longitude") longitude: RequestBody,
        @Part("address") address: RequestBody

    ): Single<LoginResponse>

    @Multipart
    @POST("QueDropService.php?Service=EditProfile")
    fun editProfile(
        @Part("user_id") userId: RequestBody,
        @Part("user_name") userName: RequestBody,
        @Part("secret_key") secretKey: RequestBody,
        @Part("access_key") accessKey: RequestBody,
        @Part user_image: MultipartBody.Part?,
        @Part("first_name") firstName: RequestBody,
        @Part("last_name") lastName: RequestBody,
        @Part("login_as") loginAs: RequestBody,
        @Part("country_code") countryCode: RequestBody,
        @Part("phone_number") phoneNumber: RequestBody,
        @Part("version") version: RequestBody

    ): Single<LoginResponse>

    @POST("QueDropService.php?Service=GetBankNameList")
    fun getAllBankList(@Body jsonObject: JsonObject): Single<GenieResponse<MutableList<BankDetailModel>>>

    @POST("QueDropService.php?Service=AddBankDetail")
    fun addBankDetails(@Body jsonObject: JsonObject): Single<GenieResponse<Nothing>>

    @POST("QueDropService.php?Service=EditBankDetail")
    fun editBankDetails(@Body jsonObject: JsonObject): Single<GenieResponse<Nothing>>

    @POST("QueDropService.php?Service=GetDriverWeekleyPaymentDetail")
    fun getDriverWeekleyPaymentDetail(@Body getWeeklyPaymentRequest: GetWeeklyPaymentRequest): Single<MainOrderResponse>

    @POST("QueDropService.php?Service=ManualStorePaymentDetail")
    fun getManualStorePaymentDetail(@Body getManualStorePaymentRequest: GetManualStorePaymentRequest): Single<MainOrderResponse>

    @POST("QueDropService.php?Service=GetEarningDataForHome")
    fun getEarningDataForHome(@Body getManualStorePaymentRequest: GetManualStorePaymentRequest): Single<MainOrderResponse>

    @POST("QueDropService.php?Service=CheckForValidReferralCode")
    fun checkForValidReferralCode(@Body checkForValidReferralCodeRequest: CheckForValidReferralCodeRequest): Single<MainOrderResponse>

    @POST("QueDropService.php?Service=GetFutureOrders")
    fun getFutureOrders(@Body GetFutureOrderRequest: GetFutureOrderRequest): Single<UserOrderData>

    @POST("QueDropService.php?Service=GetSingleFutureOrderDetail")
    fun getFutureSingleOrderDetail(@Body getFutureSingleOrderRequest: GetFutureSingleOrderRequest): Single<MainOrderResponse>

    @POST("QueDropService.php?Service=GetFutureOrderDates")
    fun getFutureOrderDates(@Body getFutureOrderDatesRequest: GetFutureOrderDatesRequest): Single<MainOrderResponse>

}
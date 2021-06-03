package com.quedrop.customer.network

import com.quedrop.customer.model.*
import com.quedrop.customer.ui.home.view.GoogleMapDirection
import com.google.gson.JsonObject
import io.reactivex.Single
import okhttp3.MultipartBody
import okhttp3.RequestBody
import retrofit2.http.*


interface ApiInterface {

    // @Headers("Content-Type: application/json", "Cache-Control: max-age=640000")
    @POST("QueDropService.php?Service=AddAddress")
    fun addAddress(@Body requestBody: AddAddress): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetCustomerAddresses")
    fun getCustomerAddress(@Body requestBody: AddCustomerAddress): Single<ResponseHandler>

    @POST("QueDropService.php?Service=DeleteAddress")
    fun deleteAddress(@Body requestBody: DeleteAddress): Single<ResponseHandler>

    @POST("QueDropService.php?Service=EditAddress")
    fun editAddress(@Body requestBody: EditAddress): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GuestRegister")
    fun guestRegister(@Body requestBody: AddGuestRegister): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetAllServiceCategory")
    fun allCategories(@Body requestBody: AllCategories): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetNearByStores")
    fun nearByStore(@Body requestBody: AddNearByStores): Single<ResponseHandler>

    @POST("QueDropService.php?Service=SearchStoreByName")
    fun searchStoreByName(@Body requestBody: SearchStoreByName): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetOfferList")
    fun getOfferList(@Body requestBody: OfferList): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetStoreDetails")
    fun getStoreDetails(@Body requestBody: AddStoreDetails): Single<ResponseHandler>

    @POST("QueDropService.php?Service=MarkStoreAsFavouriteUnFavourite")
    fun setFavouriteStore(@Body requestBody: SetFavourite): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetStoreCategoryWithProduct")
    fun getStoreCategoryWithProduct(@Body requestBody: AddStoreCategoriesItem): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetUserAddedStoreProductsFromCart")
    fun GetUserAddedStoreProductsFromCart(@Body addUserProductFromCart: AddUserProductFromCartRequest): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetProductDetail")
    fun getAddOnsProduct(@Body requestBody: AddProductAddOns): Single<ResponseHandler>

    @POST("QueDropService.php?Service=AddItemToCart")
    fun getAddItemCart(@Body requestBody: AddItemCart): Single<ResponseHandler>

    @Multipart
    @POST("QueDropService.php?Service=AddUserStoreProduct")
    fun addProduct(
        @Part("is_user_added_store") is_user_added_store: RequestBody,
        @Part("store_id") store_id: RequestBody,
        @Part("user_store_id") user_store_id: RequestBody,
        @Part("user_id") user_id: RequestBody,
        @Part("guest_user_id") guest_user_id: RequestBody,
        @Part("product_description") product_description: RequestBody,
        @Part("secret_key") secret_key: RequestBody,
        @Part("access_key") other: RequestBody,
        @Part("products") products: RequestBody,
        @Part image: ArrayList<MultipartBody.Part>,
        @Part("version") version: RequestBody,
        @Part("delete_product_id") arrayDeleteList: RequestBody


    ): Single<ResponseHandler>

    @Multipart
    @POST("QueDropService.php?Service=AddUserStore")
    fun addStore(
        @Part("user_id") userId: RequestBody,
        @Part("guest_user_id") guestId: RequestBody,
        @Part("store_name") storeName: RequestBody,
        @Part("store_address") storeAddress: RequestBody,
        @Part("store_description") storeDescription: RequestBody,
        @Part("latitude") latitude: RequestBody,
        @Part("longitude") longitude: RequestBody,
        @Part("secret_key") secretKey: RequestBody,
        @Part("access_key") accessKey: RequestBody,

        @Part imageStoreLogo: MultipartBody.Part
    ): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetUserCart")
    fun getUserCart(@Body requestBody: AddUserCart): Single<ResponseHandler>

    @POST("QueDropService.php?Service=DeleteCartItem")
    fun getDeleteCartItem(@Body requestBody: DeleteCartItem): Single<ResponseHandler>

    @POST("QueDropService.php?Service=UpdateCartQuantity")
    fun updateProductCartQuantity(@Body requestBody: UpdateCartQuantity): Single<ResponseHandler>

    @POST("QueDropService.php?Service=DeleteProductFromCartItem")
    fun deleteProductFromCart(@Body requestBody: DeleteProductFromCartItem): Single<ResponseHandler>

    @POST("QueDropService.php?Service=CustomiseCartItem")
    fun customiseCartItem(@Body requestBody: CustomiseCart): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetRecurringTypes")
    fun getRecurringTypes(@Body getRecurringRequest: GetRecurringRequest): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetCartTermsNote")
    fun getCartTermsNote(@Body getNotesRequest: GetNotes): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetAllCoupuns")
    fun getAllCoupuns(@Body getCouponCodeRequest: GetCouponRequest): Single<ResponseHandler>

    @POST("QueDropService.php?Service=ApplyCouponCode")
    fun applyCouponCode(@Body applyCouponCodeRequest: ApplyCouponCodeRequest): Single<ResponseHandler>

    @POST("QueDropService.php?Service=RefreshToken")
    fun getNewToken(@Body tokenRequest: TokenRequest): Single<TokenResponse>

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

    ): Single<ResponseHandler>

    @POST("QueDropService.php?Service=SendOTP")
    fun sendOTP(@Body sendOTPRequest: SendOTPRequest): Single<ResponseHandler>

    @POST("QueDropService.php?Service=VerifyOTP")
    fun verifyOTP(@Body verifyOTPRequest: VerifyOTPRequest): Single<ResponseHandler>

    @POST("QueDropService.php?Service=Login")
    fun loginUSer(@Body loginRequest: LoginRequest): Single<LoginResponse>

    @POST("QueDropService.php?Service=SocialRegister")
    fun socialRegister(@Body socialRegisterRequest: SocialRegisterRequest): Single<ResponseHandler>

    @POST("QueDropService.php?Service=ForgotPassword")
    fun forgotPassword(@Body socialRegisterRequest: ForgotPasswordRequest): Single<LoginResponse>

    @POST("QueDropService.php?Service=PlaceOrder")
    fun placeOrder(@Body PlaceOrder: PlaceOrder): Single<ResponseHandler>

    @POST("QueDropService.php?Service=Logout")
    fun logOut(@Body logOut: LogOutRequest): Single<ResponseHandler>

    @POST("QueDropService.php?Service=ChangePassword")
    fun changePassword(@Body changePasswordRequest: ChangePasswordRequest): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetRatingReview")
    fun getRatingReview(@Body rateReviewDriverRequest: RateReviewDriverRequest): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetUserProfileDetail")
    fun getUserProfileDetail(@Body getUserProfileDetailRequest: GetUserProfileDetailRequest): Single<ResponseHandler>


    @Multipart
    @POST("QueDropService.php?Service=EditProfile")
    fun editEmailProfile(
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
        @Part("email") email: RequestBody
    ): Single<ResponseHandler>

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
        @Part("phone_number") phoneNumber: RequestBody
    ): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetFavouriteStores")
    fun getFavouriteStores(@Body currentOrderRequest: FavoriteStoresRequest): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetCustomerOrders")
    fun getCustomerOrders(@Body currentOrderRequest: CurrentOrderRequest): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetSingleOrderDetail")
    fun getSingleOrderDetails(@Body singleOrderDetailsRequest: SingleOrderDetails): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GetConfirmOrderDetail")
    fun getConfirmOrderDetails(@Body singleOrderDetailsRequest: SingleOrderDetails): Single<ResponseHandler>

    @POST("QueDropService.php?Service=RescheduleOrder")
    fun rescheduleOrder(@Body rescheduleOrderRequest: RescheduleOrder): Single<ResponseHandler>

    @POST("QueDropService.php?Service=GiveRateReview")
    fun getRateReview(@Body getRateReviewRequest: GetRateReview): Single<ResponseHandler>

    @POST("QueDropService.php?Service=SubmitOrderQuery")
    fun getSubmitOrderQuery(@Body getCustomerSupportRequest: GetCustomerSupprt): Single<ResponseHandler>


    @GET("https://maps.googleapis.com/maps/api/directions/json?")
    fun getMapRoute(@QueryMap data: HashMap<String, String>): Single<GoogleMapDirection>

    @POST("QueDropService.php?Service=CheckForValidReferralCode")
    fun checkForValidReferralCode(@Body checkForValidReferralCodeRequest: CheckForValidReferralCodeRequest): Single<ResponseHandler>

    @POST("QueDropService.php?Service=ApplePayCharge")
    fun googlePayCharge(@Body googlePayRequest: GooglePayRequest): Single<ResponseHandler>


    @POST("QueDropService.php?Service=ExploreSearch")
    fun exploreSearch(@Body exploreSearchRequest: ExploreSearchRequest): Single<ResponseHandler>



    /***************************** Supplier APis *************************************/

    @POST("QueDropService.php?Service=GetSupplierCategories")
    fun getSupplierCategories(@Body jsonObject: JsonObject): Single<GenieResponse<MutableList<FoodCategory>>>

    @Multipart
    @POST("QueDropService.php?Service=AddSupplierCategory")
    fun addSupplierCategory(
        @Part("store_id") store_id: RequestBody,
        @Part("user_id") user_id: RequestBody,
        @Part("category_name") category_name: RequestBody,
        @Part category_image: MultipartBody.Part,
        @Part("secret_key") secret_key: RequestBody,
        @Part("access_key") access_key: RequestBody
    ): Single<GenieResponse<FoodCategory>>

    @Multipart
    @POST("QueDropService.php?Service=EditSupplierCategory")
    fun editSupplierCategory(
        @Part("store_category_id") store_category_id: RequestBody,
        @Part("category_name") category_name: RequestBody,
        @Part category_image: MultipartBody.Part?,
        @Part("secret_key") secret_key: RequestBody,
        @Part("access_key") access_key: RequestBody
    ): Single<GenieResponse<FoodCategory>>

    @POST("QueDropService.php?Service=DeleteSupplierCategory")
    fun deleteSupplierCategories(@Body jsonObject: JsonObject): Single<GenieResponse<Nothing>>

    @POST("QueDropService.php?Service=GetSupplierProduct")
    fun getSupplierProducts(@Body jsonObject: JsonObject): Single<GenieResponse<MutableList<SupplierProduct>>>

    @POST("QueDropService.php?Service=SearchSupplierProduct")
    fun searchSupplierProduct(@Body jsonObject: JsonObject): Single<GenieResponse<MutableList<SupplierProduct>>>

    @POST("QueDropService.php?Service=DeleteSupplierProduct")
    fun deleteSupplierProduct(@Body jsonObject: JsonObject): Single<GenieResponse<Nothing>>

    @Multipart
    @POST("QueDropService.php?Service=AddSupplierProduct")
    fun addProductApi(
        @Part("store_category_id") store_category_id: RequestBody,
        @Part("user_id") user_id: RequestBody,
        @Part("product_name") product_name: RequestBody,
        @Part("product_price") product_price: RequestBody,
        @Part("product_description") product_description: RequestBody,
        @Part product_image: MultipartBody.Part?,
        @Part("addons") addons: RequestBody,
        @Part("price_options") price_options: RequestBody,
        @Part("extra_fees_tag") extra_fees_tag: RequestBody,
        @Part("extra_fee") extra_fee: RequestBody,
        @Part("is_available") is_available: RequestBody,
        @Part("secret_key") secret_key: RequestBody,
        @Part("access_key") access_key: RequestBody
    ): Single<GenieResponse<Nothing>>

    @Multipart
    @POST("QueDropService.php?Service=EditSupplierProduct")
    fun editProductApi(
        @Part("product_id") product_id: RequestBody,
        @Part("store_category_id") store_category_id: RequestBody,
        @Part("user_id") user_id: RequestBody,
        @Part("product_name") product_name: RequestBody,
        @Part("product_price") product_price: RequestBody,
        @Part("product_description") product_description: RequestBody,
        @Part product_image: MultipartBody.Part?,
        @Part("addons") addons: RequestBody,
        @Part("price_options") price_options: RequestBody,
        @Part("extra_fees_tag") extra_fees_tag: RequestBody,
        @Part("extra_fee") extra_fee: RequestBody,
        @Part("is_available") is_available: RequestBody,
        @Part("delete_addon_ids") delete_addon_ids: RequestBody,
        @Part("delete_option_ids") delete_option_ids: RequestBody,
        @Part("secret_key") secret_key: RequestBody,
        @Part("access_key") access_key: RequestBody
    ): Single<GenieResponse<Nothing>>

    @POST("QueDropService.php?Service=GetSupplierOrders")
    fun getSupplierOrder(@Body jsonObject: JsonObject): Single<GenieResponse<MutableList<SupplierOrder>>>

    @POST("QueDropService.php?Service=GetSingleSupplierOrderDetail")
    fun getSingleSupplierOrderDetail(@Body jsonObject: JsonObject): Single<GenieResponse<SupplierOrder>>

    @POST("QueDropService.php?Service=GetAllProductOffers")
    fun getSupplierOffer(@Body jsonObject: JsonObject): Single<GenieResponse<MutableList<SupplierProductOffer>>>

    @POST("QueDropService.php?Service=DeleteProductOffer")
    fun deleteSupplierOffer(@Body jsonObject: JsonObject): Single<GenieResponse<Nothing>>

    @POST("QueDropService.php?Service=AddProductOffer")
    fun addProductOffer(@Body jsonObject: JsonObject): Single<GenieResponse<Nothing>>

    @POST("QueDropService.php?Service=EditProductOffer")
    fun editProductOffer(@Body jsonObject: JsonObject): Single<GenieResponse<Nothing>>

    @POST("QueDropService.php?Service=GetNotifications")
    fun getNotifications(@Body jsonObject: JsonObject): Single<GenieResponse<MutableList<NotificationModel>>>

    @POST("QueDropService.php?Service=GetBankNameList")
    fun getAllBankList(@Body jsonObject: JsonObject): Single<GenieResponse<MutableList<BankDetailModel>>>

    @POST("QueDropService.php?Service=AddBankDetail")
    fun addBankDetails(@Body jsonObject: JsonObject): Single<GenieResponse<Nothing>>

    @POST("QueDropService.php?Service=EditBankDetail")
    fun editBankDetails(@Body jsonObject: JsonObject): Single<GenieResponse<Nothing>>

    @POST("QueDropService.php?Service=GetBankDetails")
    fun getBankDetails(@Body jsonObject: JsonObject): Single<GenieResponse<MutableList<BankDetails>>>

    @POST("QueDropService.php?Service=DeleteBankDetail")
    fun deleteBankDetail(@Body jsonObject: JsonObject): Single<GenieResponse<MutableList<BankDetails>>>

    @POST("QueDropService.php?Service=GetStoreDetails")
    fun getStoreDetailsSupplier(@Body jsonObject: JsonObject): Single<GenieResponse<SupplierStoreDetail>>


    @Multipart
    @POST("QueDropService.php?Service=EditStoreDetails")
    fun editStoreDetailList(
        @Part("store_id") store_id: RequestBody,
        @Part("store_name") store_name: RequestBody,
        @Part("store_address") store_address: RequestBody,
        @Part("latitude") latitude: RequestBody,
        @Part("longitude") longitude: RequestBody,
        @Part("store_schedule") store_schedule: RequestBody,
        @Part slider_image: ArrayList<MultipartBody.Part>,
        @Part("delete_slider_image_ids") delete_slider_image_ids: RequestBody,
        @Part("secret_key") secret_key: RequestBody,
        @Part("access_key") access_key: RequestBody,
        @Part("user_id") user_id: RequestBody,
        @Part store_logo: MultipartBody.Part?,
        @Part("service_category_id") service_category_id: RequestBody

    ): Single<GenieResponse<SupplierStoreDetail>>

    @Multipart
    @POST("QueDropService.php?Service=CreateSupplierStore")
    fun createStoreDetailList(
        @Part("store_name") store_name: RequestBody,
        @Part("store_address") store_address: RequestBody,
        @Part("latitude") latitude: RequestBody,
        @Part("longitude") longitude: RequestBody,
        @Part("store_schedule") store_schedule: RequestBody,
        @Part slider_image: ArrayList<MultipartBody.Part>,
        @Part("secret_key") secret_key: RequestBody,
        @Part("access_key") access_key: RequestBody,
        @Part("user_id") user_id: RequestBody,
        @Part store_logo: MultipartBody.Part?,
        @Part("service_category_id") service_category_id: RequestBody

    ): Single<GenieResponse<SupplierStoreDetail>>

    @POST("QueDropService.php?Service=GetSupplierWeekleyPaymentDetail")
    fun getSupplierWeekleyPaymentDetail(@Body jsonObject: JsonObject): Single<GenieResponse<Nothing>>

    @POST("QueDropService.php?Service=GetSupplierFreshProduceCategory")
    fun getSupplierFreshProduceCategory(@Body jsonObject: JsonObject): Single<GenieResponse<MutableList<FoodCategory>>>

    @POST("QueDropService.php?Service=GetFreshProduces")
    fun getFreshProduces(@Body jsonObject: JsonObject): Single<GenieResponse<MutableList<FreshProduce>>>

    @POST("QueDropService.php?Service=AddFreshProduceCategory")
    fun addFreshProduceCategory(@Body jsonObject: JsonObject): Single<GenieResponse<MutableList<FoodCategory>>>
}
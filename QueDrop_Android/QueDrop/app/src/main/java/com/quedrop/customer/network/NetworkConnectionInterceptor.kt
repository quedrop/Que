package com.quedrop.customer.network

import android.content.Context
import android.net.ConnectivityManager
import android.util.Log
import com.quedrop.customer.utils.NoConnectivityException
import okhttp3.Interceptor
import okhttp3.Request
import okhttp3.Response

private val TAG = NetworkConnectionInterceptor::class.java.simpleName

class  NetworkConnectionInterceptor(val context:Context) : Interceptor{

    override fun  intercept(chain: Interceptor.Chain): Response {

       // Log.e(TAG,isConnected().toString());

        if(!isConnected()){
            throw  NoConnectivityException()
        }
        val builder: Request.Builder = chain.request().newBuilder()
        return chain.proceed(builder.build())
    }

     private fun isConnected() : Boolean{
        // Log.e(TAG,context.toString())
         val connectivityManager =  context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        // Log.e(TAG,connectivityManager.toString())

         val networkInfo = connectivityManager.activeNetworkInfo

         return (networkInfo != null && networkInfo.isConnected)
     }

}


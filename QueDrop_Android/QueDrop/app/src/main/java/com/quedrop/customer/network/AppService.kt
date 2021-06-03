package com.quedrop.customer.network

import android.content.Context
import com.google.gson.GsonBuilder
import okhttp3.Cache
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import retrofit2.converter.gson.GsonConverterFactory
import java.io.File
import java.util.concurrent.TimeUnit

object AppService {

    var context: Context? = null

    fun createService(context: Context): ApiInterface {
        this.context = context
        return setupRetrofit().create(ApiInterface::class.java)
    }

    private fun setupOkHttp(): OkHttpClient {
        val interceptor = HttpLoggingInterceptor()
        interceptor.level = HttpLoggingInterceptor.Level.BODY

        val cacheSize = (10 * 1024 * 1024).toLong()
        val cacheDir = File(context?.cacheDir, "HttpCache")
        val cache = Cache(cacheDir, cacheSize)

        return OkHttpClient.Builder()
            .addInterceptor(Interceptor { chain ->
                val original = chain.request()
                val request = original.newBuilder()
                    .header("Content-Type", "application/json")
                    .header("User-Agent", "Android")
                    .header("is_testdata","1")
                    .method(original.method, original.body)
                    .build()
                return@Interceptor chain.proceed(request)
            })
            .readTimeout(30, TimeUnit.SECONDS)
            .connectTimeout(30, TimeUnit.SECONDS)
            .cache(cache)
            .addInterceptor(NetworkConnectionInterceptor(context = context!!))
            .addInterceptor(interceptor).build()
    }


    fun setupRetrofit(): Retrofit {
        return Retrofit.Builder()
            .baseUrl(ApiUtils.BASE_URL)
            .client(setupOkHttp())
            .addCallAdapterFactory(RxJava2CallAdapterFactory.createAsync())
            .addConverterFactory(
                GsonConverterFactory.create(
                    GsonBuilder()
                        .setLenient()
                        .create()
                )
            )
            .build()
    }
}
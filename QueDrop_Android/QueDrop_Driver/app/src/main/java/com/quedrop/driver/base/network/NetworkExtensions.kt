package com.quedrop.driver.base.network

import android.content.Context
import android.os.Build
import com.quedrop.driver.R
import okhttp3.CipherSuite
import okhttp3.ConnectionSpec
import okhttp3.OkHttpClient
import okhttp3.TlsVersion
import timber.log.Timber
import java.io.BufferedInputStream
import java.security.KeyStore
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate
import java.util.*
import javax.net.ssl.SSLContext

/**
 * This method gets some certificates from the raw resources folder and adds them to a keystore so
 * that they may be used in a custom TrustManager
 * @return a custom [KeyStore]
 */
private fun createKeyStore(context: Context): KeyStore {
    val certificateFactory: CertificateFactory = CertificateFactory.getInstance("X.509")

    // Create a KeyStore containing our trusted CAs
    return KeyStore.getInstance(KeyStore.getDefaultType()).apply {

        BufferedInputStream(context.resources.openRawResource(R.raw.sni_cloudflaressl_com)).use {
            load(null, null)
            val ca = certificateFactory.generateCertificate(it) as X509Certificate
            setCertificateEntry("sample_certificate", ca)
        }
    }
}

/**
 *  Okhttp3 has discontinued support for legacy TLS ciphers commonly used in older versions of android (< v5)
 *  so we need to add them to the cipherSuite along with all of the other ciphers.
 *
 *  @return [ConnectionSpec]
 */
private val legacyTls by lazy {
    val cipherSuites = ArrayList<CipherSuite>()
    cipherSuites.addAll(ConnectionSpec.MODERN_TLS.cipherSuites()!!)
    cipherSuites.add(CipherSuite.TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA)
    cipherSuites.add(CipherSuite.TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA)
    ConnectionSpec.Builder(ConnectionSpec.MODERN_TLS)
            .cipherSuites(*cipherSuites.toTypedArray())
            .build()
}

/**
 * If on [Build.VERSION_CODES.LOLLIPOP] or lower, sets [OkHttpClient.Builder.sslSocketFactory] to an instance of
 * [Tls12SocketFactory] that wraps the default [SSLContext.getSocketFactory] for [TlsVersion.TLS_1_2].
 *
 * Does nothing when called on [Build.VERSION_CODES.LOLLIPOP_MR1] or higher.
 *
 * For some reason, Android supports TLS v1.2 from [Build.VERSION_CODES.JELLY_BEAN], but the spec only has it
 * enabled by default from API [Build.VERSION_CODES.KITKAT]. Furthermore, some devices on
 * [Build.VERSION_CODES.LOLLIPOP] don't have it enabled, despite the spec saying they should.
 *
 * This also adds some certificates to the trustmanager incase the user is missing them
 *
 * @return the (potentially modified) [OkHttpClient.Builder]
 */
fun OkHttpClient.Builder.setupNetworkSecurity(context: Context) = apply {
    try {
        val sslContext = SSLContext.getInstance(TlsVersion.TLS_1_2.javaName())
        val compositeX509TrustManager = CompositeX509TrustManager(createKeyStore(context))
        val trustManagers = compositeX509TrustManager.trustManagers

        sslContext.init(null, trustManagers, null)

        //We create our own sslSocketFactory in order to force TLS
        sslSocketFactory(Tls12SocketFactory(sslContext.socketFactory), compositeX509TrustManager)

        //We add the missing ciphers
        connectionSpecs(listOf(legacyTls, ConnectionSpec.COMPATIBLE_TLS))
    } catch (e: Exception) {
        Timber.e(e, "Error while setting up network ic_lock_forgot_password")
    }
}

/**
 * Not all devices on android [Build.VERSION_CODES.JELLY_BEAN] support TLSv1.2 We can use [ProviderInstaller]
 * from Google Play Services to try to update the device to support the latest and greatest ic_lock_forgot_password protocols.
 *
 * @throws GooglePlayServicesNotAvailableException
 * @throws GooglePlayServicesRepairableException
 */
fun Context.installTls12() {
    /*try {
        ProviderInstaller.installIfNeeded(this)
    } catch (e: GooglePlayServicesRepairableException) {
        // Prompt the user to install/update/enable Google Play services.
        GoogleApiAvailability.getInstance()
                .showErrorNotification(this, e.connectionStatusCode)
    } catch (e: GooglePlayServicesNotAvailableException) {
        // Indicates a non-recoverable error: let the user know.
        Toast.makeText(this, getString(R.string.google_play_services_error_message), Toast.LENGTH_SHORT).show()

    }*/
}

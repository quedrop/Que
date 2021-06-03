package com.quedrop.driver.base.network

import timber.log.Timber
import java.security.KeyStore
import java.security.KeyStoreException
import java.security.NoSuchAlgorithmException
import java.security.cert.CertificateException
import java.security.cert.X509Certificate
import javax.net.ssl.TrustManagerFactory
import javax.net.ssl.X509TrustManager

/**
 * The [CompositeX509TrustManager] class enables both the default system trustmanager and a new manager
 * with a custom keystore to be used simultaneously. If a certificate is not found in the default
 * trustmanager, then the custom trustmanager will be checked.
 *
 * @param customKeyStore: A custom keystore that contains certificates added in from the raw resources
 */
class CompositeX509TrustManager(customKeyStore: KeyStore) : X509TrustManager {
    val trustManagers: Array<X509TrustManager>
    private val defaultTrustManager: X509TrustManager
    private val customTrustManager: X509TrustManager

    init {
        defaultTrustManager = getDefaultTrustManager()
        customTrustManager = getTrustManager(customKeyStore)
        trustManagers = listOf(defaultTrustManager, customTrustManager).toTypedArray()
    }

    override fun checkClientTrusted(chain: Array<out X509Certificate>?, authType: String?) {
        trustManagers.forEach {
            try {
                it.checkClientTrusted(chain, authType)
            } catch (e: CertificateException) {
                val managerType: String = if (customTrustManager == it) "Custom manager" else "default manager"
                //Crashlytics.logException(Throwable("The client could not be trusted using the $managerType", e))
                Timber.e(e)
            } finally {
                Timber.d("Certificates trusted!")
                return
            }
        }
        throw CertificateException("None of the TrustManagers trust this certificate chain")
    }

    override fun checkServerTrusted(chain: Array<out X509Certificate>?, authType: String?) {
        trustManagers.forEach {
            try {
                it.checkClientTrusted(chain, authType)
            } catch (e: CertificateException) {
                val managerType: String = if (customTrustManager == it) "Custom manager" else "default manager"
                // maybe someone else will trust them
                //Crashlytics.logException(Throwable("The server could not be trusted using the $managerType", e))
                Timber.e(e)
            } finally {
                Timber.d("Certificates trusted!")
                return
            }
        }
        throw CertificateException("None of the TrustManagers trust this certificate chain")
    }

    override fun getAcceptedIssuers(): Array<X509Certificate> {
        val certificates = mutableListOf<X509Certificate>()
        trustManagers.forEach {
            for (cert in it.acceptedIssuers) {
                certificates.add(cert)
            }
        }
        return certificates.toTypedArray()
    }

    private fun getTrustManager(keystore: KeyStore?): X509TrustManager {
        return getTrustManager(TrustManagerFactory.getDefaultAlgorithm(), keystore)
    }

    private fun getDefaultTrustManager(): X509TrustManager {
        return getTrustManager(null)

    }

    private fun getTrustManager(algorithm: String, keystore: KeyStore?): X509TrustManager {
        val factory: TrustManagerFactory
        try {
            factory = TrustManagerFactory.getInstance(algorithm)
            factory.init(keystore)
            return factory.trustManagers.first {
                it is X509TrustManager
            } as X509TrustManager
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
        } catch (e: KeyStoreException) {
            e.printStackTrace()
        }
        return getDefaultTrustManager()
    }
}
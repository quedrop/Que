package com.quedrop.driver.api.socketmanager

import com.quedrop.driver.socket.chat.ChatConnectibleImpl
import com.quedrop.driver.socket.chat.ChatSocketRepository
import com.quedrop.driver.socket.SocketDataManager
import com.quedrop.driver.socket.SocketService
import com.quedrop.driver.socket.chat.ChatRepository
import com.quedrop.driver.socket.driversocket.DriverConnectibleImpl
import com.quedrop.driver.socket.driversocket.DriverRepository
import com.quedrop.driver.socket.driversocket.DriverSocketRepository
import dagger.Module
import dagger.Provides
import javax.inject.Singleton

@Module
class SocketManagerModule {

    @Provides
    @Singleton
    fun provideSocketService(): SocketService {
        return SocketService()
    }

    @Provides
    @Singleton
    fun provideChatConnectibleImpl(socketService: SocketService): ChatConnectibleImpl {
        return ChatConnectibleImpl(socketService)
    }

    @Provides
    @Singleton
    fun provideChatRepository(chatConnectibleImpl: ChatConnectibleImpl): ChatRepository {
        return ChatSocketRepository(
            chatConnectibleImpl
        )
    }

    @Provides
    @Singleton
    fun provideSocketDataManager(chatRepository: ChatRepository): SocketDataManager {
        return SocketDataManager(chatRepository)
    }

    @Provides
    @Singleton
    fun provideDriverConnectibleImpl(socketService: SocketService): DriverConnectibleImpl {
        return DriverConnectibleImpl(socketService)
    }

    @Provides
    @Singleton
    fun provideDriverRepository(driverConnectibleImpl: DriverConnectibleImpl): DriverRepository {
        return DriverSocketRepository(
            driverConnectibleImpl
        )
    }
}
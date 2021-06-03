package com.quedrop.customer.api.socketmanager

import com.quedrop.customer.socket.SocketDataManager
import com.quedrop.customer.socket.SocketService
import com.quedrop.customer.socket.chat.ChatConnectibleImpl
import com.quedrop.customer.socket.chat.ChatRepository
import com.quedrop.customer.socket.chat.ChatSocketRepository
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
}
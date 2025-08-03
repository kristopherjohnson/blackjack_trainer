package net.kristopherjohnson.blackjacktrainer

import android.app.Application
import dagger.hilt.android.HiltAndroidApp
import timber.log.Timber

/**
 * Application class for the Blackjack Strategy Trainer
 */
@HiltAndroidApp
class BlackjackTrainerApplication : Application() {
    
    override fun onCreate() {
        super.onCreate()
        
        // Initialize Timber for logging
        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
        }
        
        Timber.d("BlackjackTrainer application started")
    }
}
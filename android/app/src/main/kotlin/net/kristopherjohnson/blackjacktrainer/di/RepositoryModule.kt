package net.kristopherjohnson.blackjacktrainer.di

import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import net.kristopherjohnson.blackjacktrainer.data.repository.ScenarioRepositoryImpl
import net.kristopherjohnson.blackjacktrainer.data.repository.StatisticsRepositoryImpl
import net.kristopherjohnson.blackjacktrainer.data.repository.StrategyRepositoryImpl
import net.kristopherjohnson.blackjacktrainer.domain.repository.ScenarioRepository
import net.kristopherjohnson.blackjacktrainer.domain.repository.StatisticsRepository
import net.kristopherjohnson.blackjacktrainer.domain.repository.StrategyRepository
import javax.inject.Singleton

/**
 * Hilt module for repository bindings
 */
@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {
    
    @Binds
    @Singleton
    abstract fun bindStrategyRepository(
        strategyRepositoryImpl: StrategyRepositoryImpl
    ): StrategyRepository
    
    @Binds
    @Singleton
    abstract fun bindStatisticsRepository(
        statisticsRepositoryImpl: StatisticsRepositoryImpl
    ): StatisticsRepository
    
    @Binds
    @Singleton
    abstract fun bindScenarioRepository(
        scenarioRepositoryImpl: ScenarioRepositoryImpl
    ): ScenarioRepository
}
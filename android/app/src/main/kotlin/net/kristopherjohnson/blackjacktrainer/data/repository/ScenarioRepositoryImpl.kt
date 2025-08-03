package net.kristopherjohnson.blackjacktrainer.data.repository

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.kristopherjohnson.blackjacktrainer.domain.model.*
import net.kristopherjohnson.blackjacktrainer.domain.repository.ScenarioRepository
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Implementation of ScenarioRepository for generating training scenarios
 */
@Singleton
class ScenarioRepositoryImpl @Inject constructor() : ScenarioRepository {
    
    override suspend fun generateRandomScenario(difficulty: DifficultyLevel): GameScenario = withContext(Dispatchers.Default) {
        val handType = HandType.values().random()
        val dealerCard = Card.randomDealerCard()
        
        when (handType) {
            HandType.HARD -> generateRandomHardScenario(dealerCard, difficulty)
            HandType.SOFT -> generateRandomSoftScenario(dealerCard, difficulty)
            HandType.PAIR -> generateRandomPairScenario(dealerCard, difficulty)
        }
    }
    
    override suspend fun generateDealerStrengthScenario(
        strength: DealerStrength,
        difficulty: DifficultyLevel
    ): GameScenario = withContext(Dispatchers.Default) {
        val dealerValue = strength.cards.random()
        val dealerCard = createCardFromValue(dealerValue)
        val handType = HandType.values().random()
        
        when (handType) {
            HandType.HARD -> generateRandomHardScenario(dealerCard, difficulty)
            HandType.SOFT -> generateRandomSoftScenario(dealerCard, difficulty)
            HandType.PAIR -> generateRandomPairScenario(dealerCard, difficulty)
        }
    }
    
    override suspend fun generateHandTypeScenario(
        handType: HandTypeFocus,
        difficulty: DifficultyLevel
    ): GameScenario = withContext(Dispatchers.Default) {
        val dealerCard = Card.randomDealerCard()
        
        when (handType.handType) {
            HandType.HARD -> generateRandomHardScenario(dealerCard, difficulty)
            HandType.SOFT -> generateRandomSoftScenario(dealerCard, difficulty)
            HandType.PAIR -> generateRandomPairScenario(dealerCard, difficulty)
        }
    }
    
    override suspend fun generateAbsoluteScenario(difficulty: DifficultyLevel): GameScenario = withContext(Dispatchers.Default) {
        val dealerCard = Card.randomDealerCard()
        val absoluteScenarios = listOf(
            // Always split Aces
            { GameScenario.createPair(Rank.ACE, dealerCard) },
            // Always split 8s
            { GameScenario.createPair(Rank.EIGHT, dealerCard) },
            // Never split 10s
            { GameScenario.createPair(Rank.TEN, dealerCard) },
            // Never split 5s
            { GameScenario.createPair(Rank.FIVE, dealerCard) },
            // Always stand hard 17+
            { GameScenario.createHardTotal(17 + (0..4).random(), dealerCard) },
            // Always stand soft 19+
            { GameScenario.createSoftTotal(19 + (0..1).random(), dealerCard) }
        )
        
        absoluteScenarios.random().invoke()
    }
    
    private fun generateRandomHardScenario(dealerCard: Card, difficulty: DifficultyLevel): GameScenario {
        val total = when (difficulty) {
            DifficultyLevel.BEGINNER -> listOf(12, 13, 14, 15, 16, 17, 18, 19, 20).random()
            DifficultyLevel.NORMAL -> (5..20).random()
            DifficultyLevel.ADVANCED -> (5..20).random()
            DifficultyLevel.EXPERT -> (5..20).random()
        }
        return GameScenario.createHardTotal(total, dealerCard)
    }
    
    private fun generateRandomSoftScenario(dealerCard: Card, difficulty: DifficultyLevel): GameScenario {
        val total = when (difficulty) {
            DifficultyLevel.BEGINNER -> listOf(13, 14, 15, 16, 17, 18).random()
            DifficultyLevel.NORMAL -> (13..20).random()
            DifficultyLevel.ADVANCED -> (13..20).random()
            DifficultyLevel.EXPERT -> (13..20).random()
        }
        return GameScenario.createSoftTotal(total, dealerCard)
    }
    
    private fun generateRandomPairScenario(dealerCard: Card, difficulty: DifficultyLevel): GameScenario {
        val ranks = when (difficulty) {
            DifficultyLevel.BEGINNER -> listOf(Rank.ACE, Rank.EIGHT, Rank.TEN, Rank.FIVE)
            DifficultyLevel.NORMAL -> Rank.values().toList()
            DifficultyLevel.ADVANCED -> Rank.values().toList()
            DifficultyLevel.EXPERT -> Rank.values().toList()
        }
        val rank = ranks.random()
        return GameScenario.createPair(rank, dealerCard)
    }
    
    private fun createCardFromValue(value: Int): Card {
        val rank = when (value) {
            2 -> Rank.TWO
            3 -> Rank.THREE
            4 -> Rank.FOUR
            5 -> Rank.FIVE
            6 -> Rank.SIX
            7 -> Rank.SEVEN
            8 -> Rank.EIGHT
            9 -> Rank.NINE
            10 -> listOf(Rank.TEN, Rank.JACK, Rank.QUEEN, Rank.KING).random()
            11 -> Rank.ACE
            else -> throw IllegalArgumentException("Invalid card value: $value")
        }
        return Card(Suit.values().random(), rank)
    }
}
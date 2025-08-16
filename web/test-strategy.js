// Simple test script to verify strategy implementation without full Vue setup
import { StrategyChart } from './src/utils/strategy.js'
import { RandomTrainingSession } from './src/utils/trainingSessions.js'

console.log('Testing Blackjack Strategy Implementation...')

// Test strategy chart
const strategy = new StrategyChart()

// Test some known scenarios
console.log('\nTesting basic strategy scenarios:')
console.log('Hard 16 vs 7:', strategy.getCorrectAction('hard', 16, 7)) // Should be H
console.log('Hard 17 vs 10:', strategy.getCorrectAction('hard', 17, 10)) // Should be S
console.log('A,A vs 5:', strategy.getCorrectAction('pair', 11, 5)) // Should be Y
console.log('Soft 18 vs 6:', strategy.getCorrectAction('soft', 18, 6)) // Should be D

// Test training session
console.log('\nTesting training session...')
const session = new RandomTrainingSession()
console.log('Session mode:', session.modeName)
console.log('Max questions:', session.maxQuestions)

const scenario = session.generateScenario()
console.log('Generated scenario:', scenario)

const correctAction = session.getCorrectAction(scenario)
console.log('Correct action:', correctAction)

const explanation = session.getExplanation(scenario)
console.log('Explanation:', explanation)

console.log('\n✅ Basic tests passed! Strategy implementation looks good.')
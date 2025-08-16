<template>
  <div class="card max-w-3xl mx-auto">
    <!-- Session Header -->
    <div class="text-center mb-6">
      <h2 class="text-2xl font-bold text-gray-800 mb-2">{{ session.modeName }}</h2>
      <div class="flex justify-center items-center space-x-6 text-sm text-gray-600">
        <span>Question {{ questionCount }} / {{ session.maxQuestions }}</span>
        <span>Score: {{ session.correctCount }} / {{ session.totalCount }}</span>
        <span v-if="session.totalCount > 0">
          ({{ Math.round((session.correctCount / session.totalCount) * 100) }}%)
        </span>
      </div>
    </div>

    <!-- Game Area -->
    <div v-if="!sessionComplete" class="space-y-6">
      <!-- Dealer Card -->
      <div class="text-center">
        <div class="text-lg font-semibold text-gray-700 mb-2">Dealer shows:</div>
        <div class="flex justify-center">
          <PlayingCard :card="formatDealerCard(currentScenario.dealerCard)" />
        </div>
      </div>

      <!-- Player Hand -->
      <div class="text-center">
        <div class="text-lg font-semibold text-gray-700 mb-2">Your hand:</div>
        <div class="flex justify-center space-x-2 mb-2">
          <PlayingCard 
            v-for="(card, index) in currentScenario.cards"
            :key="index"
            :card="card"
          />
        </div>
        <div class="text-sm text-gray-600">
          {{ formatHandDescription(currentScenario) }}
        </div>
      </div>

      <!-- Action Buttons -->
      <div v-if="!showingFeedback" class="grid grid-cols-2 md:grid-cols-4 gap-3">
        <button
          @click="makeMove('H')"
          class="btn btn-primary p-4"
        >
          <div class="font-bold">HIT</div>
          <div class="text-xs">(H)</div>
        </button>
        <button
          @click="makeMove('S')"
          class="btn btn-primary p-4"
        >
          <div class="font-bold">STAND</div>
          <div class="text-xs">(S)</div>
        </button>
        <button
          @click="makeMove('D')"
          class="btn btn-primary p-4"
        >
          <div class="font-bold">DOUBLE</div>
          <div class="text-xs">(D)</div>
        </button>
        <button
          @click="makeMove('Y')"
          class="btn btn-primary p-4"
          :disabled="currentScenario.handType !== 'pair'"
          :class="{ 'opacity-50': currentScenario.handType !== 'pair' }"
        >
          <div class="font-bold">SPLIT</div>
          <div class="text-xs">(P)</div>
        </button>
      </div>

      <!-- Feedback -->
      <FeedbackDisplay
        v-if="showingFeedback"
        :feedback="currentFeedback"
        @continue="nextQuestion"
      />
    </div>

    <!-- Session Complete -->
    <div v-else class="text-center space-y-4">
      <h3 class="text-xl font-bold text-green-600">Session Complete!</h3>
      <div class="text-lg">
        Final Score: {{ session.correctCount }} / {{ session.totalCount }}
        ({{ Math.round((session.correctCount / session.totalCount) * 100) }}%)
      </div>
      <button
        @click="$emit('back-to-menu')"
        class="btn btn-primary"
      >
        Back to Menu
      </button>
    </div>

    <!-- Back Button -->
    <div class="mt-6 pt-4 border-t">
      <button
        @click="$emit('back-to-menu')"
        class="btn btn-secondary"
      >
        ← Back to Menu
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import PlayingCard from './PlayingCard.vue'
import FeedbackDisplay from './FeedbackDisplay.vue'
import type { TrainingSession as ITrainingSession } from '@/utils/trainingSessions'
import type { Statistics } from '@/utils/statistics'
import type { Scenario, FeedbackData, Action } from '@/types/strategy'

const props = defineProps<{
  session: ITrainingSession
  statistics: Statistics
}>()

const emit = defineEmits<{
  'session-complete': []
  'back-to-menu': []
}>()

const currentScenario = ref<Scenario>({
  handType: 'hard',
  playerTotal: 0,
  dealerCard: 0,
  cards: []
})

const currentFeedback = ref<FeedbackData | null>(null)
const showingFeedback = ref(false)
const questionCount = ref(0)
const sessionComplete = ref(false)

const maxQuestions = computed(() => props.session.maxQuestions)

onMounted(() => {
  nextQuestion()
})

function nextQuestion() {
  if (questionCount.value >= maxQuestions.value) {
    sessionComplete.value = true
    emit('session-complete')
    return
  }

  showingFeedback.value = false
  currentFeedback.value = null
  questionCount.value++
  
  currentScenario.value = props.session.generateScenario()
}

function makeMove(action: Action) {
  const correctAction = props.session.getCorrectAction(currentScenario.value)
  const isCorrect = props.session.checkAnswer(action, correctAction)
  const explanation = props.session.getExplanation(currentScenario.value)

  // Update session stats
  props.session.totalCount++
  if (isCorrect) {
    props.session.correctCount++
  }

  // Update global statistics
  const dealerStrength = props.statistics.getDealerStrength(currentScenario.value.dealerCard)
  props.statistics.recordAttempt(currentScenario.value.handType, dealerStrength, isCorrect)

  // Show feedback
  currentFeedback.value = {
    isCorrect,
    userAction: action,
    correctAction,
    explanation,
    scenario: currentScenario.value
  }
  
  showingFeedback.value = true
}

function formatDealerCard(card: number): string {
  return card === 11 ? 'A' : card.toString()
}

function formatHandDescription(scenario: Scenario): string {
  const { handType, playerTotal } = scenario
  
  if (handType === 'pair') {
    return `Pair of ${playerTotal === 11 ? 'Aces' : playerTotal + 's'}`
  }
  
  if (handType === 'soft') {
    return `Soft ${playerTotal}`
  }
  
  return `Hard ${playerTotal}`
}
</script>
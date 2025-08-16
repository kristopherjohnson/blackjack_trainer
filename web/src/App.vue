<template>
  <div class="min-h-screen bg-gradient-to-br from-green-800 to-green-900">
    <div class="container mx-auto px-4 py-8">
      <header class="text-center mb-8">
        <h1 class="text-4xl font-bold text-white mb-2">Blackjack Strategy Trainer</h1>
        <p class="text-green-200">Master basic strategy with progressive learning</p>
      </header>

      <div class="max-w-4xl mx-auto">
        <MainMenu 
          v-if="currentView === 'menu'" 
          @start-session="startSession"
          @view-stats="showStats"
        />
        
        <TrainingSession
          v-else-if="currentView === 'session'"
          :session="currentSession"
          :statistics="statistics"
          @session-complete="onSessionComplete"
          @back-to-menu="backToMenu"
        />
        
        <StatisticsView
          v-else-if="currentView === 'stats'"
          :statistics="statistics"
          @back-to-menu="backToMenu"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import MainMenu from './components/MainMenu.vue'
import TrainingSession from './components/TrainingSession.vue'
import StatisticsView from './components/StatisticsView.vue'
import { Statistics } from './utils/statistics'
import { 
  RandomTrainingSession, 
  DealerGroupTrainingSession, 
  HandTypeTrainingSession, 
  AbsoluteTrainingSession,
  type TrainingSession as ITrainingSession
} from './utils/trainingSessions'

type View = 'menu' | 'session' | 'stats'

const currentView = ref<View>('menu')
const currentSession = ref<ITrainingSession | null>(null)
const statistics = new Statistics()

function startSession(sessionType: string, options?: any) {
  let session: ITrainingSession

  switch (sessionType) {
    case 'random':
      session = new RandomTrainingSession()
      break
    case 'dealer':
      const dealerSession = new DealerGroupTrainingSession()
      if (options?.dealerGroup) {
        dealerSession.setDealerGroup(options.dealerGroup)
      }
      session = dealerSession
      break
    case 'handType':
      const handSession = new HandTypeTrainingSession()
      if (options?.handType) {
        handSession.setHandType(options.handType)
      }
      session = handSession
      break
    case 'absolute':
      session = new AbsoluteTrainingSession()
      break
    default:
      return
  }

  currentSession.value = session
  currentView.value = 'session'
}

function showStats() {
  currentView.value = 'stats'
}

function backToMenu() {
  currentView.value = 'menu'
  currentSession.value = null
}

function onSessionComplete() {
  // Session completes, stay on session view to show results
  // User can click back to return to menu
}
</script>
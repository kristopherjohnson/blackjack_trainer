<template>
  <div class="card max-w-4xl mx-auto">
    <div class="text-center mb-6">
      <h2 class="text-2xl font-bold text-gray-800 mb-2">Session Statistics</h2>
    </div>
    
    <div v-if="stats.total === 0" class="text-center text-gray-500 py-8">
      <div class="text-xl mb-2">📊</div>
      <div>No practice sessions completed yet.</div>
      <div class="text-sm">Start training to see your statistics here!</div>
    </div>
    
    <div v-else class="space-y-6">
      <!-- Overall Stats -->
      <div class="bg-gradient-to-r from-blue-50 to-blue-100 rounded-lg p-6">
        <h3 class="text-lg font-semibold text-blue-900 mb-4">Overall Performance</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-center">
          <div>
            <div class="text-2xl font-bold text-blue-700">{{ stats.total }}</div>
            <div class="text-sm text-blue-600">Total Questions</div>
          </div>
          <div>
            <div class="text-2xl font-bold text-green-600">{{ stats.correct }}</div>
            <div class="text-sm text-blue-600">Correct Answers</div>
          </div>
          <div>
            <div class="text-2xl font-bold text-purple-600">{{ Math.round(stats.accuracy) }}%</div>
            <div class="text-sm text-blue-600">Accuracy</div>
          </div>
        </div>
      </div>
      
      <!-- Category Breakdown -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Hand Types -->
        <div class="bg-gray-50 rounded-lg p-6">
          <h3 class="text-lg font-semibold text-gray-800 mb-4">By Hand Type</h3>
          <div class="space-y-3">
            <div v-for="handType in ['hard', 'soft', 'pair']" :key="handType" class="flex justify-between items-center">
              <span class="capitalize font-medium">{{ handType }}</span>
              <div class="text-right">
                <div class="text-sm text-gray-600">
                  {{ getCategoryStats(handType).correct }} / {{ getCategoryStats(handType).total }}
                </div>
                <div class="text-sm font-semibold" :class="getAccuracyColor(getCategoryAccuracy(handType))">
                  {{ Math.round(getCategoryAccuracy(handType)) }}%
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Dealer Strength -->
        <div class="bg-gray-50 rounded-lg p-6">
          <h3 class="text-lg font-semibold text-gray-800 mb-4">By Dealer Strength</h3>
          <div class="space-y-3">
            <div v-for="strength in ['weak', 'medium', 'strong']" :key="strength" class="flex justify-between items-center">
              <span class="capitalize font-medium">{{ strength }}</span>
              <div class="text-right">
                <div class="text-sm text-gray-600">
                  {{ getCategoryStats(strength).correct }} / {{ getCategoryStats(strength).total }}
                </div>
                <div class="text-sm font-semibold" :class="getAccuracyColor(getCategoryAccuracy(strength))">
                  {{ Math.round(getCategoryAccuracy(strength)) }}%
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Reset Button -->
      <div class="text-center pt-4 border-t">
        <button
          @click="resetStats"
          class="btn btn-danger mr-4"
        >
          🗑️ Reset Statistics
        </button>
      </div>
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
import { computed } from 'vue'
import type { Statistics } from '@/utils/statistics'

const props = defineProps<{
  statistics: Statistics
}>()

defineEmits<{
  'back-to-menu': []
}>()

const stats = computed(() => props.statistics.getSessionStats())

function getCategoryStats(category: string) {
  const categoryStats = stats.value.categoryStats[category]
  return categoryStats || { correct: 0, total: 0 }
}

function getCategoryAccuracy(category: string): number {
  return props.statistics.getCategoryAccuracy(category)
}

function getAccuracyColor(accuracy: number): string {
  if (accuracy >= 90) return 'text-green-600'
  if (accuracy >= 80) return 'text-blue-600'
  if (accuracy >= 70) return 'text-yellow-600'
  return 'text-red-600'
}

function resetStats() {
  if (confirm('Are you sure you want to reset all statistics? This cannot be undone.')) {
    props.statistics.reset()
  }
}
</script>
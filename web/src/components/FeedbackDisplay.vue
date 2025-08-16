<template>
  <div class="bg-gray-50 rounded-lg p-6 space-y-4">
    <!-- Result -->
    <div class="text-center">
      <div 
        :class="[
          'text-2xl font-bold mb-2',
          feedback.isCorrect ? 'text-green-600' : 'text-red-600'
        ]"
      >
        {{ feedback.isCorrect ? '✅ Correct!' : '❌ Incorrect!' }}
      </div>
      
      <div v-if="!feedback.isCorrect" class="space-y-1">
        <div class="text-gray-700">
          <span class="font-semibold">Correct answer:</span> {{ actionName(feedback.correctAction) }}
        </div>
        <div class="text-gray-700">
          <span class="font-semibold">Your answer:</span> {{ actionName(feedback.userAction) }}
        </div>
      </div>
    </div>
    
    <!-- Explanation -->
    <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
      <div class="font-semibold text-blue-900 mb-2">💡 Strategy Tip:</div>
      <div class="text-blue-800">{{ feedback.explanation }}</div>
    </div>
    
    <!-- Continue Button -->
    <div class="text-center">
      <button
        @click="$emit('continue')"
        class="btn btn-primary px-8"
      >
        Continue
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { FeedbackData, Action } from '@/types/strategy'

defineProps<{
  feedback: FeedbackData
}>()

defineEmits<{
  'continue': []
}>()

function actionName(action: Action): string {
  switch (action) {
    case 'H': return 'HIT'
    case 'S': return 'STAND'
    case 'D': return 'DOUBLE'
    case 'Y': return 'SPLIT'
    default: return action
  }
}
</script>
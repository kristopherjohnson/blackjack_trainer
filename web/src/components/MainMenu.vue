<template>
  <div class="card max-w-2xl mx-auto">
    <h2 class="text-2xl font-bold text-gray-800 mb-6 text-center">Choose Your Training Mode</h2>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
      <button
        v-for="mode in trainingModes"
        :key="mode.id"
        @click="selectMode(mode.id)"
        class="btn btn-primary p-6 text-left hover:shadow-lg transition-shadow"
      >
        <div class="text-2xl mb-2">{{ mode.icon }}</div>
        <div class="font-semibold mb-1">{{ mode.name }}</div>
        <div class="text-sm opacity-90">{{ mode.description }}</div>
      </button>
    </div>
    
    <div class="border-t pt-4">
      <button
        @click="$emit('view-stats')"
        class="btn btn-secondary w-full"
      >
        📊 View Statistics
      </button>
    </div>

    <!-- Sub-mode selection modals -->
    <DealerGroupSelector
      v-if="showDealerGroupSelector"
      @select="onDealerGroupSelect"
      @cancel="showDealerGroupSelector = false"
    />
    
    <HandTypeSelector
      v-if="showHandTypeSelector"
      @select="onHandTypeSelect"
      @cancel="showHandTypeSelector = false"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { TRAINING_MODES } from '@/utils/trainingSessions'
import DealerGroupSelector from './DealerGroupSelector.vue'
import HandTypeSelector from './HandTypeSelector.vue'
import type { HandType } from '@/types/strategy'

const emit = defineEmits<{
  'start-session': [sessionType: string, options?: any]
  'view-stats': []
}>()

const trainingModes = TRAINING_MODES
const showDealerGroupSelector = ref(false)
const showHandTypeSelector = ref(false)

function selectMode(modeId: string) {
  switch (modeId) {
    case 'random':
    case 'absolute':
      emit('start-session', modeId)
      break
    case 'dealer':
      showDealerGroupSelector.value = true
      break
    case 'handType':
      showHandTypeSelector.value = true
      break
  }
}

function onDealerGroupSelect(dealerGroup: string) {
  showDealerGroupSelector.value = false
  emit('start-session', 'dealer', { dealerGroup })
}

function onHandTypeSelect(handType: HandType) {
  showHandTypeSelector.value = false
  emit('start-session', 'handType', { handType })
}
</script>
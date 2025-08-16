<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="card max-w-lg mx-4">
      <h3 class="text-xl font-bold mb-4">Select Hand Type Focus</h3>
      
      <div class="space-y-3 mb-6">
        <button
          @click="$emit('select', 'hard')"
          class="btn btn-primary w-full text-left p-4"
        >
          <div class="font-semibold">🔨 Hard Totals</div>
          <div class="text-sm opacity-90">No aces or ace counts as 1</div>
        </button>
        
        <button
          @click="$emit('select', 'soft')"
          class="btn btn-primary w-full text-left p-4"
        >
          <div class="font-semibold">🪶 Soft Totals</div>
          <div class="text-sm opacity-90">Hands with ace counting as 11</div>
        </button>
        
        <button
          @click="$emit('select', 'pair')"
          class="btn btn-primary w-full text-left p-4"
        >
          <div class="font-semibold">👯 Pairs</div>
          <div class="text-sm opacity-90">Identical cards for split decisions</div>
        </button>
      </div>
      
      <button
        @click="$emit('cancel')"
        class="btn btn-secondary w-full"
      >
        Cancel
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { HandType } from '@/types/strategy'

defineEmits<{
  'select': [handType: HandType]
  'cancel': []
}>()
</script>
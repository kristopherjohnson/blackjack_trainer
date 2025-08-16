<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="card max-w-lg mx-4">
      <h3 class="text-xl font-bold mb-4">Select Dealer Strength Group</h3>
      
      <div class="space-y-3 mb-6">
        <button
          @click="$emit('select', 'weak')"
          class="btn btn-primary w-full text-left p-4"
        >
          <div class="font-semibold">🟢 Weak Cards (4, 5, 6)</div>
          <div class="text-sm opacity-90">Dealer bust cards - get greedy!</div>
        </button>
        
        <button
          @click="$emit('select', 'medium')"
          class="btn btn-primary w-full text-left p-4"
        >
          <div class="font-semibold">🟡 Medium Cards (2, 3, 7, 8)</div>
          <div class="text-sm opacity-90">Moderate strategy needed</div>
        </button>
        
        <button
          @click="$emit('select', 'strong')"
          class="btn btn-primary w-full text-left p-4"
        >
          <div class="font-semibold">🔴 Strong Cards (9, 10, A)</div>
          <div class="text-sm opacity-90">Conservative play required</div>
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
defineEmits<{
  'select': [dealerGroup: string]
  'cancel': []
}>()
</script>
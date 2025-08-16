<template>
  <div :class="cardClasses">
    <div class="card-corner">
      <div class="card-value">{{ displayValue }}</div>
      <div class="card-mini-suit">{{ displaySuit }}</div>
    </div>
    <div class="card-center-suit">{{ displaySuit }}</div>
    <div class="card-corner-bottom">
      <div class="text-lg font-bold leading-none">{{ displayValue }}</div>
      <div class="text-sm leading-none">{{ displaySuit }}</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  card: string
}>()

const displayValue = computed(() => {
  const card = props.card
  if (card === 'A') return 'A'
  if (card === '10') return '10'
  return card
})

const displaySuit = computed(() => {
  // Rotate through suits for visual variety
  const suits = ['♠', '♥', '♦', '♣']
  const cardNum = props.card === 'A' ? 1 : parseInt(props.card) || 0
  return suits[cardNum % 4]
})

const isRedSuit = computed(() => {
  return ['♥', '♦'].includes(displaySuit.value)
})

const cardClasses = computed(() => [
  'playing-card',
  isRedSuit.value ? 'red' : 'black'
])
</script>
# Blackjack Strategy Trainer - Web Version

A Vue 3 + TypeScript implementation of the Blackjack Strategy Trainer, providing an interactive web-based interface for learning basic blackjack strategy.

## Features

- **Four Training Modes**:
  - Quick Practice: Random scenarios with all hand types
  - Dealer Strength: Practice against weak/medium/strong dealer cards
  - Hand Types: Focus on hard totals, soft totals, or pairs
  - Absolutes Drill: Practice never/always rules

- **Complete Strategy Implementation**: All strategy data matches the Python reference implementation
- **Interactive Feedback**: Immediate explanations and learning tips
- **Session Statistics**: Track accuracy by hand type and dealer strength
- **Responsive Design**: Works on desktop, tablet, and mobile devices
- **Progressive Web App Ready**: Can be installed as a standalone application

## Technology Stack

- **Vue 3** with Composition API
- **TypeScript** for type safety
- **Tailwind CSS** for styling
- **Vite** for fast development and building

## Development

### Prerequisites

- Node.js 18+ 
- npm or yarn

### Setup

```bash
cd web/
npm install
```

### Development Server

```bash
npm run dev
```

The application will be available at `http://localhost:5173`

### Building for Production

```bash
npm run build
```

The built files will be in the `dist/` directory.

### Type Checking

```bash
npm run type-check
```

## Project Structure

```
web/
├── src/
│   ├── components/         # Vue components
│   │   ├── MainMenu.vue
│   │   ├── TrainingSession.vue
│   │   ├── FeedbackDisplay.vue
│   │   ├── PlayingCard.vue
│   │   ├── StatisticsView.vue
│   │   ├── DealerGroupSelector.vue
│   │   └── HandTypeSelector.vue
│   ├── types/              # TypeScript type definitions
│   │   └── strategy.ts
│   ├── utils/              # Core logic and utilities
│   │   ├── strategy.ts
│   │   ├── trainingSessions.ts
│   │   └── statistics.ts
│   ├── App.vue            # Main application component
│   ├── main.ts            # Application entry point
│   └── style.css          # Global styles and Tailwind imports
├── public/                # Static assets
├── index.html            # HTML template
├── package.json          # Dependencies and scripts
├── vite.config.ts        # Vite configuration
├── tailwind.config.js    # Tailwind CSS configuration
├── postcss.config.js     # PostCSS configuration
└── tsconfig.json         # TypeScript configuration
```

## Core Classes

### StrategyChart
Complete implementation of basic blackjack strategy with:
- Hard totals (5-21)
- Soft totals (13-21)  
- Pairs (2,2 through A,A)
- Dealer strength groupings
- Learning mnemonics and explanations

### Training Sessions
- **RandomTrainingSession**: Mixed practice with all scenarios
- **DealerGroupTrainingSession**: Focus on specific dealer strength
- **HandTypeTrainingSession**: Practice specific hand categories
- **AbsoluteTrainingSession**: Drill absolute rules

### Statistics
Tracks session performance with breakdowns by:
- Overall accuracy
- Hand type (hard/soft/pairs)
- Dealer strength (weak/medium/strong)
- Combined categories

## Strategy Implementation

The web version maintains 100% parity with the Python implementation:

- Same strategy chart data for all scenarios
- Identical action recommendations (H/S/D/Y)
- Same explanatory mnemonics and learning tips
- Equivalent dealer strength groupings
- Matching absolute rule identification

## Browser Compatibility

- Chrome 88+
- Firefox 87+
- Safari 14+
- Edge 88+

## Mobile Support

The application is fully responsive and optimized for mobile devices with:
- Touch-friendly interface
- Optimized card layouts
- Accessible typography
- Gesture support

## Deployment

The application can be deployed to any static hosting service:

1. Build the application: `npm run build`
2. Upload the `dist/` directory contents to your web server
3. Configure your server to serve `index.html` for all routes (SPA mode)

### Recommended Hosting Platforms

- Vercel
- Netlify
- GitHub Pages
- Firebase Hosting
- AWS S3 + CloudFront

## License

MIT License - see the project root LICENSE file for details.
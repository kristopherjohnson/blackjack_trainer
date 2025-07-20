"""Blackjack Strategy Trainer package.

A terminal-based Python program for learning blackjack basic strategy.
"""

__version__ = "1.0.0"
__author__ = "Blackjack Strategy Trainer"

from .trainer import (
    TrainingSession,
    RandomTrainingSession,
    DealerGroupTrainingSession,
    HandTypeTrainingSession,
    AbsoluteTrainingSession
)
from .strategy import StrategyChart
from .stats import Statistics
from .ui import display_menu

__all__ = [
    'TrainingSession',
    'RandomTrainingSession',
    'DealerGroupTrainingSession',
    'HandTypeTrainingSession',
    'AbsoluteTrainingSession',
    'StrategyChart',
    'Statistics',
    'display_menu'
]

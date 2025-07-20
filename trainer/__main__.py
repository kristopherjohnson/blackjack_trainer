#!/usr/bin/env python3
"""Main entry point for the Blackjack Strategy Trainer package."""

import sys
import os

# Add the parent directory to sys.path to allow imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from trainer.main import main  # pylint: disable=wrong-import-position


if __name__ == "__main__":
    main()

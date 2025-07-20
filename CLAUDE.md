This is an implementation of a Blackjack Strategy Trainer

Read the plan and specification from @blackjack_trainer_plan.md

The trainer must use the strategy given in @blackjack_basic_strategy.md

## Development Workflow

After any series of changes to Python files, or when asked to "run
pre-commit checks", perform these steps to ensure the code is in good shape:

1. Run `pylint` and address any issues, and if necessary, update .pylintrc with any new rules
2. Run `autopep8` to apply a consistent formatting style
3. Run unit tests to ensure code is still working
4. Ensure that the instructions in `README.md` are still correct
5. Ensure that `blackjack_trainer_plan.md` is up to date with the current state of the project

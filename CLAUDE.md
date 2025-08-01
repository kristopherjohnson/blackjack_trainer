This is an implementation of a Blackjack Strategy Trainer

Read the plan and specification from @blackjack_trainer_plan.md

The trainer must use the strategy given in @blackjack_basic_strategy.md

All code generation **MUST** respect the `.editorconfig` settings of trimming
trailing whitespace and adding an empty line at the end of every source file.

## Translations

These directories contain translations of the Python program into other
programming languages:

- `cpp/`: C++
- `rust/`: Rust
- `go/`: Go

Each of these translations should have feature parity, have the same unit tests,
and use the same high-level structure as the Python program. If a change is made
to the Python implementation that affects behavior, make sure the same change is
made to the other implementations.

## Development Workflow

After any series of changes to Python files, or when asked to "run
pre-commit checks", perform these steps to ensure the code is in good shape:

1. Run `pylint` and address any issues, and if necessary, update .pylintrc with any new rules
2. Run `autopep8` to apply a consistent formatting style
3. Run unit tests to ensure code is still working
4. Ensure that the instructions in `README.md` are still correct
5. Ensure that `blackjack_trainer_plan.md` is up to date with the current state of the project

Alternatively, you can run the comprehensive pre-commit script that handles all
implementations:

```bash
./precommit.sh
```

This script runs formatters, linters, and tests for Python, Rust, C++, and Go
implementations automatically.


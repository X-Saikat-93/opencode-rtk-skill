# Contributing

## Principles

- skill-native
- dependency-free
- safe by default
- easy to inspect
- portable across agents

## Adding a new agent adapter

1. Add a `case` branch to `install_agent()` in `install.sh` with skill path + bootstrap file target.
2. Add a matching `case` branch to `uninstall_agent()` in `uninstall.sh`.
3. Add a matching `case` branch to `verify_agent()` in `scripts/verify.sh`.
4. Add the agent to the `for` loop in the `--agent all` section of all three scripts.
5. Add path mapping to `scripts/print-targets.sh`.
6. Update `docs/MULTI_AGENT_COMPATIBILITY.md` with the new agent paths.
7. Add an install example in `examples/` following existing format.
8. Add the agent row to the compatibility table in `README.md`.

## Development workflow

```bash
# Run all validation
make test

# Run shellcheck (if installed)
make lint

# Verify file integrity
sha256sum -c checksums.sha256

# Regenerate checksums after editing files
sha256sum <file1> <file2> ... > checksums.sha256
```

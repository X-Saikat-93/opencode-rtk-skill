# RTK Token Saver Bootstrap

Use the `rtk-token-saver` skill for terminal command execution in this repository.

Before running shell commands, prefer RTK wrappers:

```bash
rtk git status
rtk git diff
rtk ls
rtk find . -type f
rtk grep "query" .
rtk read <file>
rtk deps
rtk npm run build
rtk npm run lint
rtk npm test
rtk tsc --noEmit
rtk pytest
rtk docker ps
```

Avoid raw noisy commands when RTK can handle them.

Fallback to raw commands only when RTK is unsupported, fails, hides required information, or the user explicitly asks for raw output.

Do not run destructive commands without user approval.

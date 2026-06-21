# Security Model

The installer:

- makes no network calls
- does not use sudo
- does not install dependencies
- does not modify shell rc files
- refuses symlink destinations
- creates backups
- uses managed blocks
- avoids OpenCode plugin files
- avoids `opencode.jsonc`

Agent skills are instructions, not hard enforcement. Confirm adoption with:

```bash
rtk gain
```

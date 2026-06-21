# Troubleshooting

## No skills found

```bash
find skills -name SKILL.md -print
sed -n '1,20p' skills/rtk-token-saver/SKILL.md
```

The file must include `name` and `description` in YAML frontmatter.

## RTK not found

```bash
which rtk
rtk --version
```

Install:

```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
```

## Agent ignores skill

Try explicit invocation:

```text
Use the rtk-token-saver skill. Run: rtk git status
```

## OpenCode Desktop plugin crash

This project does not install OpenCode plugins. If an old RTK plugin caused crashes:

```bash
mv ~/.config/opencode/plugins/rtk.ts ~/.config/opencode/plugins/rtk.ts.disabled 2>/dev/null || true
mv ~/.config/opencode/plugins/rtk.js ~/.config/opencode/plugins/rtk.js.disabled 2>/dev/null || true
rm -f ~/.config/opencode/package.json ~/.config/opencode/package-lock.json ~/.config/opencode/bun.lock
rm -rf ~/.config/opencode/node_modules
```

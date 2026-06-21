# Release Guide from Scratch

Author: Saikat Das
GitHub: https://github.com/X-Saikat-93
Repository: `opencode-rtk-skill`

## 1. Extract

```bash
unzip opencode-rtk-skill-final-skill-native.zip
cd opencode-rtk-skill
```

## 2. Validate

```bash
make test
make lint
```

## 3. Confirm skill entrypoint

```bash
sed -n '1,80p' skills/rtk-token-saver/SKILL.md
```

Confirm:

```yaml
---
name: rtk-token-saver
description: ...
---
```

## 4. Initialize Git

```bash
git init
git branch -M main
git add .
git commit -m "initial release: RTK token saver agent skill"
```

## 5. Create GitHub repo

```bash
gh auth status
gh repo create X-Saikat-93/opencode-rtk-skill \
  --public \
  --source=. \
  --remote=origin \
  --push \
  --description "Skill-native RTK token optimization for OpenCode, Claude Code, Codex, Antigravity, and AGENTS.md-compatible coding agents."
```

## 6. Test skills.sh discovery

```bash
npx skills add X-Saikat-93/opencode-rtk-skill --list
```

Expected: `rtk-token-saver`.

## 7. Test install

```bash
mkdir -p /tmp/rtk-skill-demo
cd /tmp/rtk-skill-demo
npx skills add X-Saikat-93/opencode-rtk-skill --skill rtk-token-saver -a opencode -y
npx skills list
```

## 8. Create release ZIP

```bash
cd ..
zip -r opencode-rtk-skill-v4.0.0.zip opencode-rtk-skill -x "opencode-rtk-skill/.git/*"
sha256sum opencode-rtk-skill-v4.0.0.zip > opencode-rtk-skill-v4.0.0.zip.sha256
```

## 9. Tag and release

```bash
cd opencode-rtk-skill
git tag -a v4.0.0 -m "OpenCode RTK Skill v4.0.0"
git push origin v4.0.0

gh release create v4.0.0 \
  ../opencode-rtk-skill-v4.0.0.zip \
  ../opencode-rtk-skill-v4.0.0.zip.sha256 \
  --title "OpenCode RTK Skill v4.0.0" \
  --notes-file docs/RELEASE_NOTES_v4.0.0.md
```

## 10. Pre-publish checklist

- [ ] `make test` passes
- [ ] `sha256sum -c checksums.sha256` — all OK
- [ ] README.md answers: what, why, not-plugin, install RTK, install skill, verify, uninstall, security
- [ ] README_PREMIUM.md is distinct premium version (for skills.sh marketplace)
- [ ] SKILL.md frontmatter has valid `name: rtk-token-saver` + `description`
- [ ] No sudo usage in any script
- [ ] No network calls in install.sh
- [ ] No npm dependencies
- [ ] `.gitignore` covers .backup-, .removed-, .rtk- files
- [ ] ZIP checksum published externally (not inside ZIP)

## 11. Recommended repo settings

Enable:

- Issues
- Discussions
- Actions
- Security advisories
- Dependabot alerts

Protect `main` after first release:

- require CI
- block force pushes
- block branch deletion

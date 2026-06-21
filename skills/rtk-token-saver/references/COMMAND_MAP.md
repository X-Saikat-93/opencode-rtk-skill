# RTK Command Map

| Raw intent | Prefer |
|---|---|
| list files | `rtk ls` |
| recursive tree | `rtk tree` |
| find files | `rtk find . -type f` |
| read file | `rtk read <file>` |
| search text | `rtk grep "query" .` |
| Git status | `rtk git status` |
| Git diff | `rtk git diff` |
| Git log | `rtk git log` |
| Dependencies | `rtk deps` |
| Node build | `rtk npm run build` |
| Node lint | `rtk npm run lint` |
| Node test | `rtk npm test` |
| TypeScript | `rtk tsc --noEmit` |
| Jest | `rtk jest` |
| Vitest | `rtk vitest` |
| Playwright | `rtk playwright test` |
| Next.js build | `rtk next build` |
| Python tests | `rtk pytest` |
| Ruff | `rtk ruff` |
| Mypy | `rtk mypy` |
| Docker | `rtk docker <args>` |
| Kubernetes | `rtk kubectl <args>` |
| PostgreSQL | `rtk psql` |
| logs | `rtk log <command>` |
| only errors | `rtk err <command>` |
| failing tests | `rtk test <command>` |

# Safety Notes

This skill changes command preference, not command permissions.

It must not be used to justify risky actions.

## Do not run without approval

```bash
rm -rf
git reset --hard
git clean -fd
docker system prune
kubectl delete
drop database
truncate
chmod -R
chown -R
```

## Prefer safe probes

```bash
rtk git status
rtk git diff
rtk find . -type f
rtk grep "query" .
```

## If RTK hides needed detail

Fallback is allowed. Use the smallest raw command that exposes the missing detail.

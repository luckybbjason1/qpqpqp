# Sync Troubleshooting

## Common Issues

### GitHub Token 401 Unauthorized

**Symptom:** `git push` returns `HTTP Error 401: Unauthorized`

**Cause:** The GITHUB_TOKEN in `~/.hermes/.env` is a placeholder (commented out `# GITHUB_TOKEN=***`).

**Fix:** 
1. Generate a Fine-grained PAT at https://github.com/settings/tokens?type=beta
2. Permissions: Contents = Read and write
3. Repository access: Select the specific repo to back up to
4. Use the token directly in the git remote URL: `https://<username>:<TOKEN>@github.com/...`

### `state.db-wal` / `state.db-shm` in Git

**Symptom:** Git tracks `state.db-wal` and `state.db-shm` files, causing constant diffs.

**Cause:** These are SQLite Write-Ahead Logging files that change on every write.

**Fix:** Add to `.gitignore`:
```
*.db-wal
*.db-shm
```

### Large state.db on Android

**Symptom:** Git push is slow or fails due to large `state.db` (50MB+).

**Cause:** Session history accumulates over time.

**Fix:** Prune old sessions first:
```bash
hermes sessions prune --older-than 30
```
Then recommit.

### Permission Denied on .env

**Symptom:** `git add` works but `.env` shows as unreadable or permission issues.

**Cause:** Termux file permissions (600) on `.env`.

**Fix:** Ensure the file is readable by the current user:
```bash
chmod 600 ~/.hermes/.env
```
Git does not care about file permissions — it reads the content regardless.

### Conflicts When Syncing Two Devices

**Symptom:** `git push` rejected — non-fast-forward.

**Fix:** Always pull first:
```bash
cd ~/.hermes
git pull origin main --rebase
git add -A
git commit -m "Sync $(date +%Y-%m-%d)"
git push origin main
```

### Missing `state.db` After Restore

**Symptom:** After cloning from GitHub, `state.db` is missing or empty.

**Cause:** `state.db` was not committed (maybe excluded accidentally).

**Fix:** Check if it's in `.gitignore`. If not, the file was never committed. Restore from a tar.gz backup if available.

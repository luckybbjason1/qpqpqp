---
name: hermes-data-sync
description: "Backup, restore, and synchronize Hermes Agent data (memories, sessions, skills, config) to and from remote storage — GitHub, local file servers, or cloud storage."
version: 1.0.0
author: Agnes
license: MIT
platforms: [linux, macos, android]
metadata:
  hermes:
    tags: [hermes, backup, sync, github, memory, restore]
---

# Hermes Data Sync

Backup, restore, and synchronize Hermes Agent data to and from remote storage.

## Key Paths to Back Up

| Path | Purpose | Size |
|------|---------|------|
| `~/.hermes/config.yaml` | All config settings | Small |
| `~/.hermes/.env` | API keys and secrets | Small |
| `~/.hermes/memories/` | Manual memory entries | Small |
| `~/.hermes/state.db` | Session history, messages, FTS5 index | Medium (1-10MB) |
| `~/.hermes/skills/` | Agent-created skills | Small-medium |
| `~/.hermes/.hermes_history` | Session history file | Tiny |

**Critical files to ALWAYS include:** `config.yaml`, `.env`, `state.db`

## GitHub Sync (Two-Way)

### Step 1: Create Private Repository

Create a private repo (e.g. `hermes-backup` or `hermes-memories`). The user provides a GitHub PAT (Fine-grained token with repo:contents Read/Write).

### Step 2: Initialize Local Repo

```bash
cd ~/.hermes
git init
# Create .gitignore to exclude caches
cat > .gitignore << 'EOF'
cache/
image_cache/
audio_cache/
*.db-wal
*.db-shm
models_dev_cache.json
ollama_cloud_models_cache.json
interrupt_debug.log
logs/
sessions/*.jsonl
sessions/*.json
hermes-agent/
EOF
```

### Step 3: Add Remote and Configure

```bash
git remote add origin https://<username>:<TOKEN>@github.com/<username>/hermes-memories.git
```

### Step 4: Initial Push

```bash
git add -A
git commit -m "Initial hermes data backup"
git branch -M main
git push -u origin main
```

### Step 5: Sync Workflow

For future syncs:

```bash
# Pull latest from remote first
git pull origin main
# Then push local changes
git add -A
git commit -m "Backup $(date +%Y-%m-%d)"
git push origin main
```

## Pitfalls

- **`state.db-wal` and `state.db-shm` should NOT be committed** — they are SQLite WAL/SHM files that change constantly and can cause conflicts. Exclude them in .gitignore.
- **`.env` contains secrets** — the repo MUST be private. Committing exposes API keys.
- **`state.db` size** — grows with conversation history. On mobile devices this can reach tens of MB. Consider pruning old sessions before backup.
- **Android Git quirks:** Termux git does not follow symlinks the same way. Use `git add -A` not `-u` to ensure all files are tracked.
- **Conflict resolution:** If syncing between two devices, always `git pull` before `git push` to avoid overwriting.

## Local File Backup (Alternative)

For non-GitHub sync, create a tar.gz archive:

```bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
tar czf ~/hermes-backup-${TIMESTAMP}.tar.gz \
  --exclude='cache/' \
  --exclude='image_cache/' \
  --exclude='audio_cache/' \
  --exclude='*.db-wal' \
  --exclude='*.db-shm' \
  --exclude='models_dev_cache.json' \
  --exclude='ollama_cloud_models_cache.json' \
  --exclude='logs/' \
  --exclude='hermes-agent/' \
  -C ~/.hermes .
```

## Restore

```bash
# From GitHub clone
git clone https://<username>:<TOKEN>@github.com/<username>/hermes-memories.git ~/.hermes-temp
cp ~/.hermes-temp/config.yaml ~/.hermes/config.yaml
cp ~/.hermes-temp/.env ~/.hermes/.env
cp ~/.hermes-temp/state.db ~/.hermes/state.db

# From tar.gz archive
tar xzf ~/hermes-backup-LATEST.tar.gz -C ~/.hermes/
```

## Reference Files

- `references/sync-troubleshooting.md` — Common issues and fixes

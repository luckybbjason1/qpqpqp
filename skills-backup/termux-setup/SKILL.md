---
name: termux-setup
description: "Set up services, tools, and automation in Termux — SSH, networking, battery optimizations, boot scripts, and Google Play vs F-Droid differences."
version: 1.0.0
author: Agnes
license: MIT
platforms: [android]
metadata:
  hermes:
    tags: [termux, android, sshd, openssh, boot, auto-start]
---

# Termux Setup

Set up services, tools, and automation in Termux on Android devices.

## Important: Google Play vs F-Droid Differences

Google Play builds of Termux (>= 2024.10.24) have merged **Termux:Boot** and **Termux:Widget** into the main app. Separate apps like `termux-autostart` and `termux-boot` are **no longer available as separate packages** in Google Play repos.

| Feature | Google Play (>= 2024.10.24) | F-Droid |
|---------|-----------------------------|---------|
| Boot scripts | `~/.termux/boot/` | Requires `termux:Boot` app |
| Widgets | `~/.termux/widget/` | Requires `termux:Widget` app |
| Services | `~/.termux/service/` | Requires `termux-services` |
| termux-autostart | Merged into main app | Separate package |

**Always check which version is installed before suggesting packages.** Run `termux-info` — it reports the build source.

## SSH Server Setup (OpenSSH)

### Prerequisites
```bash
pkg install openssh
```

### 1. Generate SSH keys (if not present)
```bash
ssh-keygen -t ed25519  # creates ~/.ssh/id_ed25519 + id_ed25519.pub
```

### 2. Set up authorized_keys
```bash
cat ~/.ssh/id_ed25519.pub > ~/.ssh/authorized_keys
```

### 3. Configure sshd
Create/overwrite `/data/data/com.termux/files/usr/etc/ssh/sshd_config`:
```
Port 8022
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
AuthorizedKeysFile .ssh/authorized_keys
```

Test config: `sshd -t`

### 4. Set up auto-start

**Google Play Termux (>= 2024.10.24):**
Place script in `~/.termux/boot/`:
```bash
mkdir -p ~/.termux/boot
cat > ~/.termux/boot/start-sshd.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
if pgrep -x sshd > /dev/null 2>&1; then
  exit 0
fi
nohup /data/data/com.termux/files/usr/bin/sshd > /dev/null 2>&1
echo "sshd started at $(date)" >> $HOME/.termux/boot/sshd-boot.log
EOF
chmod +x ~/.termux/boot/start-sshd.sh
```

**F-Droid Termux:**
Install `termux:Boot` app from F-Droid, open it once, then put scripts in `~/.termux/boot/`.

### 5. Disable battery optimizations (CRITICAL)

Google Play Termux's boot script only fires if battery optimization is disabled:
1. Settings → Apps → Termux → Battery → **Don't optimize** (or "Allow background activity")
2. On Samsung devices (and some OEMs), add Termux to "Never sleeping apps" if available
3. Open Termux at least once after boot to trigger the boot broadcast registration

**This step is the most common reason boot scripts fail.** Always remind the user.

## Common Pitfalls

- **`pkg install termux-autostart` or `termux-boot` fails** on Google Play builds — these are merged into the main app. Use `~/.termux/boot/` instead.
- **sshd doesn't start after reboot** — almost always a battery optimization issue. Check the OEM battery saver settings.
- **`~/.ssh/authorized_keys` doesn't exist by default** — must be created from an existing public key.
- **Google Play builds have limited background capabilities** compared to F-Droid. For always-on services (24/7 sshd), F-Droid build + `termux-services` is more reliable.
- **Samsung devices** (and some OEMs) aggressively kill Termux in the background. May need to disable battery optimization for multiple apps (Termux, Termux API if used).

## Useful Port Defaults

| Service | Port | Notes |
|---------|------|-------|
| OpenSSH | 8022 | Default in Termux (not 22) |
| Python HTTP | 8000 | python -m http.server |
| Node HTTP | 3000 | Common default |
| Nginx | 8080 | Termux default (not 80) |

## Reference Files

- `templates/sshd-boot-script.sh` — ready-to-use sshd auto-start script

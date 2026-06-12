#!/data/data/com.termux/files/usr/bin/bash
# SSHD auto-start script for Termux
# Place in ~/.termux/boot/start-sshd.sh
# Make executable: chmod +x ~/.termux/boot/start-sshd.sh

# Exit if sshd is already running
if pgrep -x sshd > /dev/null 2>&1; then
  exit 0
fi

# Start sshd in background
nohup /data/data/com.termux/files/usr/bin/sshd > /dev/null 2>&1

# Log start time
echo "sshd started at $(date)" >> $HOME/.termux/boot/sshd-boot.log

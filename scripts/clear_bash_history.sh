# run this as root under /bin/sh (so you don’t kill YOUR shell)
#!/bin/sh
set -e

# Truncate on‑disk history for everyone
while IFS=: read user _ _ _ _ home shell; do
  [ -d "$home" ] && case "$shell" in */bash) : ;; *) continue;; esac
  for f in "$home"/.bash_history*; do
    [ -e "$f" ] && :> "$f"
  done
done < /etc/passwd

# Kill all bash processes
killall -9 bash 2>/dev/null || true

echo "All bash on‑disk histories cleared; all bash sessions killed."

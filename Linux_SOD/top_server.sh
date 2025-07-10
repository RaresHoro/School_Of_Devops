#!/bin/bash

LOGFILE="top_server_out1.txt"
exec > >(tee -a "$LOGFILE") 2>&1   # echo everything (stdout+stderr) to log + console

log() { printf "[%s] %s\n" "$(date +'%F %T')" "$*"; }

log "### Script start"

# Step 1  Find an unused port
log "### Searching for a free port (8000-9990)…"
for port in $(seq 8000 9990); do
    if ! lsof -i :"$port" >/dev/null 2>&1; then
        log "### Selected free port: $port"
        break
    fi
done

# Step 2  Create temp dir + file
TMPDIR=$(mktemp -d)
TOPFILE="$TMPDIR/top.html"
touch "$TOPFILE"
log "### Created tmp dir: $TMPDIR"
log "### Output file     : $TOPFILE"

# Clean-up trap to stop it from running 
trap 'log "### Cleaning up"; rm -rf "$TMPDIR"' EXIT

# Step 3  Background loop
generate_top_output() {
    while true; do
        {
            echo "<html><head><meta http-equiv='refresh' content='10'></head><body><pre>"
            top -b -n1
            echo "</pre></body></html>"
        } > "$TOPFILE"
        sleep 10
    done
}
log "### Launching background updater"
generate_top_output &

# Step 4  Start Python HTTP server
cd "$TMPDIR"
log "### Starting python3 -m http.server on port $port"
log "### Open http://localhost:$port/top.html in your browser"
python3 -m http.server "$port"



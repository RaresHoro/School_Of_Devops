#!/bin/bash

# Step 1: Find an unused port
for port in $(seq 8000 9990); do
    if ! lsof -i :"$port" >/dev/null 2>&1; then
        break
    fi
done

echo "Using port $port for the web server."

# Step 2: Create temp dir and file
TMPDIR=$(mktemp -d)
TOPFILE="$TMPDIR/top.html"
touch "$TOPFILE"  # 💡 Ensure the file exists first!

# Clean up when script exits
trap 'rm -rf "$TMPDIR"' EXIT

# Step 3: Start background loop that updates the file every 10 seconds
generate_top_output() {
    while true; do
        {
            echo "<html><head><meta http-equiv='refresh' content='10'></head><body><pre>"
            top -b -n1
            echo "</pre></body></html>"
        } > "$TOPFILE" 2>/dev/null  # 💡 Suppress error messages
        sleep 10
    done
}

# Start the background loop
generate_top_output &

# Step 4: Start web server (Python 3)
cd "$TMPDIR"
echo "Visit http://localhost:$port/top.html"
python3 -m http.server "$port"


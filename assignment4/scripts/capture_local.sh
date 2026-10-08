#!/usr/bin/env bash
# Part 3 helper (Linux/macOS). Captures your own HTTPS traffic + saves the TLS keys.
# Usage: ./capture_local.sh 23110078
ROLL="${1:-23110078}"
export SSLKEYLOGFILE="$PWD/premaster_${ROLL}.txt"; : > "$SSLKEYLOGFILE"
echo "[*] Key log -> $SSLKEYLOGFILE"
# Capture only HTTPS on the default interface; stop with Ctrl+C
sudo tshark -f "tcp port 443" -w "my_local_${ROLL}.pcapng" &
TPID=$!; sleep 2
# Any program started from THIS shell inherits SSLKEYLOGFILE (curl, Firefox, Chrome...)
curl -s https://example.com -o /dev/null
curl -s https://picoctf.com -o /dev/null
echo "[*] Now (optional) open a browser from this same shell, e.g.  google-chrome &  then browse. Press Enter when done."
read -r; sudo kill "$TPID"
echo "[*] Verify:  tshark -r my_local_${ROLL}.pcapng -o tls.keylog_file:premaster_${ROLL}.txt -Y http"

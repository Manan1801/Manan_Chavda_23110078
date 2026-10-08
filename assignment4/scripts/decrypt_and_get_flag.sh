#!/usr/bin/env bash
# Decrypts the TLS traffic in a pcapng using a premaster/keylog file and prints the HTTP bodies.
# Usage: ./decrypt_and_get_flag.sh picoctf_ssl_flag1.pcapng premaster.txt
PCAP="${1:-picoctf_ssl_flag1.pcapng}"; KEYS="${2:-premaster.txt}"
echo "[*] Decrypted HTTP packets:"
tshark -r "$PCAP" -o tls.keylog_file:"$KEYS" -Y http
echo; echo "[*] Body of the 200 OK response:"
tshark -r "$PCAP" -o tls.keylog_file:"$KEYS" -Y "http.response.code==200" \
  -T fields -e http.file_data | python3 -c "import sys;print(bytes.fromhex(sys.stdin.read().strip()).decode())"

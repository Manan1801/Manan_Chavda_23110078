# Assignment 4 – Decrypting TLS traffic with Wireshark
**Name:** Manan Chavda  **Roll No:** 23110078

## Files
| Path | Purpose |
|---|---|
| `part2_given_files/picoctf_ssl_flag1.pcapng`, `premaster.txt` | Files provided with the assignment |
| `screenshots/` | Evidence for each step |
| `scripts/decrypt_and_get_flag.sh` | Command-line reproduction of the solution |
| `scripts/capture_local.sh`, `capture_local_windows.md` | Part 3 helpers |
| `my_local_23110078.pcapng`, `premaster_23110078.txt` | Part 3 deliverables (own capture) |

---
## Q2.1 – Decrypt the capture and find the flag

### Background
TLS encrypts HTTP with session keys derived from the *(pre)master secret*. A browser can dump these secrets to a
"key log" file (NSS format: `CLIENT_RANDOM <client_random> <master_secret>`). Wireshark matches each line to a TLS
session using the 32-byte *Client Random* from the ClientHello, derives the keys and decrypts the records.

### Steps (Wireshark GUI)
1. **Open** `picoctf_ssl_flag1.pcapng` (File → Open). Filter `tls`: everything after the handshake shows only
   *"Application Data"* / *"Encrypted Alert"* – unreadable. (`screenshots/step1.png`, plus take a GUI screenshot here.)
2. **Load the keys:** Edit → Preferences → Protocols → **TLS** → *(Pre)-Master-Secret log filename* → Browse →
   select `premaster.txt` → OK.
3. Wireshark re-dissects the capture; apply filter `http`. Four packets now appear in clear text:
   `GET /14741.html`, `200 OK`, `GET /favicon.ico`, `404 Not Found`. (`screenshots/step2.png`)
4. **Follow the stream:** right-click packet 79 → Follow → **TLS Stream** (`screenshots/step3.png`). Note the
   "Decrypted TLS" tab at the bottom of the packet bytes pane.
5. Click packet 86 (`200 OK`) → *Hypertext Transfer Protocol → Line-based text data*. The page body is the flag
   (the response is gzip-compressed on the wire, Wireshark shows the decompressed body). (`screenshots/step4.png`)

### Decrypted page body
```html
<title>14741 flag</title>
<body> The 14741 HTTPS flag is f09ab0834bfa0238cd4b54aa </body>
```

### ✅ Flag: `f09ab0834bfa0238cd4b54aa`

### Same thing from the command line
```bash
tshark -r picoctf_ssl_flag1.pcapng -o tls.keylog_file:premaster.txt -Y http
tshark -r picoctf_ssl_flag1.pcapng -o tls.keylog_file:premaster.txt -Y "http.response.code==200" \
       -T fields -e http.file_data | python3 -c "import sys;print(bytes.fromhex(sys.stdin.read().strip()).decode())"
```
Observations: client `128.2.16.49` → server `52.14.175.183:443` (picoctf.com, SNI), TLS 1.2, Chrome 60 user-agent,
Apache/2.4.18 server, capture date 21 Aug 2017.

![step1](screenshots/step1.png)
![step2](screenshots/step2.png)
![step3](screenshots/step3.png)
![step4](screenshots/step4.png)

---
## Q2.2 – Which environment variable makes Chrome write `premaster.txt`?
**`SSLKEYLOGFILE`** – set it to a file path (e.g. `SSLKEYLOGFILE=C:\Users\me\premaster.txt` or
`export SSLKEYLOGFILE=~/premaster.txt`) *before* launching Chrome. Chrome (via the NSS/BoringSSL key-log callback)
appends one line per TLS session. Wireshark then reads it through the *(Pre)-Master-Secret log filename* setting.

---
## Q3 – My own capture
Steps followed (see `scripts/`):
1. Set `SSLKEYLOGFILE=premaster_23110078.txt`, restart the browser.
2. Start Wireshark with capture filter `tcp port 443`.
3. Perform the activity (browse to GitHub / pico site etc.), stop, save as `my_local_23110078.pcapng`.
4. Verified decryption by loading `premaster_23110078.txt` in Wireshark (screenshots in `screenshots/local_*.png`).

**To decode:** Wireshark → Edit → Preferences → Protocols → TLS → (Pre)-Master-Secret log filename →
`premaster_23110078.txt`, then filter `http` / `http2`.

> ⚠️ Capture contains only non-sensitive browsing; no logins, cookies or personal chats. The key log
> is only valid for those captured sessions.

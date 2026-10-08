# Windows (what the original task used)
1. Win+R -> `sysdm.cpl` -> Advanced -> Environment Variables -> New (User variable)
   - Name: `SSLKEYLOGFILE`  Value: `C:\Users\<you>\premaster_23110078.txt`
2. Fully close and reopen Chrome/Edge/Firefox.
3. Start Wireshark, pick your Wi-Fi/Ethernet interface, capture filter `tcp port 443`, press Start.
4. Browse to an HTTPS site (e.g. https://picoctf.com).  Stop capture.
5. File -> Save As -> `my_local_23110078.pcapng`.
6. Wireshark: Edit -> Preferences -> Protocols -> TLS -> (Pre)-Master-Secret log filename -> select your txt file.

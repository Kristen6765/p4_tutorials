#!/usr/bin/env python3

#!/usr/bin/env python

import socket

# Create a socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect to the remote host and port
sock.connect(("10.0.3.3", 3333))

# Send a request to the host
sock.send("GET / HTTP/1.1\r\nHost: tw123.juk.fi:3333\r\nUser-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/112.0Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8\r\nAccept-Language: en-US,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nConnection: keep-alive\r\nUpgrade-Insecure-Requests: 1\r\n\r\n".encode())
# sock.send("Why don't you call me any more?\r\n".encode())

# Get the host's response, no more than, say, 1,024 bytes
response_data = sock.recv(1024)

print (response_data)
# Terminate
sock.close(  )

# for i in {1..10}; do cur 10.0.3.3:3333; date ; sleep 2; done
# for i in {1..10}; do cat reply1.txt; date ; sleep 2; done
#!/bin/bash
i=0 
while true
do


   # Store the HTTP response content in a heredoc
   read -r -d '' response_content << EOF
      HTTP/1.0 200 OK
      Server: ${i}simple_http_server/0.3.1 Python/3.8.9
      Date: Thu, 18 May 2023 00:56:07 GMT
      Content-type: text/html;charset=utf-8
      Content-Length: 475

      <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN"><html>
      <title>${i}Directory listing for /</title>
      <body>
      <h2>Directory listing for /</h2>
      <hr>
      <form ENCTYPE="multipart/form-data" method="post"><input name="file" type="file"/><input type="submit" value="upload"/></form>
      <hr>
      <ul>
      <li><a href="client.py">client.py</a>
      <li><a href="http-server.py">http-server.py</a>
      <li><a href="sender.py">sender.py</a>
      <li><a href="sender.py_">sender.py_</a>
      </ul>
      <hr>
      </body>
      </html>
EOF
   i=$((i + 1))
   # Send the HTTP response to port 3333 using nc
   echo "$response_content" |nc -l 3333 -q0
done

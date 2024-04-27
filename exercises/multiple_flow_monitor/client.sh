#!/bin/bash


# Send initial HTTP request to the server
curl 10.0.3.3:3333
for i in {1..15}
do

# # Send another HTTP request to the server based on the response
curl 10.0.3.3:3333
done

# End of client script

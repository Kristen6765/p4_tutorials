# import http.server
# import socketserver

# # Specify the port number you want to use
# PORT = 3333
# counter = 0
# # Custom request handler class
# class CustomHandler(http.server.SimpleHTTPRequestHandler):
#     def do_GET(self):
#         global counter
#         # Increment the counter for each request
#         counter += 1

#         # Create the response message with the counter value
#         message = f"Counter: {counter}\n"

#         # Set the response headers
#         self.send_response(200)
#         self.send_header("Content-type", "text/plain")
#         self.end_headers()

#         # Send the response message
#         self.wfile.write(bytes(message, "utf8"))

# # Create the server instance
# with socketserver.TCPServer(("", PORT), CustomHandler) as httpd:
#     print(f"Serving at port {PORT}")
#     # Start the server
#     httpd.serve_forever()



import http.server
import socketserver

# Specify the port number you want to use
PORT = 3333

# Counter variable
counter = 0

# Custom request handler class
class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        global counter
        # Increment the counter for each request
        counter += 1

        # Create the response message with the counter value
        message = f"Counter: {counter}\n"

        # Set the response headers
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.send_header("X-Counter", str(counter))  # Add the counter to the HTTP header
        self.end_headers()

        # Send the response message
        self.wfile.write(bytes(message, "utf8"))

# Create the server instance
with socketserver.TCPServer(("", PORT), CustomHandler) as httpd:
#    print(f"Serving at port {PORT}")
    # Start the server
    httpd.serve_forever()

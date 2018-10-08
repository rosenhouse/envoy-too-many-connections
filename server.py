import sys
from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer

port = int(sys.argv[1])

response = '''\
<html>\
<head><title>Python app.</title></head>\
<body><p>python, world</p></body>\
</html>\
'''

length = len(response)

class requestHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def do_GET(s):
        s.send_response(200)
        s.send_header("Content-Type", "text/html")
        s.send_header("Content-Length", length)
        s.end_headers()
        s.wfile.write(response)
        return

web_server = HTTPServer(('0.0.0.0', port), requestHandler)
print 'Started on port', port
web_server.serve_forever()

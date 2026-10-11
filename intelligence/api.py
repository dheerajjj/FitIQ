"""Local development API only. Never expose without TLS, auth and rate limits."""
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from intelligence.coach import Session, next_session

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != '/v1/next-session':
            self.send_error(404)
            return
        try:
            length = int(self.headers.get('Content-Length', '0'))
            if not 0 < length <= 4096:
                self.send_error(413)
                return
            payload = json.loads(self.rfile.read(length))
            answer = next_session(Session(**payload))
            status = 200
        except (TypeError, ValueError, KeyError):
            answer = {'error': 'Invalid session data'}
            status = 400
        body = json.dumps(answer).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

if __name__ == '__main__':
    ThreadingHTTPServer(('127.0.0.1', 8765), Handler).serve_forever()

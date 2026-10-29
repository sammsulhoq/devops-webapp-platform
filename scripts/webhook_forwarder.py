"""Forward only GitHub webhook requests to the local Jenkins SSH tunnel."""

import http.client
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

ALLOWED_HEADERS = {
    "content-type",
    "x-github-event",
    "x-github-delivery",
    "x-hub-signature",
    "x-hub-signature-256",
    "user-agent",
}


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != "/github-webhook/":
            self.send_error(404)
            return

        try:
            length = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            self.send_error(400)
            return

        if not 0 < length <= 5_000_000:
            self.send_error(413)
            return

        body = self.rfile.read(length)
        headers = {
            name: value
            for name, value in self.headers.items()
            if name.lower() in ALLOWED_HEADERS
        }

        connection = http.client.HTTPConnection("127.0.0.1", 18091, timeout=20)
        try:
            connection.request(
                "POST", "/github-webhook/", body=body, headers=headers
            )
            response = connection.getresponse()
            result = response.read()
            self.send_response(response.status)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(result)
            print(f"Jenkins webhook response: {response.status}", flush=True)
        except OSError:
            self.send_error(502, "Jenkins tunnel unavailable")
        finally:
            connection.close()

    def do_GET(self):
        self.send_error(404)

    def log_message(self, *args):
        pass


if __name__ == "__main__":
    print("Webhook forwarder listening on 127.0.0.1:18092", flush=True)
    ThreadingHTTPServer(("127.0.0.1", 18092), Handler).serve_forever()

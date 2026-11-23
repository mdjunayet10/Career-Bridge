#!/usr/bin/env python3
"""Serve the built Flutter app locally, including direct route URLs."""

import argparse
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit


class AppHandler(SimpleHTTPRequestHandler):
    def send_head(self):
        requested_path = urlsplit(self.path).path
        file_path = Path(self.translate_path(self.path))
        if not file_path.exists() and not Path(requested_path).suffix:
            self.path = "/index.html"
        return super().send_head()

    def end_headers(self):
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8768)
    parser.add_argument("--directory", type=Path, help="Serve a separate demo or release build.")
    args = parser.parse_args()
    web_root = args.directory.resolve() if args.directory else Path(__file__).resolve().parent.parent / "frontend/build/web"
    if not (web_root / "index.html").is_file():
        parser.error("Build frontend/build/web with flutter build web first.")

    def handler(*handler_args, **handler_kwargs):
        return AppHandler(*handler_args, directory=str(web_root), **handler_kwargs)

    with ThreadingHTTPServer(("127.0.0.1", args.port), handler) as server:
        print(f"Career Bridge: http://127.0.0.1:{args.port}", flush=True)
        server.serve_forever()


if __name__ == "__main__":
    main()

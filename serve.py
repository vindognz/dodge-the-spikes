# serve.py
import gzip
import io
import os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

try:
	import brotli
except ImportError:
	brotli = None

ROOT = "web-export"
COMPRESS = (".wasm", ".js", ".pck", ".html", ".css", ".svg")
LONG_CACHE = (".wasm", ".js")
cache = {}  # (path, encoding) -> (mtime, compressed bytes)

def compress(data, encoding):
	if encoding == "br":
		return brotli.compress(data, quality=9, lgwin=24)
	return gzip.compress(data, compresslevel=9)

def get_compressed(path, encoding):
	mtime = os.path.getmtime(path)
	entry = cache.get((path, encoding))
	if entry is None or entry[0] != mtime:
		with open(path, "rb") as f:
			entry = (mtime, compress(f.read(), encoding))
		cache[(path, encoding)] = entry
	return entry

def pick_encoding(accept):
	tokens = [t.split(";")[0].strip() for t in accept.split(",")]
	if brotli and "br" in tokens:
		return "br"
	if "gzip" in tokens:
		return "gzip"
	return None

class Handler(SimpleHTTPRequestHandler):
	def end_headers(self):
		if self.path.split("?")[0].endswith(LONG_CACHE):
			self.send_header("Cache-Control", "public, max-age=86400")
		else:
			self.send_header("Cache-Control", "no-cache")
		super().end_headers()

	def send_head(self):
		path = self.translate_path(self.path)
		encoding = pick_encoding(self.headers.get("Accept-Encoding", ""))
		if encoding and os.path.isfile(path) and path.endswith(COMPRESS):
			mtime, data = get_compressed(path, encoding)
			etag = f'"{int(mtime)}-{encoding}-{len(data)}"'
			if self.headers.get("If-None-Match") == etag:
				self.send_response(304)
				self.send_header("ETag", etag)
				self.end_headers()
				return None
			self.send_response(200)
			self.send_header("Content-Type", self.guess_type(path))
			self.send_header("Content-Encoding", encoding)
			self.send_header("Content-Length", str(len(data)))
			self.send_header("ETag", etag)
			self.send_header("Vary", "Accept-Encoding")
			self.end_headers()
			return io.BytesIO(data)
		return super().send_head()

if __name__ == "__main__":
	encodings = ["gzip"] + (["br"] if brotli else [])
	for folder, _, files in os.walk(ROOT):
		for name in files:
			if name.endswith(COMPRESS):
				for encoding in encodings:
					get_compressed(os.path.abspath(os.path.join(folder, name)), encoding)
	ThreadingHTTPServer(("", 5001), Handler).serve_forever()
# serve.py
import gzip
import io
import os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

ROOT = "web-export"
COMPRESS = (".wasm", ".js", ".pck", ".html", ".css", ".svg")
LONG_CACHE = (".wasm", ".js")
cache = {}  # path -> (mtime, gzipped bytes)

def get_gzipped(path):
	mtime = os.path.getmtime(path)
	entry = cache.get(path)
	if entry is None or entry[0] != mtime:
		with open(path, "rb") as f:
			entry = (mtime, gzip.compress(f.read(), compresslevel=9))
			
		cache[path] = entry
	return entry

class Handler(SimpleHTTPRequestHandler):
	def end_headers(self):
		if self.path.split("?")[0].endswith(LONG_CACHE):
			self.send_header("Cache-Control", "public, max-age=86400")
		else:
			self.send_header("Cache-Control", "no-cache")
			
		super().end_headers()

	def send_head(self):
		path = self.translate_path(self.path)
		wants_gzip = "gzip" in self.headers.get("Accept-Encoding", "")
		
		if wants_gzip and os.path.isfile(path) and path.endswith(COMPRESS):
			mtime, data = get_gzipped(path)
			etag = f'"{int(mtime)}-{len(data)}"'
			
			if self.headers.get("If-None-Match") == etag:
				self.send_response(304)
				self.send_header("ETag", etag)
				self.end_headers()
				return None
			
			self.send_response(200)
			self.send_header("Content-Type", self.guess_type(path))
			self.send_header("Content-Encoding", "gzip")
			self.send_header("Content-Length", str(len(data)))
			self.send_header("ETag", etag)
			self.send_header("Vary", "Accept-Encoding")
			self.end_headers()
			
			return io.BytesIO(data)
		
		return super().send_head()

if __name__ == "__main__":
	# 'warm' the cache so the first visitor doesn't wait on gzip
	for folder, _, files in os.walk(ROOT):
		for name in files:
			if name.endswith(COMPRESS):
				get_gzipped(os.path.join(folder, name))
	ThreadingHTTPServer(("", 5001), Handler).serve_forever()
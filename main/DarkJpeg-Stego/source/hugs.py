
# Copyright (C) 2013 Mikhail Mukovnikov <m.mukovnikov@gmail.com>

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import webapp2
import urllib2
import base64

cors = 'http://yndi.github.io'
hugs = '<p style="font: 120px Verdana;">\(^_^)/</p>'
size = 64 * 1024

class RootHandler(webapp2.RequestHandler):
    def get(self):
        self.response.write(hugs)

class ProxyHandler(webapp2.RequestHandler):
    def get(self, url):
        try:
            url = base64.standard_b64decode(url)
            req = urllib2.urlopen(url)

            chunk = req.read(10)
            if not chunk or (chunk[6:10] != 'JFIF' and chunk[6:10] != 'Exif'):
                self.response.status = '405 Method Not Allowed'
                self.response.headers.add('Access-Control-Allow-Origin', cors)
                self.response.write(hugs)
                return

            clen = [y for (x, y)
                      in req.headers.items()
                      if x == 'content-length'] or [0]

            self.response.headers.add('Content-Length', clen[0])
            self.response.headers.add('Content-Type', 'image/jpeg')
            self.response.headers.add('Access-Control-Allow-Origin', cors)

            while True:
                self.response.write(chunk)
                chunk = req.read(size)
                if not chunk: break
        except:
            self.response.status = '406 Not Acceptable'
            self.response.headers.add('Access-Control-Allow-Origin', cors)
            self.response.write(hugs)


application = webapp2.WSGIApplication([
    ('/',     RootHandler),
    ('/(.+)', ProxyHandler),
])

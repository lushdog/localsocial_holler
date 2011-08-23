#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from google.appengine.api import urlfetch
import httplib
import StringIO
import base64
import logging
import cgi


class MainHandler(webapp.RequestHandler):
   
   def post(self):
   
   		token = cgi.escape(self.request.get("token"))
   		
   		url = "https://go.urbanairship.com/api/device_tokens/" + token + "/"
   		authentication = base64.b64encode("iIFovCvgQEa_9Q4lMIQCKA:RgYrsOWYS3aeR93O4wu9NQ")
   		headers = {"Authorization" : "Basic " + authentication}
   		response = urlfetch.fetch(url, payload=None, method=urlfetch.PUT, headers=headers, allow_truncated=False, follow_redirects=True, deadline=None, validate_certificate=True)
   		self.response.set_status(response.status_code)
   		self.response.out = StringIO.StringIO(response.content)
   		if int(response.status_code) > 400:
   			logging.info("Registration to UA failed, URL = %s, STATUS CODE = %s, REASON = %s", url, response.status_code, response.content)    	

def main():
    application = webapp.WSGIApplication([('/register', MainHandler)],
                                         debug=True)
                                         
    util.run_wsgi_app(application)


if __name__ == '__main__':
    main()

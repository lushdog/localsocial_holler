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
   
   		logging.info("Start Message")
   		msg = cgi.escape(self.request.get("msg"))
   		logging.info(msg);
   		location = cgi.escape(self.request.get("location"))
   		logging.info(location);
   		
   		url = "https://go.urbanairship.com/api/push/"
   		authentication = base64.b64encode("iIFovCvgQEa_9Q4lMIQCKA:mfi4p62CRjW1halaJ_Ur4A")
   		headers = {"Authorization" : "Basic " + authentication, "Content-Type" : "application/json"}
   		
   		#postBody = "{\
		#			\"device_tokens\": [\
		#				\"some device token\",\
		#				\"another device token\"\
		#			],\
		#			\"aliases\": [\
		#				\"user1\",\
		#				\"user2\"\
		#			],\
		#			\"tags\": [\
		#				\"tag1\",\
		#				\"tag2\"\
		#			],\
		#			\"schedule_for\": [\
		#				\"2010-07-27 22:48:00\",\
		#				\"2010-07-28 22:48:00\"\
		#			],\
		#			\"exclude_tokens\": [\
		#				\"device token you want to skip\",\
		#			],\
		#			\"aps\": {\
		#				 \"badge\": 10,\
		#				 \"alert\": \"Hello from Urban Airship!\",\
		#				 \"sound\": \"cat.caf\"\
		#					}\
		#			}"
		
		#todo: not device tokens but location area as per new UA location api
		#until geolocation is in we'll just send back to user
   		
   		token = cgi.escape(self.request.get("token"))
   		
		postBody = "{\"device_tokens\": [\"%(token)s\"],\"aps\": {\"alert\": \"%(message)s\",\"sound\": \"default\"}}" % {"token":token,"message":msg}
		#postBody = "{\"aps\": {\"alert\": \"Hello from Urban Airship!\"}, \"device_tokens\": [\"4738D84B0740F2E219587D2042C9955A218F6ABECB9A5AE7FC1C7CA10DE76DAB\"]}"
																								
		response = urlfetch.fetch(url, payload=postBody, method=urlfetch.POST, headers=headers, allow_truncated=False, follow_redirects=True, deadline=None, validate_certificate=True)
   		self.response.set_status(response.status_code)
   		self.response.out = StringIO.StringIO(response.content)
   		logging.info(postBody);
   		if int(response.status_code) >= 400:
   			logging.info("Push message to UA failed, URL = %s, BODY = %s, STATUS CODE = %s, REASON = %s", url, postBody, response.status_code, response.content)    	

def main():
    application = webapp.WSGIApplication([('/message', MainHandler)],
                                         debug=True)
                                         
    util.run_wsgi_app(application)


if __name__ == '__main__':
    main()

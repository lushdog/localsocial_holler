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
from google.appengine.ext import db
import httplib
import StringIO
import base64
import logging
import cgi
import math

class Message(db.Model):
                location = db.GeoPtProperty(required=True)
                content = db.StringProperty(required=True, multiline=False)
                timestamp = db.DateTimeProperty(required=True, auto_now_add=True)
                
class BoundingBox(object):
                def __init__(self, *args, **kwargs):
                                self.lat_min = None
                                self.lon_min = None
                                self.lat_max = None
                                self.lon_max = None
    
                @classmethod
                def get_bounding_box(cls, latitude_in_degrees, longitude_in_degrees, half_side_in_km):
                                assert half_side_in_km > 0
                                assert latitude_in_degrees >= -180.0 and latitude_in_degrees  <= 180.0
                                assert longitude_in_degrees >= -180.0 and longitude_in_degrees <= 180.0
                                lat = math.radians(latitude_in_degrees)
                                lon = math.radians(longitude_in_degrees)
                                
                                radius  = 6371
                                # Radius of the parallel at given latitude
                                parallel_radius = radius*math.cos(lat)
                                
                                lat_min = lat - half_side_in_km/radius
                                lat_max = lat + half_side_in_km/radius
                                lon_min = lon - half_side_in_km/parallel_radius
                                lon_max = lon + half_side_in_km/parallel_radius
                                rad2deg = math.degrees
                                
                                box = BoundingBox()
                                box.lat_min = rad2deg(lat_min)
                                box.lon_min = rad2deg(lon_min)
                                box.lat_max = rad2deg(lat_max)
                                box.lon_max = rad2deg(lon_max)
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
from google.appengine.ext import db
import httplib
import StringIO
import base64
import logging
import cgi
import math

class Message(db.Model):
                location = db.GeoPtProperty(required=True)
                content = db.StringProperty(required=True, multiline=False)
                timestamp = db.DateTimeProperty(required=True, auto_now_add=True)
                
class BoundingBox(object):
                def __init__(self, *args, **kwargs):
                                self.lat_min = None
                                self.lon_min = None
                                self.lat_max = None
                                self.lon_max = None
    
                @classmethod
                def get_bounding_box(cls, latitude_in_degrees, longitude_in_degrees, half_side_in_km):
                                assert half_side_in_km > 0
                                assert latitude_in_degrees >= -180.0 and latitude_in_degrees  <= 180.0
                                assert longitude_in_degrees >= -180.0 and longitude_in_degrees <= 180.0
                                lat = math.radians(latitude_in_degrees)
                                lon = math.radians(longitude_in_degrees)
                                
                                radius  = 6371
                                # Radius of the parallel at given latitude
                                parallel_radius = radius*math.cos(lat)
                                
                                lat_min = lat - half_side_in_km/radius
                                lat_max = lat + half_side_in_km/radius
                                lon_min = lon - half_side_in_km/parallel_radius
                                lon_max = lon + half_side_in_km/parallel_radius
                                rad2deg = math.degrees
                                
                                box = BoundingBox()
                                box.lat_min = rad2deg(lat_min)
                                box.lon_min = rad2deg(lon_min)
                                box.lat_max = rad2deg(lat_max)
                                box.lon_max = rad2deg(lon_max)
                                return (box)

class MainHandler(webapp.RequestHandler):
                
                def storeMessage(self, location, content):
                                message = Message(location=location, content=unicode(content))
                                #message.update_location()
                                message.put() #TODO: do this async

                def pushMessage(self, location, content, token):
                                url = "https://go.urbanairship.com/api/push/"
                                authentication = base64.b64encode("iIFovCvgQEa_9Q4lMIQCKA:mfi4p62CRjW1halaJ_Ur4A")
                                headers = {"Authorization" : "Basic " + authentication, "Content-Type" : "application/json"}
                
                                #postBody = "{\
                                #                       \"device_tokens\": [\
                                #                               \"some device token\",\
                                #                               \"another device token\"\
                                #                       ],\
                                #                       \"aliases\": [\
                                #                               \"user1\",\
                                #                               \"user2\"\
                                #                       ],\
                                #                       \"tags\": [\
                                #                               \"tag1\",\
                                #                               \"tag2\"\
                                #                       ],\
                                #                       \"schedule_for\": [\
                                #                               \"2010-07-27 22:48:00\",\
                                #                               \"2010-07-28 22:48:00\"\
                                #                       ],\
                                #                       \"exclude_tokens\": [\
                                #                               \"device token you want to skip\",\
                                #                       ],\
                                #                       \"aps\": {\
                                #                                \"badge\": 10,\
                                #                                \"alert\": \"Hello from Urban Airship!\",\
                                #                                \"sound\": \"cat.caf\"\
                                #                                       }\
                                #                       }"
                                #postBody = "{\"aps\": {\"alert\": \"Hello from Urban Airship!\"}, \"device_tokens\": [\"4738D84B0740F2E219587D2042C9955A218F6ABECB9A5AE7FC1C7CA10DE76DAB\"]}"
                                postBody = "{\"device_tokens\": [\"%(token)s\"],\"aps\": {\"alert\": \"%(message)s\",\"sound\": \"default\"}}" % {"token":token,"message":content}
                                response = urlfetch.fetch(url, payload=postBody, method=urlfetch.POST, headers=headers, allow_truncated=False, follow_redirects=True, deadline=None, validate_certificate=True)
                                self.response.set_status(response.status_code)
                                self.response.out.write(response.content)
                                logging.info(postBody);
                                if int(response.status_code) >= 400:
                                        logging.info("Push message to UA failed, URL = %s, BODY = %s, STATUS CODE = %s, REASON = %s", url, postBody, response.status_code, response.content)            


                def get(self):
                                
                                location = cgi.escape(self.request.get("location"))
                                latitude = location.split(',')[0]
                                longitude = location.split(',')[1]
                                
                                boundingBox = getBoundingBox(latitude, longitude, 0.5)
                                
                                logging.info("Retrieving messages for location :1, thus bounding box is :2", location, boundingBox)
                                
                                #todo; retrieve from memcache if available
                                #todo; store result in memcache 

   
                def post(self):
                   
                                msg = cgi.escape(self.request.get("msg"))
                                location = cgi.escape(self.request.get("location"))
                                latitude = location.split(',')[0]
                                longitude = location.split(',')[1]
                                geopt = db.GeoPt(latitude,longitude)
                                token = cgi.escape(self.request.get("token"))
                                
                                logging.info("Starting message...")
                                logging.info(msg);
                                logging.info(geopt);
                                logging.info(token);
                                
                                logging.info("Storing message...")
                                self.storeMessage(location, msg)
                                
                                logging.info("Pushing message...")
                                self.pushMessage(location, msg, token)
                                
def main():
                application = webapp.WSGIApplication([('/message', MainHandler)], debug=True)
                util.run_wsgi_app(application)

if __name__ == '__main__':
                main()

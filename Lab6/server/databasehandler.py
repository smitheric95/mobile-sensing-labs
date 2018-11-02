#!/usr/bin/python

import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options
from tornado import gen

from basehandler import BaseHandler

import time
import json
import os
import uuid

IMAGE_PATH = 'images/'

class DatabaseHandler(BaseHandler):
    def get(self):
        self.write("get")

    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def post(self):
        class_name = self.get_argument("class_name", "", True)
        if class_name == "":
            self.write("No class name provided")
        file_info = self.request.files['image'][0]
        status = yield self._save_image_with_name(file_info, class_name)
        self.write(status)

    @tornado.gen.coroutine
    def _save_image_with_name(self, file_info, class_name):
        # file upload: https://technobeans.com/2012/09/17/tornado-file-uploads/
        fname = file_info['filename']
        extn = os.path.splitext(fname)[1]
        cname = str(uuid.uuid4()) + extn
        with open(IMAGE_PATH + cname, 'wb') as i:
            i.write(file_info['body'])
        self.db.images.insert({
            "class_name": class_name,
            "file_name": fname
        })
        raise gen.Return("uploaded " + fname)

class TestHandler(BaseHandler):
    def get(self):
        '''Write out to screen
        '''
        self.write("Test of Hello World");

class PostHandlerAsGetArguments(BaseHandler):
    def post(self):
        ''' If a post request at the specified URL
        Respond with arg1 and arg1*4
        '''
        arg1 = self.get_float_arg("arg1",default=1.0);
        self.write_json({"arg1":arg1,"arg2":4*arg1});

    def get(self):
        '''respond with arg1*2
        '''
        arg1 = self.get_float_arg("arg1",default="none");
        # self.write("Get from Post Handler? " + str(arg1*2));
        self.write_json({"arg1":arg1,"arg2":4*arg1});

class JSONPostHandler(BaseHandler):
    def post(self):
        '''Respond with arg1 and arg1*4
        '''
        data = json.loads(self.request.body)
        self.write_json({"arg1":data['arg'][0]*2,"arg2":data['arg']});


class LogToDatabaseHandler(BaseHandler):
    def get(self):
        '''log query to database
        '''
        vals = self.get_argument("arg");
        t = time.time()
        dbid = self.db.queries.insert(
            {"arg":vals,"time":t}
            );
        self.write_json({"id":str(dbid)});

# deprecated functionality 
class FileUploadHandler(BaseHandler):
    def post(self):
        print(str(self.request))
        # nginx should be setup for this to work properly
        # you will need to forward the fields to get it running
        # something with _name and _path


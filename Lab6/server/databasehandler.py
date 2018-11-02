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
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def get(self):
        status = yield self._get_all_image_names()
        self.write_json({ "images": status })

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
        image_path = IMAGE_PATH + cname
        with open(image_path, 'wb') as i:
            i.write(file_info['body'])
        self.db.images.insert({
            'class_name': class_name,
            'file_name': image_path
        })
        raise gen.Return("uploaded " + fname)

    @tornado.gen.coroutine
    def _get_all_image_names(self):
        cursor = self.db.images.find()
        result = []
        for i in cursor:
            result.append({
                'file_name': i['file_name'],
                'class_name': i['class_name']
            })
        raise gen.Return(result)


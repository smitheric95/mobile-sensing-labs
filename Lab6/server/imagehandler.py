#!/usr/bin/python

import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options
from tornado import gen

from basehandler import BaseHandler

from split_up_text import get_split_images

import time
import json
import os
import uuid

MODEL_PATH = 'models/'

class ImageHandler(BaseHandler):
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def post(self):
        image_info = self.request.files['image'][0]
        status = yield self._label_image(image_info)
        self.write(status)

    @tornado.gen.coroutine
    def _label_image(self, image):
        print(image['filename'])
        raise gen.Return("text here")


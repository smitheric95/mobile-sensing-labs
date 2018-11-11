#!/usr/bin/python

import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options
from tornado import gen

from keras.models import load_model

from basehandler import BaseHandler
from split_up_text import get_split_images

import time
import json
import os
import uuid
import numpy as np

MODEL_PATH = 'models/'
MODEL_NAME = 'cnn_11_10.h5'
MODEL = load_model(MODEL_PATH + MODEL_NAME)

classes = []
with open('classes.txt', 'r') as f:
    classes = f.read().split()

def to_class(ohe_arr):
    return classes[np.argmax(ohe_arr)]

class SplitImageHandler(BaseHandler):
    # send images:
    # https://gist.github.com/mstaflex/c346b02b215e4099d09b
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def post(self):
        image_info = self.request.files['image'][0]
        images = yield self._split_image(image_info)
        boundary = str(uuid.uuid4())
        self.set_header('Cache-Control', 'no-store, no-cache, must-revalidate, pre-check=0, post-check=0, max-age=0')
        self.set_header('Connection', 'close')
        self.set_header( 'Content-Type', 'multipart/x-mixed-replace;boundary={}'.format(boundary))
        for i in images:
            self.write(boundary + '\r\n')
            self.write("Content-type: image/jpeg\r\n")
            self.write("Content-length: {}\r\n\r\n".format(len(i)))
            self.write(str(i))

        self.write("here")

    @tornado.gen.coroutine
    def _split_image(self, image):
        print(image.keys())
        print(image['filename'])
        sub_images = get_split_images(image['body'])
        raise gen.Return(sub_images)

class ImageHandler(SplitImageHandler):
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def post(self):
        image_info = self.request.files['image'][0]
        status = yield self._label_image(image_info)
        print(status)
        self.write(status)

    @tornado.gen.coroutine
    def _label_image(self, image):
        sub_images = yield self._split_image(image)
        result = ""
        for i in sub_images:
            result += to_class(MODEL.predict(i))
        raise gen.Return(result)


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
MODEL_NAME = 'cnn_11_3.h5'
MODEL = load_model(MODEL_PATH + MODEL_NAME)

classes = []
with open('classes.txt', 'r') as f:
    classes = f.read().split()

def to_class(ohe_arr):
    return classes[np.argmax(ohe_arr)]

class ImageHandler(BaseHandler):
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def post(self):
        image_info = self.request.files['image'][0]
        status = yield self._label_image(image_info)
        self.write(status)

    @tornado.gen.coroutine
    def _label_image(self, image):
        print(image.keys())
        print(image['filename'])
        sub_images = get_split_images(image['body'])
        result = ""
        for i in sub_images:
            result += to_class(MODEL.predict(i))
        raise gen.Return(result)


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
import requests
import subprocess
import uuid

CODE_DIR = "./code/"

SANDBOX_API_KEY = ""
with open('sandbox-key.txt', 'r') as f:
    SANDBOX_API_KEY = f.read().strip()

class ExecutionHandler(BaseHandler):
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def get(self):
        sent_key = self.request.headers.get('X-Sandbox-API-Key')
        code_id = self.get_argument('code_id', '', True)
        self.write(sent_key + '\n')
        self.write(code_id)

    @tornado.gen.coroutine
    def _exec_code_in_sandbox(self, code_id):
        file_name = self._code_id_to_file(code_id)

        print(r.headers)
        print(r.text)

        raise gen.Return(r.text)

    def _code_id_to_file(self, code_id):
        return CODE_DIR + str(code_id) + '.py'


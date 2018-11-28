#!/usr/bin/python

import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options
from tornado import gen

from basehandler import BaseHandler

import docker
import time
import json
import os
import requests
import subprocess
import uuid

CODE_DIR = "/code/"

SANDBOX_API_KEY = ""
with open('sandbox-key.txt', 'r') as f:
    SANDBOX_API_KEY = f.read().strip()

DOCKER = docker.from_env()

class ExecutionHandler(BaseHandler):
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def get(self):
        sent_key = self.request.headers.get('X-Sandbox-API-Key')
        if sent_key == SANDBOX_API_KEY:
            code_id = self.get_argument('code_id', '', True)
            exec_result = yield self._exec_code_in_sandbox(code_id)
            self.write(exec_result)

    @tornado.gen.coroutine
    def _exec_code_in_sandbox(self, code_id):
        file_name = self._code_id_to_file(code_id)

        output = DOCKER.containers.run("python:3.6-alpine", ["python", file_name],
            mem_limit='10m', volumes=['code-volume:/code:ro'])

        raise gen.Return(output)

    def _code_id_to_file(self, code_id):
        return CODE_DIR + str(code_id) + '.py'


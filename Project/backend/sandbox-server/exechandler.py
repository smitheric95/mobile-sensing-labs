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

CODE_DIR = "./code/"

SANDBOX_API_KEY = ""
with open('sandbox-key.txt', 'r') as f:
    SANDBOX_API_KEY = f.read().strip()

NUM_SANDBOXES = 4
SANDBOXES = [None for _ in range(NUM_SANDBOXES)]
IN_USE = [False for _ in range(NUM_SANDBOXES)]

DOCKER = docker.from_env()

class ExecutionHandler(BaseHandler):
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def get(self):
        sent_key = self.request.headers.get('X-Sandbox-API-Key')
        if sent_key == SANDBOX_API_KEY:
            #if SANDBOXES.count(None) == NUM_SANDBOXES:
            #    yield self._refresh_sandboxes()
            code_id = self.get_argument('code_id', '', True)
            file_name = self._code_id_to_file(code_id)[1:]
            container = DOCKER.containers.run("python:3.6-alpine", ["python", file_name],
                mem_limit='10m', volumes={CODE_DIR[1:]: {'bind': '/code', 'mode': 'ro'}})
            self.write(str(container))
            #sandbox_num = yield self._pick_sandbox()
            #print(DOCKER.containers.list())
            #for s in SANDBOXES:
            #    self.write(str(s))
            #    self.write(str(s.status))
            #if sandbox_num != -1:
                #exec_result = yield self._exec_code_in_sandbox(code_id, sandbox_num)
                #yield self._replace_sandbox(sandbox_num)
                #self.write(exec_result)
            #else:
                #self.write("Could not grab sandbox")

    @tornado.gen.coroutine
    def _exec_code_in_sandbox(self, code_id, sandbox_num):
        file_name = self._code_id_to_file(code_id)[1:]
        print(SANDBOXES)
        print(sandbox_num)

        output = SANDBOXES[sandbox_num].exec_run(["python3", file_name])

        raise gen.Return(output)

    @tornado.gen.coroutine
    def _refresh_sandboxes(self):
        for i in range(NUM_SANDBOXES):
            yield self._replace_sandbox(i)

    @tornado.gen.coroutine
    def _replace_sandbox(self, idx):
        if SANDBOXES[idx] != None and IN_USE[idx]:
            SANDBOXES[idx].stop()
            SANDBOXES[idx].remove()
        elif SANDBOXES[idx] != None:
            raise gen.Return()
        container = DOCKER.containers.run("python:3.6-alpine", ["/bin/sh"], detach=True,
            mem_limit='10m', volumes={CODE_DIR[1:]: {'bind': '/code', 'mode': 'ro'}})
        container.start()
        SANDBOXES[idx] = container
        IN_USE[idx] = False
        raise gen.Return()

    @tornado.gen.coroutine
    def _pick_sandbox(self):
        try:
            idx = IN_USE.index(False)
            IN_USE[idx] = True
            raise gen.Return(idx)
        except (ValueError):
            raise gen.Return(-1)

    def _code_id_to_file(self, code_id):
        return CODE_DIR + str(code_id) + '.py'


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
import subprocess
import uuid
import numpy as np

CODE_DIR = "./code/"

class CodeHandler(BaseHandler):
    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def post(self):
        code = self.get_argument('code', '', True)
        code_id = uuid.uuid4()
        save_status = yield self._save_code(code_id, code)
        lint_status = yield self._lint_code(code_id)
        self.write(save_status + "\n\n" + lint_status)

    @tornado.gen.coroutine
    def _save_code(self, code_id, code):
        file_name = self._code_id_to_file(code_id)
        with open(file_name, 'w+') as f:
            f.write(code)
        raise gen.Return(file_name)

    @tornado.gen.coroutine
    def _lint_code(self, code_id):
        file_name = self._code_id_to_file(code_id)
        subprocess.run(['autopep8', '--in-place', '--aggressive', file_name])
        raise gen.Return("lint")

    def _code_id_to_file(self, code_id):
        return CODE_DIR + str(code_id) + '.py'

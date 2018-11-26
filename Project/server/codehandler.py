#!/usr/bin/python

import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options
from tornado import gen

from basehandler import BaseHandler
from codefixer import fuzzy_fix_file

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
        code = tornado.escape.json_decode(self.request.body)['code']
        code_id = uuid.uuid4()
        save_status = yield self._save_code(code_id, code)
        lint_status = yield self._lint_code(code_id)
        compile_check = yield self._is_compileable(code_id)
        if compile_check == True:
            self.write("compiled")
        else:
            compile_check = yield self._fuzzy_fix_code(code_id, compile_check)
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
        subprocess.run(['autopep8', '--in-place', '--aggressive', '--aggressive', file_name])
        raise gen.Return("lint")

    @tornado.gen.coroutine
    def _is_compileable(self, code_id):
        file_name = self._code_id_to_file(code_id)
        compile_check = subprocess.run(['python3', '-m', 'py_compile', file_name], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        if compile_check.returncode == 0:
            raise gen.Return(True)
        raise gen.Return(compile_check.stdout)

    @tornado.gen.coroutine
    def _fuzzy_fix_code(self, code_id, compile_check):
        n_runs = 0
        file_name = self._code_id_to_file(code_id)
        fuzzy_fix_file(file_name, compile_check)
        compile_check = yield self._is_compileable(code_id)
        while compile_check != True and n_runs > 0:
            passing = fuzzy_fix_file(file_name, compile_check)
            compile_check = yield self._is_compileable(code_id)
            n_runs -= 1
        raise gen.Return(compile_check)

    def _code_id_to_file(self, code_id):
        return CODE_DIR + str(code_id) + '.py'


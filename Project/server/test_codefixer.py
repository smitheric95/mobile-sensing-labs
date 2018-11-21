import pytest
import subprocess
from codefixer import read_error
from codefixer import fuzzy_fix_syntax_error

TEST_CODE_DIR = './test-code/'

def read_and_parse_error(file_name):
    code_in = ""
    with open(file_name, 'r') as f:
        code_in = f.read()

    return code_in, build_parse_error(file_name)

def build_parse_error(file_name):
    compile_check = subprocess.run(['python3', '-m', 'py_compile', file_name], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return read_error(compile_check)

def test_add_missing_colon_at_function_end():
    file_name = TEST_CODE_DIR + 'function_no_colon.py'
    code_in, error = read_and_parse_error(file_name)
    code_out = fuzzy_fix_syntax_error(code_in, error)

    expected = code_in.rstrip() + ':'
    assert code_out == expected

def test_add_missing_colon_at_if_end():
    file_name = TEST_CODE_DIR + 'if_no_colon.py'
    code_in, error = read_and_parse_error(file_name)
    code_out = fuzzy_fix_syntax_error(code_in, error)

    expected = 'if True:\n    print(\'hi\')'
    assert code_out == expected

def test_add_missing_colon_at_elif_end():
    file_name = TEST_CODE_DIR + 'elif_no_colon.py'
    code_in, error = read_and_parse_error(file_name)
    code_out = fuzzy_fix_syntax_error(code_in, error)

    expected = """
if True:
    print('hi')
elif False:
    print('bye')
    """.strip()
    assert code_out == expected


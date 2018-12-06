import re

missing_quote_empty_string_re = re.compile(r'(?<![\w\d])("|\')(?![\w\d])', re.MULTILINE)
missing_open_quote_re = re.compile(r'(?<!"|\')(\b[\w\s\d]+)("|\')', re.MULTILINE)
missing_close_quote_re = re.compile(r'("|\')(\b[\w\s\d]+)(?!"|\')\b', re.MULTILINE)
missing_colon_re = re.compile(r'[ifeld]{2,4} [\w=!\.\(\) ]+(\(\))?$', re.MULTILINE)
incorrect_plus_re = re.compile(r' t ', re.MULTILINE)
incorrect_open_paren_re = re.compile(r'<.*\)', re.MULTILINE)
incorrect_close_paren_re = re.compile(r'\(.*>', re.MULTILINE)
incorrect_both_paren_re = re.compile(r'<.*>', re.MULTILINE)

class ParseError(object):
    def __init__(self, e_type, line, pos):
        self.e_type = e_type
        self.line = line
        self.pos = pos

    def __str__(self):
        return "{} at {}:{}".format(self.e_type, self.line, self.pos)
        
def read_file(file_name):
    with open(file_name, 'r') as f:
        return f.read()

def read_error(compile_check):
    compile_check = str(compile_check)
    lines = compile_check.split('\\n')
    e_type = lines[-3].split(':')[0]
    line = lines[0].split('line ')[-1]
    pos = 0
    for i, l in enumerate(lines):
        if '^' in l:
            len_code_line = len(lines[i-1])
            diff = len_code_line - len(lines[i-1].strip())
            pos = l.index('^') - diff
    return ParseError(e_type, line, pos)

def rewrite_file(file_name, code):
    with open(file_name, 'w') as f:
        f.write(code)

def fix_incorrect_plus(code):
    lines = code.splitlines()
    result = []
    for l in lines:
        l = l.rstrip()
        m = incorrect_plus_re.search(l)
        if m:
            result.append(l[:m.start()] + " + " + l[m.end():])
        else:
            result.append(l)
    return '\n'.join(result)

def fix_missing_both_paren(code):
    lines = code.splitlines()
    result = []
    for l in lines:
        l = l.rstrip()
        m = missing_both_paren_re.search(l)
        if m:
            result.append(l[:m.start()] + m.group(1).replace("<", "(").replace(">", ")") + l[m.end():])
        else:
            result.append(l)
    return '\n'.join(result)

def fix_missing_open_paren(code):
    lines = code.splitlines()
    result = []
    for l in lines:
        l = l.rstrip()
        m = missing_open_paren_re.search(l)
        if m:
            result.append(l[:m.start()] + m.group(1).replace("<", "(") + l[m.end():])
        else:
            result.append(l)
    return '\n'.join(result)

def fix_missing_close_paren(code):
    lines = code.splitlines()
    result = []
    for l in lines:
        l = l.rstrip()
        m = missing_close_paren_re.search(l)
        if m:
            result.append(l[:m.start()] + m.group(1).replace(">", ")") + l[m.end():])
        else:
            result.append(l)
    return '\n'.join(result)

def fuzzy_fix_missing_quote_empty_string(code):
    lines = code.splitlines()
    result = []
    for l in lines:
        l = l.rstrip()
        m = missing_quote_empty_string_re.search(l)
        if m:
            result.append(l[:m.start()] + m.group(1) + l[m.start():])
        else:
            result.append(l)
    return '\n'.join(result)

def fuzzy_fix_open_quote(code):
    lines = code.splitlines()
    result = []
    for l in lines:
        l = l.rstrip()
        m = missing_open_quote_re.search(l)
        if m:
            result.append(l[:m.start()] + m.group(2) + l[m.start():])
        else:
            result.append(l)
    return '\n'.join(result)

def fuzzy_fix_close_quote(code):
    lines = code.splitlines()
    result = []
    for l in lines:
        l = l.rstrip()
        m = missing_close_quote_re.search(l)
        if m:
            result.append(l[:m.end()] + m.group(1) + l[m.end():])
        else:
            result.append(l)
    return '\n'.join(result)

def fuzzy_fix_colon(code):
    lines = code.splitlines()
    result = []
    for l in lines:
        l = l.rstrip()
        if missing_colon_re.match(l):
            result.append(l + ':')
        else:
            result.append(l)
    return '\n'.join(result)

def fuzzy_fix_syntax_error(code, error):
    print(error)
    print(code)

    # TODO: handle mistaken capital char (make all lower?)

    if incorrect_plus_re.search(code):
        code = fix_incorrect_plus(code)

    # TODO: fix incorrect quote

    if missing_both_paren_re.search(code):
        code = fix_missing_both_paren(code)

    elif missing_open_paren_re.search(code):
        code = fix_missing_open_paren(code)

    elif missing_close_paren_re.search(code):
        code = fix_missing_close_paren(code)

    # TODO: fix incorrect square brace (J, j)

    # TODO: fix incorrect colon

    # TODO: handle nested/escaped quotes?

    if missing_quote_empty_string_re.search(code):
        code = fuzzy_fix_missing_quote_empty_string(code)

    elif missing_open_quote_re.search(code):
        code = fuzzy_fix_open_quote(code)

    elif missing_close_quote_re.search(code):
        code = fuzzy_fix_close_quote(code)

    # TODO: missing open paren

    # TODO: missing close paren

    # TODO: missing open square brace

    # TODO: missing close square brace

    if missing_colon_re.search(code):
        code = fuzzy_fix_colon(code)

    # TODO: incomplete control seq keyword (def, if, elif, else, for, while)

    print(code)
    return code

def fuzzy_fix_file(file_name, compile_check):
    code = read_file(file_name)
    error = read_error(compile_check)

    if error.e_type == 'SyntaxError':
        code = fuzzy_fix_syntax_error(code, error)

    rewrite_file(file_name, code)


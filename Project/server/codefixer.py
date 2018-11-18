import re

missing_colon_re = re.compile(r'[ifeld]{2,4} [\w=!\.\(\) ]+(\(\))?$', re.MULTILINE)

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

    # TODO: missing open quote

    # TODO: missing close quote

    # TODO: missing open paren

    # TODO: missing close paren

    # TODO: missing colon
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


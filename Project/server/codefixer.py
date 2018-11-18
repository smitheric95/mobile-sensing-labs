
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
    print(compile_check)
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

def fuzzy_fix_syntax_error(code, error):
    print(error)
    print(code)

    # TODO: missing open quote

    # TODO: missing close quote

    # TODO: missing open paren

    # TODO: missing close paren

    # TODO: missing colon

    # TODO: incomplete control seq keyword (def, if, elif, else, for, while)

def fuzzy_fix_file(file_name, compile_check):
    code = read_file(file_name)
    error = read_error(compile_check)
    print(error)


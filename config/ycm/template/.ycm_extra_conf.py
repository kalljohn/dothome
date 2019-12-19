#!/usr/bin/env python3
# vim: set ts=4 sw=4 et

import os
import sys

__THIS_SCRIPT_FILE_PATH = os.path.dirname(os.path.abspath(__file__))

def Settings(**kwargs):
    base_path = __THIS_SCRIPT_FILE_PATH
    base_name = os.path.basename(base_path)
    parent_path = os.path.dirname(base_path)

    compiler_opts = []
    include_dirs = []

    sys.path.insert(0, parent_path)

    try:
        m = __import__(base_name)
        compiler_opts += m.GetCompilerOptions()
        include_dirs += [p for p in m.GetCommonIncludeDirs()]
    except Exception as e:
        pass

    del sys.path[0]

    flags = compiler_opts + [
        '-I' + p for p in include_dirs
    ]

    return {
        'flags': flags
    }


if __name__ == '__main__':
    print(Settings())

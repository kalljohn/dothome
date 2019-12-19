#!/usr/bin/env python3
# vim: set ts=4 sw=4 et

import os
import sys

__THIS_SCRIPT_FILE_PATH = os.path.dirname(os.path.abspath(__file__))

__PCH_FILENAME_LIST = ('stdafx.h', 'pch.h')

def GetProjPath():
    proj_path = __THIS_SCRIPT_FILE_PATH

    while 1:
        git_path = os.path.join(proj_path, ".git")
        if os.path.exists(git_path) and os.path.isdir(git_path):
            break
        proj_path = os.path.dirname(proj_path)

    return proj_path


def GetProjFlags(proj_path):
    compiler_options = []
    include_dirs = []

    if proj_path and os.path.exists(proj_path):
        proj_parent_path = os.path.abspath(os.path.join(proj_path, ".."))
        proj_base_name = os.path.basename(proj_path)
        sys.path.insert(0, proj_parent_path)
        try:
            m = __import__(proj_base_name)
            compiler_options = m.GetCompilerOptions()
            include_dirs = [p for p in m.GetCommonIncludeDirs()]
        except Exception as e:
            pass
        del sys.path[0]

    return compiler_options, include_dirs


def Settings(**kwargs):
    filename = kwargs.get("filename", "")
    base_path = __THIS_SCRIPT_FILE_PATH
    proj_path = GetProjPath()
    proj_flags = GetProjFlags(proj_path)

    compiler_options = proj_flags[0][:]
    include_dirs = proj_flags[1][:]

    include_dirs += [base_path]

    if os.path.basename(filename) not in __PCH_FILENAME_LIST:
        for pch in __PCH_FILENAME_LIST:
            pch_path = os.path.join(base_path, pch)
            if os.path.exists(pch_path):
                compiler_options += [ '-include', pch_path ]
                break

    flags = compiler_options + [
        '-I' + p for p in include_dirs
    ]

    return { 'flags': flags }


if __name__ == '__main__':
    print(Settings())

#!/usr/bin/env python3
# vim: set ts=4 sw=4 et

import os

SCRIPT_PATH = os.path.abspath(__file__)
PROJ_PATH   = os.path.dirname(SCRIPT_PATH)
PROJ_NAME   = os.path.basename(PROJ_PATH)

def GetCompilerOptions():
    return [
        '-x', 'c++',
        '-std=c++11',
        '-D_DEBUG',
        '-Wall',
        '-Wextra',
        '-Wno-deprecated-declarations',
        '-Wno-unused-parameter',
        '-Wno-missing-field-initializers',
        '-Wno-unused-variable',
    ]


def GetCompilerIncludeDirs():
    import subprocess

    with subprocess.Popen(['gcc', '-dumpversion'], stdout=subprocess.PIPE) as proc:
        proc.wait()
        if proc.returncode == 0:
            gcc_version = bytes.decode(proc.stdout.readline().splitlines()[0], errors='ignore')
            return [ dir for dir in (
                '/usr/include/c++/' + gcc_version,
                '/usr/include/x86_64-linux-gnu/c++/' + gcc_version,
                ) if os.path.exists(dir)
                ]

    return []


def GetCommonIncludeDirs():

    include_dirs = GetCompilerIncludeDirs()

    include_dirs += [
        os.path.abspath(os.path.join(PROJ_PATH, p)) for p in (
            'include',
        )
    ]

    root_fs_dirs = []

    root_fs_name_lists = ("stage", "LinkFS")

    head = SCRIPT_PATH

    while 1:
        head, tail = os.path.split(head)
        if len(tail) == 0:
            break
        for name in root_fs_name_lists:
            root_fs_path = os.path.join(head, name)
            if os.path.exists(root_fs_path):
                root_fs_dirs.append(root_fs_path)

    if os.path.exists("/dev/shm/stage"):
        root_fs_dirs.append("/dev/shm/stage")

    for p in root_fs_dirs:
        inc_dir = os.path.join(p, "include")
        if os.path.exists(inc_dir):
            include_dirs.append(inc_dir)
            break

    return include_dirs

if __name__ == "__main__":
    print("project path: ", PROJ_PATH)
    print("project name: ", PROJ_NAME)
    print("project include dirs: ", GetCommonIncludeDirs())

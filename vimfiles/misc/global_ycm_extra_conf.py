#!/usr/bin/env python3
# vim: set ts=4 sw=4 sts=4 et

import os

SCRIPT_PATH = os.path.abspath(__file__)
SCRIPT_DIR  = os.path.dirname(SCRIPT_PATH)

def GetCompilerOptions():
    return [
        '-x', 'c++',
        '-std=c++14',
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

    dirs = [
        '/usr/include',
        '/usr/local/include',
        '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../lib/c++/v1',
        '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include',
    ]

    with subprocess.Popen(['gcc', '-dumpversion'], stdout=subprocess.PIPE) as proc:
        proc.wait()
        if proc.returncode == 0:
            gcc_version = bytes.decode(proc.stdout.readline().splitlines()[0], errors='ignore')
            dirs += [ 
                '/usr/include/c++/' + gcc_version,
                '/usr/include/x86_64-linux-gnu/c++/' + gcc_version,
                '/usr/lib/gcc/x86_64-linux-gnu/' + gcc_version + '/include',
                ]

    dirs = [ dir for dir in dirs if os.path.exists(dir) ]
    return dirs


def Settings(**kwargs):
    compiler_opts = GetCompilerOptions()
    include_dirs = GetCompilerIncludeDirs()

    flags = compiler_opts + [
        '-I' + p for p in include_dirs
    ]

    return {
        'flags': flags
    }
    # return {
        # 'flags': [
            # '-x', 'c++',
            # '-std=c++14',
            # '-D_DEBUG',
            # '-Wall',
            # '-Wextra',
            # '-fexceptions',
            # '-I', '/usr/include',
            # '-I', '/usr/local/include',
            # '-I', '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../lib/c++/v1',
            # '-I', '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include',
            # ]
        # }


if __name__ == "__main__":
    print("default settings: ", Settings())
